using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Services;

public class AuthService(
    IUserAuthRepository userAuthRepository,
    IPasswordHasher passwordHasher,
    ITokenService tokenService,
    IOtpService otpService) : IAuthService
{
    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var user = await ValidateCredentialsAsync(request.Email, request.Password, cancellationToken);
        return await BuildLoginResponseAsync(user, cancellationToken);
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
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow,
        };

        var seller = BuildSellerEntity(request, role);
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
        return new LoginResponseDto
        {
            AccessToken = token.Token,
            ExpiresAtUtc = token.ExpiresAtUtc,
            Role = role,
            UserId = user.Id,
            FullName = user.FullName,
            SellerId = sellerId,
            SellerName = sellerProfile?.Name
        };
    }

    private async Task<User> ValidateCredentialsAsync(string email, string password, CancellationToken cancellationToken)
    {
        var user = await userAuthRepository.GetByEmailAsync(email.Trim(), cancellationToken)
            ?? throw new UnauthorizedAccessException("Invalid credentials.");

        if (!user.IsActive || !passwordHasher.Verify(password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

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

    private Seller? BuildSellerEntity(RegisterRequestDto request, string role)
    {
        var isSeller = string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase);
        if (!isSeller)
            return null;

        ValidateSellerRegistration(request);

        var seller = new Seller
        {
            CompanyName = request.CompanyInfo.CompanyName.Trim(),
            CompanyCode = BuildSellerCode(request),
            CommercialRegistrationNumber = request.CompanyInfo.CommercialRegistrationNumber.Trim(),
            VatNumber = request.CompanyInfo.VatNumber.Trim(),
            BusinessActivity = request.CompanyInfo.BusinessActivity.Trim(),
            EstablishedDate = request.CompanyInfo.EstablishedDate,
            CompanyPhone = request.CompanyInfo.CompanyPhone.Trim(),
            CompanyEmail = request.CompanyInfo.CompanyEmail.Trim(),
            Website = request.CompanyInfo.Website?.Trim(),
            Description = request.CompanyInfo.Description?.Trim(),
            IsActive = false,
            KycStatus = KycStatus.Pending,
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

    private static string BuildSellerCode(RegisterRequestDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.CompanyInfo.CompanyCode))
            return request.CompanyInfo.CompanyCode.Trim().ToUpperInvariant();

        var companySeed = string.IsNullOrWhiteSpace(request.CompanyInfo.CompanyName)
            ? "SELL"
            : new string(request.CompanyInfo.CompanyName.Where(char.IsLetterOrDigit).ToArray()).ToUpperInvariant();

        if (companySeed.Length > 6)
            companySeed = companySeed[..6];

        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();
        return $"{companySeed}-{timestamp[^6..]}";
    }

    private static void ValidateSellerRegistration(RegisterRequestDto request)
    {
        var company = request.CompanyInfo;
        var manager = request.Manager;

        var requiredFields = new[]
        {
            company.CompanyName,
            company.CommercialRegistrationNumber,
            company.VatNumber,
            company.BusinessActivity,
            company.Country,
            company.City,
            company.Street,
            company.BuildingNumber,
            company.PostalCode,
            company.CompanyPhone,
            company.CompanyEmail,
            manager.FullName,
            manager.PositionTitle,
            manager.Nationality,
            manager.MobileNumber,
            manager.EmailAddress,
            manager.IdType,
            manager.IdNumber
        };

        if (requiredFields.Any(string.IsNullOrWhiteSpace))
            throw new InvalidOperationException("All required seller registration fields must be provided.");

        if (request.Branches.Count == 0 || request.Branches.Any(x => string.IsNullOrWhiteSpace(x.BranchName)))
            throw new InvalidOperationException("At least one complete branch is required.");

        if (request.BankAccounts.Count == 0 || request.BankAccounts.Any(x => string.IsNullOrWhiteSpace(x.BankName) || string.IsNullOrWhiteSpace(x.Iban)))
            throw new InvalidOperationException("At least one complete bank account is required.");

        var requiredDocs = new[]
        {
            "CommercialRegistrationDocument",
            "ArticlesOfAssociation",
            "ProofOfAddress",
            "VatCertificate",
            "AmlDocumentation",
            "ManagerIdCopy"
        };

        var providedDocTypes = request.Documents
            .Select(x => x.DocumentType)
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        if (requiredDocs.Any(x => !providedDocTypes.Contains(x)))
            throw new InvalidOperationException("Required seller KYC documents are missing.");
    }
}
