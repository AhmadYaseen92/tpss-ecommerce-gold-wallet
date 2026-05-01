using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using System.Security.Cryptography;

namespace GoldWalletSystem.Application.Services;

public class AuthService(
    IUserAuthRepository userAuthRepository,
    IPasswordHasher passwordHasher,
    ITokenService tokenService,
    IOtpService otpService) : IAuthService
{
    private static readonly HashSet<string> AllowedMarketTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "UAE", "KSA", "Jordan", "Egypt", "India"
    };
    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        var loginIdentifier = request.ResolveLoginIdentifier();
        if (string.IsNullOrWhiteSpace(loginIdentifier) || string.IsNullOrWhiteSpace(request.Password))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var normalizedLoginIdentifier = loginIdentifier.Trim();
        if (!AuthInputValidation.IsValidEmail(normalizedLoginIdentifier) && !AuthInputValidation.IsValidUaeMobile(normalizedLoginIdentifier))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var user = await ValidateCredentialsAsync(normalizedLoginIdentifier, request.Password, cancellationToken);
        return await BuildLoginResponseAsync(user, cancellationToken);
    }

    public async Task<LoginResponseDto> RefreshTokenAsync(RefreshTokenRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshToken))
            throw new UnauthorizedAccessException("Invalid refresh token.");

        var payload = ParseRefreshToken(request.RefreshToken);
        var existing = await userAuthRepository.GetActiveRefreshTokenAsync(payload.UserId, HashToken(request.RefreshToken), cancellationToken)
            ?? throw new UnauthorizedAccessException("Refresh token is expired or revoked.");

        await userAuthRepository.RevokeRefreshTokenAsync(existing.Id, cancellationToken);

        var user = await userAuthRepository.GetByIdAsync(payload.UserId, cancellationToken)
            ?? throw new UnauthorizedAccessException("User not found.");

        return await BuildLoginResponseAsync(user, cancellationToken);
    }

    public async Task LogoutAsync(int userId, string? refreshToken = null, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrWhiteSpace(refreshToken))
        {
            try
            {
                var payload = ParseRefreshToken(refreshToken);
                if (payload.UserId == userId)
                {
                    var existing = await userAuthRepository.GetActiveRefreshTokenAsync(payload.UserId, HashToken(refreshToken), cancellationToken);
                    if (existing is not null)
                    {
                        await userAuthRepository.RevokeRefreshTokenAsync(existing.Id, cancellationToken);
                        return;
                    }
                }
            }
            catch
            {
            }
        }

        await userAuthRepository.RevokeAllRefreshTokensAsync(userId, cancellationToken);
    }

    public async Task<RegisterResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.FirstName) ||
            string.IsNullOrWhiteSpace(request.LastName) ||
            string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            throw new InvalidOperationException("First name, last name, email and password are required.");
        }

        var existing = await userAuthRepository.GetByEmailAsync(request.Email.Trim(), cancellationToken);
        if (existing is not null)
        {
            throw new InvalidOperationException("Email is already registered.");
        }

        var role = string.IsNullOrWhiteSpace(request.Role) ? SystemRoles.Investor : request.Role.Trim();
        var requestedMarketType = string.IsNullOrWhiteSpace(request.MarketType)
            ? request.CompanyInfo?.MarketType
            : request.MarketType;
        var normalizedMarketType = NormalizeMarketTypeOrDefault(requestedMarketType);
        var fullName = $"{request.FirstName.Trim()} {request.MiddleName.Trim()} {request.LastName.Trim()}".Replace("  ", " ").Trim();

        var user = new User
        {
            FullName = fullName,
            Email = request.Email.Trim(),
            PasswordHash = passwordHasher.Hash(request.Password),
            PhoneNumber = request.PhoneNumber?.Trim(),
            Role = role,
            IsActive = false,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow,
        };

        var profile = new UserProfile
        {
            DateOfBirth = request.DateOfBirth,
            Nationality = request.Nationality,
            DocumentType = request.DocumentType,
            IdNumber = request.IdNumber,
            ProfilePhotoUrl = request.ProfilePhotoUrl,
            PreferredLanguage = string.IsNullOrWhiteSpace(request.PreferredLanguage) ? "en" : request.PreferredLanguage,
            PreferredTheme = string.IsNullOrWhiteSpace(request.PreferredTheme) ? "light" : request.PreferredTheme,
            MarketType = normalizedMarketType,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow,
        };

        if (request.CompanyInfo is not null)
        {
            request.CompanyInfo.MarketType = normalizedMarketType;
        }
        var seller = await BuildSellerEntityAsync(request, role, cancellationToken);
        var createdResult = await userAuthRepository.AddWithOptionalSellerAsync(user, profile, seller, cancellationToken);

        var otp = await otpService.RequestAsync(new RequestOtpRequestDto
        {
            UserId = createdResult.User.Id,
            ActionType = OtpActionTypes.Registration,
            ActionReferenceId = createdResult.User.Id.ToString(),
            ForceEmailFallback = false
        }, cancellationToken);

        return new RegisterResponseDto
        {
            UserId = createdResult.User.Id,
            Email = createdResult.User.Email,
            FullName = createdResult.User.FullName,
            Role = createdResult.User.Role,
            SellerId = createdResult.Seller?.Id,
            RequiresOtpVerification = true,
            OtpRequestId = otp.OtpRequestId
        };
    }

    public async Task VerifyRegistrationOtpAsync(VerifyRegistrationOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var verified = await otpService.VerifyAsync(new VerifyOtpRequestDto
        {
            UserId = request.UserId,
            OtpRequestId = request.OtpRequestId,
            OtpCode = request.OtpCode
        }, cancellationToken);

        await otpService.ConsumeVerificationGrantAsync(
            request.UserId,
            OtpActionTypes.Registration,
            request.UserId.ToString(),
            verified.VerificationToken,
            cancellationToken);

        await userAuthRepository.ActivateUserAsync(request.UserId, cancellationToken);
    }

    public async Task<OtpDispatchResponseDto> RequestPasswordResetOtpAsync(RequestPasswordResetOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
            throw new InvalidOperationException("Email is required.");

        var user = await userAuthRepository.GetByEmailAsync(request.Email.Trim(), cancellationToken)
            ?? throw new InvalidOperationException("User not found.");

        return await otpService.RequestAsync(new RequestOtpRequestDto
        {
            UserId = user.Id,
            ActionType = OtpActionTypes.ResetPassword,
            ActionReferenceId = user.Id.ToString(),
            ForceEmailFallback = false
        }, cancellationToken);
    }

    public async Task ConfirmPasswordResetAsync(ConfirmPasswordResetRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.NewPassword))
            throw new InvalidOperationException("Email and new password are required.");

        var user = await userAuthRepository.GetByEmailAsync(request.Email.Trim(), cancellationToken)
            ?? throw new InvalidOperationException("User not found.");

        var verified = await otpService.VerifyAsync(new VerifyOtpRequestDto
        {
            UserId = user.Id,
            OtpRequestId = request.OtpRequestId,
            OtpCode = request.OtpCode
        }, cancellationToken);

        await otpService.ConsumeVerificationGrantAsync(
            user.Id,
            OtpActionTypes.ResetPassword,
            user.Id.ToString(),
            verified.VerificationToken,
            cancellationToken);

        await userAuthRepository.UpdatePasswordAsync(user.Id, passwordHasher.Hash(request.NewPassword), cancellationToken);
    }

    private async Task<LoginResponseDto> BuildLoginResponseAsync(User user, CancellationToken cancellationToken)
    {
        var role = string.IsNullOrWhiteSpace(user.Role) ? SystemRoles.Investor : user.Role;
        var sellerProfile = await userAuthRepository.GetSellerByUserIdAsync(user.Id, cancellationToken);
        var sellerId = sellerProfile?.Id;

        var token = tokenService.GenerateAccessToken(user.Id, user.Email, role, sellerId);
        var refreshToken = BuildRefreshToken(user.Id);

        await userAuthRepository.AddRefreshTokenAsync(new RefreshToken
        {
            UserId = user.Id,
            TokenHash = HashToken(refreshToken.Token),
            ExpiresAtUtc = refreshToken.ExpiresAtUtc,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        }, cancellationToken);

        return new LoginResponseDto
        {
            AccessToken = token.Token,
            ExpiresAtUtc = token.ExpiresAtUtc,
            RefreshToken = refreshToken.Token,
            RefreshTokenExpiresAtUtc = refreshToken.ExpiresAtUtc,
            Role = role,
            UserId = user.Id,
            FullName = user.FullName,
            SellerId = sellerId,
            SellerName = sellerProfile?.CompanyName
        };
    }

    private async Task<User> ValidateCredentialsAsync(string emailOrPhone, string password, CancellationToken cancellationToken)
    {
        var loginIdentifier = emailOrPhone.Trim();
        var user = await userAuthRepository.GetByEmailAsync(loginIdentifier, cancellationToken)
            ?? await userAuthRepository.GetByPhoneAsync(loginIdentifier, cancellationToken)
            ?? throw new UnauthorizedAccessException("User not found.");

        if (!user.IsActive)
            throw new UnauthorizedAccessException("User is not active.");

        if (!passwordHasher.Verify(password, user.PasswordHash))
            throw new UnauthorizedAccessException("Credential error.");

        await ValidateSellerAccountAsync(user, cancellationToken);
        return user;
    }

    private async Task ValidateSellerAccountAsync(User user, CancellationToken cancellationToken)
    {
        var role = string.IsNullOrWhiteSpace(user.Role) ? SystemRoles.Investor : user.Role;
        if (!string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase))
            return;

        var seller = await userAuthRepository.GetSellerByUserIdAsync(user.Id, cancellationToken);
        if (seller is null)
            throw new UnauthorizedAccessException("Seller account is not linked.");

        if (seller.KycStatus != KycStatus.Approved || !seller.IsActive)
        {
            var reason = seller.KycStatus == KycStatus.Blocked
                ? "Seller account is blocked."
                : "Seller account is awaiting admin approval.";
            throw new UnauthorizedAccessException(reason);
        }
    }

    private async Task<Seller?> BuildSellerEntityAsync(RegisterRequestDto request, string role, CancellationToken cancellationToken)
    {
        var isSeller = string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase);
        if (!isSeller)
            return null;

        ValidateSellerRegistration(request);

        var seller = new Seller
        {
            CompanyName = request.CompanyInfo.CompanyName.Trim(),
            CompanyCode = await BuildSellerCodeAsync(request, cancellationToken),
            CommercialRegistrationNumber = request.CompanyInfo.CommercialRegistrationNumber.Trim(),
            VatNumber = request.CompanyInfo.VatNumber.Trim(),
            BusinessActivity = request.CompanyInfo.BusinessActivity.Trim(),
            EstablishedDate = request.CompanyInfo.EstablishedDate,
            CompanyPhone = request.CompanyInfo.CompanyPhone.Trim(),
            CompanyEmail = request.CompanyInfo.CompanyEmail.Trim(),
            Website = request.CompanyInfo.Website?.Trim(),
            Description = request.CompanyInfo.Description?.Trim(),
            MarketType = request.CompanyInfo.MarketType.Trim().ToUpperInvariant(),
            IsActive = false,
            KycStatus = KycStatus.UnderReview,
            CreatedAtUtc = DateTime.UtcNow,
            Address = new SellerAddress
            {
                Country = request.CompanyInfo.Country.Trim(),
                City = request.CompanyInfo.City.Trim(),
                Street = request.CompanyInfo.Street.Trim(),
                BuildingNumber = request.CompanyInfo.BuildingNumber.Trim(),
                PostalCode = request.CompanyInfo.PostalCode.Trim(),
                CreatedAtUtc = DateTime.UtcNow
            },
            Managers =
            [
                new SellerManager
                {
                    FullName = request.Manager.FullName.Trim(),
                    PositionTitle = request.Manager.PositionTitle.Trim(),
                    Nationality = request.Manager.Nationality.Trim(),
                    MobileNumber = request.Manager.MobileNumber.Trim(),
                    EmailAddress = request.Manager.EmailAddress.Trim(),
                    IdType = request.Manager.IdType.Trim(),
                    IdNumber = request.Manager.IdNumber.Trim(),
                    IdExpiryDate = request.Manager.IdExpiryDate,
                    IsPrimary = true,
                    CreatedAtUtc = DateTime.UtcNow
                }
            ],
            Branches = request.Branches.Select(branch => new SellerBranch
            {
                BranchName = branch.BranchName.Trim(),
                Country = branch.Country.Trim(),
                City = branch.City.Trim(),
                FullAddress = branch.FullAddress.Trim(),
                BuildingNumber = branch.BuildingNumber.Trim(),
                PostalCode = branch.PostalCode.Trim(),
                PhoneNumber = branch.PhoneNumber.Trim(),
                Email = branch.Email.Trim(),
                IsMainBranch = branch.IsMainBranch,
                CreatedAtUtc = DateTime.UtcNow
            }).ToList(),
            BankAccounts = request.BankAccounts.Select(bank => new SellerBankAccount
            {
                BankName = bank.BankName.Trim(),
                AccountHolderName = bank.AccountHolderName.Trim(),
                AccountNumber = bank.AccountNumber.Trim(),
                IBAN = bank.Iban.Trim(),
                SwiftCode = bank.SwiftCode.Trim(),
                BankCountry = bank.BankCountry.Trim(),
                BankCity = bank.BankCity.Trim(),
                BranchName = bank.BranchName.Trim(),
                BranchAddress = bank.BranchAddress.Trim(),
                Currency = bank.Currency.Trim(),
                IsMainAccount = bank.IsMainAccount,
                CreatedAtUtc = DateTime.UtcNow
            }).ToList(),
            Documents = request.Documents.Select(doc => new SellerDocument
            {
                DocumentType = doc.DocumentType.Trim(),
                FileName = doc.FileName.Trim(),
                FilePath = doc.FilePath.Trim(),
                ContentType = doc.ContentType.Trim(),
                IsRequired = doc.IsRequired,
                UploadedAtUtc = DateTime.UtcNow,
                RelatedEntityType = doc.RelatedEntityType,
                RelatedEntityId = doc.RelatedEntityId,
                CreatedAtUtc = DateTime.UtcNow
            }).ToList()
        };

        return seller;
    }

    private async Task<string> BuildSellerCodeAsync(RegisterRequestDto request, CancellationToken cancellationToken)
    {
        return await userAuthRepository.GenerateNextCompanyCodeAsync(cancellationToken);
    }


    private static (int UserId, DateTime ExpiresAtUtc) ParseRefreshToken(string rawToken)
    {
        var parts = rawToken.Split('.', 3);
        if (parts.Length != 3 || !int.TryParse(parts[0], out var userId))
            throw new UnauthorizedAccessException("Invalid refresh token.");

        var unixTime = Convert.FromBase64String(parts[1]);
        var ticks = BitConverter.ToInt64(unixTime, 0);
        var expires = DateTimeOffset.FromUnixTimeSeconds(ticks).UtcDateTime;
        if (expires <= DateTime.UtcNow)
            throw new UnauthorizedAccessException("Refresh token expired.");

        return (userId, expires);
    }

    private static (string Token, DateTime ExpiresAtUtc) BuildRefreshToken(int userId)
    {
        var expiresAtUtc = DateTime.UtcNow.AddDays(7);
        var expiresUnix = new DateTimeOffset(expiresAtUtc).ToUnixTimeSeconds();
        var random = RandomNumberGenerator.GetBytes(64);
        var token = $"{userId}.{Convert.ToBase64String(BitConverter.GetBytes(expiresUnix))}.{Convert.ToBase64String(random)}";
        return (token, expiresAtUtc);
    }

    private static string HashToken(string token)
    {
        var bytes = System.Text.Encoding.UTF8.GetBytes(token);
        var hash = SHA256.HashData(bytes);
        return Convert.ToHexString(hash);
    }

    private static void ValidateSellerRegistration(RegisterRequestDto request)
    {
        var company = request.CompanyInfo;
        var manager = request.Manager;

        var missingFields = new List<string>();

        var requiredFields = new (string Name, string? Value)[]
        {
            ("CompanyInfo.CompanyName", company.CompanyName),
            ("CompanyInfo.CommercialRegistrationNumber", company.CommercialRegistrationNumber),
            ("CompanyInfo.VatNumber", company.VatNumber),
            ("CompanyInfo.BusinessActivity", company.BusinessActivity),
            ("CompanyInfo.Country", company.Country),
            ("CompanyInfo.City", company.City),
            ("CompanyInfo.Street", company.Street),
            ("CompanyInfo.BuildingNumber", company.BuildingNumber),
            ("CompanyInfo.PostalCode", company.PostalCode),
            ("CompanyInfo.CompanyPhone", company.CompanyPhone),
            ("CompanyInfo.CompanyEmail", company.CompanyEmail),
            ("CompanyInfo.MarketType", company.MarketType),
            ("Manager.FullName", manager.FullName),
            ("Manager.PositionTitle", manager.PositionTitle),
            ("Manager.Nationality", manager.Nationality),
            ("Manager.MobileNumber", manager.MobileNumber),
            ("Manager.EmailAddress", manager.EmailAddress),
            ("Manager.IdType", manager.IdType),
            ("Manager.IdNumber", manager.IdNumber)
        };

        missingFields.AddRange(requiredFields
            .Where(x => string.IsNullOrWhiteSpace(x.Value))
            .Select(x => x.Name));

        if (request.Branches.Count == 0)
            missingFields.Add("Branches[0]");
        else
        {
            for (var i = 0; i < request.Branches.Count; i++)
            {
                var branch = request.Branches[i];
                if (string.IsNullOrWhiteSpace(branch.BranchName)) missingFields.Add($"Branches[{i}].BranchName");
                if (string.IsNullOrWhiteSpace(branch.Country)) missingFields.Add($"Branches[{i}].Country");
                if (string.IsNullOrWhiteSpace(branch.City)) missingFields.Add($"Branches[{i}].City");
                if (string.IsNullOrWhiteSpace(branch.FullAddress)) missingFields.Add($"Branches[{i}].FullAddress");
                if (!string.IsNullOrWhiteSpace(branch.PostalCode) && !AuthInputValidation.IsNumericOnly(branch.PostalCode))
                    throw new InvalidOperationException($"Branch #{i + 1} postal code must be numeric.");
                if (!string.IsNullOrWhiteSpace(branch.PhoneNumber) && !AuthInputValidation.IsValidInternationalPhone(branch.PhoneNumber))
                    throw new InvalidOperationException($"Branch #{i + 1} phone number format is invalid.");
            }
        }

        if (request.BankAccounts.Count == 0)
            missingFields.Add("BankAccounts[0]");
        else
        {
            for (var i = 0; i < request.BankAccounts.Count; i++)
            {
                var bank = request.BankAccounts[i];
                if (string.IsNullOrWhiteSpace(bank.BankName)) missingFields.Add($"BankAccounts[{i}].BankName");
                if (string.IsNullOrWhiteSpace(bank.AccountHolderName)) missingFields.Add($"BankAccounts[{i}].AccountHolderName");
                if (string.IsNullOrWhiteSpace(bank.AccountNumber)) missingFields.Add($"BankAccounts[{i}].AccountNumber");
                if (string.IsNullOrWhiteSpace(bank.Iban)) missingFields.Add($"BankAccounts[{i}].Iban");
                if (!string.IsNullOrWhiteSpace(bank.Iban) && !AuthInputValidation.IsValidIban(bank.Iban))
                    throw new InvalidOperationException($"Bank account #{i + 1} IBAN format is invalid.");
                if (!string.IsNullOrWhiteSpace(bank.SwiftCode) && !AuthInputValidation.IsValidSwift(bank.SwiftCode))
                    throw new InvalidOperationException($"Bank account #{i + 1} SWIFT format is invalid.");
            }
        }

        var requiredDocs = new[]
        {
            "CommercialRegistrationDocument",
            "ProofOfAddress",
            "AmlDocumentation",
            "ManagerIdCopy"
        };

        var providedDocTypes = request.Documents
            .Select(x => x.DocumentType)
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        var missingDocs = requiredDocs.Where(x => !providedDocTypes.Contains(x)).ToList();
        missingFields.AddRange(missingDocs.Select(x => $"Documents:{x}"));


        if (!string.IsNullOrWhiteSpace(company.CommercialRegistrationNumber) && !AuthInputValidation.IsNumericOnly(company.CommercialRegistrationNumber))
            throw new InvalidOperationException("Company trade license number must be numeric.");

        if (!string.IsNullOrWhiteSpace(company.VatNumber) && !AuthInputValidation.IsNumericOnly(company.VatNumber))
            throw new InvalidOperationException("Company VAT number must be numeric.");

        if (!string.IsNullOrWhiteSpace(company.PostalCode) && !AuthInputValidation.IsNumericOnly(company.PostalCode))
            throw new InvalidOperationException("Company postal code must be numeric.");

        if (!string.IsNullOrWhiteSpace(company.CompanyPhone) && !AuthInputValidation.IsValidInternationalPhone(company.CompanyPhone))
            throw new InvalidOperationException("Company phone number format is invalid.");

        if (!string.IsNullOrWhiteSpace(manager.MobileNumber) && !AuthInputValidation.IsValidInternationalPhone(manager.MobileNumber))
            throw new InvalidOperationException("Manager mobile number format is invalid.");

        if (!string.IsNullOrWhiteSpace(manager.EmailAddress) && !AuthInputValidation.IsValidEmail(manager.EmailAddress))
            throw new InvalidOperationException("Manager email address format is invalid.");

        if (!string.IsNullOrWhiteSpace(company.CompanyEmail) && !AuthInputValidation.IsValidEmail(company.CompanyEmail))
            throw new InvalidOperationException("Company email address format is invalid.");

        if (!string.IsNullOrWhiteSpace(company.MarketType) && !AllowedMarketTypes.Contains(company.MarketType.Trim()))
            throw new InvalidOperationException("Market type must be one of: UAE, KSA, Jordan, Egypt, India.");

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber) && !AuthInputValidation.IsValidUaeMobile(request.PhoneNumber))
            throw new InvalidOperationException("Login phone number must be a valid UAE mobile format.");

        if (missingFields.Count > 0)
            throw new InvalidOperationException($"All required seller registration fields must be provided. Missing: {string.Join(", ", missingFields)}");
    }


    private static string NormalizeMarketTypeOrDefault(string? marketType)
    {
        if (string.IsNullOrWhiteSpace(marketType)) return "UAE";
        return AllowedMarketTypes.FirstOrDefault(x => x.Equals(marketType.Trim(), StringComparison.OrdinalIgnoreCase)) ?? "UAE";
    }

}
