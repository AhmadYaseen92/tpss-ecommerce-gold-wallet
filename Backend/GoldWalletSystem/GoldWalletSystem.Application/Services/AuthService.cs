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

        var created = await userAuthRepository.AddAsync(user, profile, cancellationToken);
        var sellerId = await EnsureSellerProfileAsync(created, request, role, fullName, cancellationToken);
        var otp = await otpService.RequestAsync(new RequestOtpRequestDto
        {
            UserId = created.Id,
            ActionType = OtpActionTypes.Registration,
            ActionReferenceId = created.Id.ToString(),
            ForceEmailFallback = false
        }, cancellationToken);

        return new RegisterResponseDto
        {
            UserId = created.Id,
            Email = created.Email,
            FullName = created.FullName,
            Role = created.Role,
            SellerId = sellerId,
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
            throw new UnauthorizedAccessException("Seller account is awaiting admin approval.");
    }

    private async Task<int?> EnsureSellerProfileAsync(User createdUser, RegisterRequestDto request, string role, string fullName, CancellationToken cancellationToken)
    {
        var isSeller = string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase);
        if (!isSeller)
            return null;

        ValidateSellerRegistration(request);

        var seller = new Seller
        {
            UserId = createdUser.Id,
            Name = fullName,
            Code = BuildSellerCode(request),
            ContactEmail = request.Email.Trim(),
            ContactPhone = request.PhoneNumber?.Trim(),
            IsActive = false,
            Country = request.Country.Trim(),
            City = request.City.Trim(),
            Street = request.Street.Trim(),
            BuildingNumber = request.BuildingNumber.Trim(),
            PostalCode = request.PostalCode.Trim(),
            CompanyName = request.CompanyName.Trim(),
            TradeLicenseNumber = request.TradeLicenseNumber.Trim(),
            VatNumber = request.VatNumber.Trim(),
            NationalIdNumber = request.NationalIdNumber.Trim(),
            BankName = request.BankName.Trim(),
            IBAN = request.Iban.Trim(),
            AccountHolderName = request.AccountHolderName.Trim(),
            NationalIdFrontPath = request.NationalIdFrontPath.Trim(),
            NationalIdBackPath = request.NationalIdBackPath.Trim(),
            TradeLicensePath = request.TradeLicensePath.Trim(),
            KycStatus = KycStatus.Pending,
            CreatedAtUtc = DateTime.UtcNow
        };

        var createdSeller = await userAuthRepository.AddSellerProfileAsync(seller, cancellationToken);
        return createdSeller.Id;
    }

    private static string BuildSellerCode(RegisterRequestDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.SellerCode))
            return request.SellerCode.Trim().ToUpperInvariant();

        var companySeed = string.IsNullOrWhiteSpace(request.CompanyName)
            ? "SELL"
            : new string(request.CompanyName.Where(char.IsLetterOrDigit).ToArray()).ToUpperInvariant();

        if (companySeed.Length > 6)
            companySeed = companySeed[..6];

        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();
        return $"{companySeed}-{timestamp[^6..]}";
    }

    private static void ValidateSellerRegistration(RegisterRequestDto request)
    {
        var requiredFields = new[]
        {
            request.Country,
            request.City,
            request.Street,
            request.BuildingNumber,
            request.PostalCode,
            request.CompanyName,
            request.TradeLicenseNumber,
            request.VatNumber,
            request.NationalIdNumber,
            request.BankName,
            request.Iban,
            request.AccountHolderName,
            request.NationalIdFrontPath,
            request.NationalIdBackPath,
            request.TradeLicensePath
        };

        if (requiredFields.Any(string.IsNullOrWhiteSpace))
            throw new InvalidOperationException("All seller registration and KYC fields are required.");
    }
}
