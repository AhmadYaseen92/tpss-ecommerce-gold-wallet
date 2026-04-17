using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Services;

public class AuthService(IUserAuthRepository userAuthRepository, IPasswordHasher passwordHasher, ITokenService tokenService) : IAuthService
{
    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var user = await userAuthRepository.GetByEmailAsync(request.Email, cancellationToken)
            ?? throw new UnauthorizedAccessException("Invalid credentials.");

        if (!user.IsActive || !passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var role = string.IsNullOrWhiteSpace(user.Role) ? SystemRoles.Investor : user.Role;
        var sellerId = await userAuthRepository.GetSellerIdForUserAsync(user.Id, cancellationToken);
        if (string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase))
        {
            if (!sellerId.HasValue)
                throw new UnauthorizedAccessException("Seller account is not linked.");

            var seller = await userAuthRepository.GetSellerByIdAsync(sellerId.Value, cancellationToken);
            if (seller is null || seller.KycStatus != KycStatus.Approved || !seller.IsActive)
            {
                throw new UnauthorizedAccessException("Seller account is awaiting admin approval.");
            }
        }

        var token = tokenService.GenerateAccessToken(user.Id, user.Email, role, sellerId);

        return new LoginResponseDto
        {
            AccessToken = token.Token,
            ExpiresAtUtc = token.ExpiresAtUtc,
            Role = role,
            UserId = user.Id,
            SellerId = sellerId,
            DisplayName = user.FullName
        };
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

        var isSeller = string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase);
        var sellerId = isSeller && request.SellerId.HasValue && request.SellerId.Value > 0
            ? request.SellerId
            : await ResolveSellerIdAsync(request, role, fullName, cancellationToken);

        var user = new User
        {
            FullName = fullName,
            Email = request.Email.Trim(),
            PasswordHash = passwordHasher.Hash(request.Password),
            PhoneNumber = request.PhoneNumber?.Trim(),
            Role = role,
            SellerId = sellerId,
            IsActive = !isSeller,
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

        return new RegisterResponseDto
        {
            UserId = created.Id,
            Email = created.Email,
            FullName = created.FullName,
            Role = created.Role,
            SellerId = sellerId,
        };
    }

    private async Task<int?> ResolveSellerIdAsync(RegisterRequestDto request, string role, string fullName, CancellationToken cancellationToken)
    {
        var isSeller = string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase);
        if (!isSeller)
            return null;

        ValidateSellerRegistration(request);

        var seller = new Seller
        {
            Name = fullName,
            Code = BuildSellerCode(request),
            Email = request.Email.Trim(),
            PasswordHash = passwordHasher.Hash(request.Password),
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

        var createdSeller = await userAuthRepository.AddSellerAsync(seller, cancellationToken);
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
