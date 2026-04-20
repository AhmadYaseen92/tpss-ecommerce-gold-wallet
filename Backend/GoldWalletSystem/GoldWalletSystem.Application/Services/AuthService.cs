using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Models.Auth;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using System.Security.Cryptography;
using System.Text.Json;

namespace GoldWalletSystem.Application.Services;

public class AuthService(
    IUserAuthRepository userAuthRepository,
    IPasswordHasher passwordHasher,
    ITokenService tokenService,
    ILoginOtpChallengeStore loginOtpChallengeStore,
    IMobileAppConfigurationRepository mobileAppConfigurationRepository,
    IOtpDeliveryService otpDeliveryService) : IAuthService
{
    private static readonly TimeSpan LoginOtpTtl = TimeSpan.FromMinutes(5);

    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var user = await ValidateCredentialsAsync(request.Email, request.Password, cancellationToken);
        return await BuildLoginResponseAsync(user, cancellationToken);
    }

    public async Task<SendLoginOtpResponseDto> SendLoginOtpAsync(SendLoginOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var user = await ValidateCredentialsAsync(request.Email, request.Password, cancellationToken);
        var channels = await ResolveOtpDeliveryChannelsAsync(cancellationToken);

        var otpCode = GenerateOtpCode();
        var challenge = new LoginOtpChallengeModel
        {
            UserId = user.Id,
            OtpHash = passwordHasher.Hash(otpCode),
            ExpiresAtUtc = DateTime.UtcNow.Add(LoginOtpTtl),
            DeliveryChannels = channels.Select(x => x.ToString()).ToArray()
        };

        await loginOtpChallengeStore.UpsertAsync(challenge, cancellationToken);
        await otpDeliveryService.SendLoginOtpAsync(user, otpCode, channels, cancellationToken);

        return new SendLoginOtpResponseDto
        {
            ExpiresAtUtc = challenge.ExpiresAtUtc,
            DeliveryChannels = channels.Select(x => x.ToString()).ToArray()
        };
    }

    public async Task<LoginResponseDto> VerifyLoginOtpAsync(VerifyLoginOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.OtpCode))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var user = await userAuthRepository.GetByEmailAsync(request.Email.Trim(), cancellationToken)
            ?? throw new UnauthorizedAccessException("Invalid credentials.");

        if (!user.IsActive)
            throw new UnauthorizedAccessException("Invalid credentials.");

        await ValidateSellerAccountAsync(user, cancellationToken);

        var challenge = await loginOtpChallengeStore.GetActiveAsync(user.Id, DateTime.UtcNow, cancellationToken)
            ?? throw new UnauthorizedAccessException("OTP is invalid or expired.");

        if (!passwordHasher.Verify(request.OtpCode.Trim(), challenge.OtpHash))
            throw new UnauthorizedAccessException("OTP is invalid or expired.");

        await loginOtpChallengeStore.RemoveAsync(user.Id, cancellationToken);
        return await BuildLoginResponseAsync(user, cancellationToken);
    }

    private async Task<LoginResponseDto> BuildLoginResponseAsync(User user, CancellationToken cancellationToken)
    {
        var role = string.IsNullOrWhiteSpace(user.Role) ? SystemRoles.Investor : user.Role;
        var sellerId = await userAuthRepository.GetSellerIdForUserAsync(user.Id, cancellationToken);

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
        var sellerId = await userAuthRepository.GetSellerIdForUserAsync(user.Id, cancellationToken);

        if (!string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase))
            return;

        if (!sellerId.HasValue)
            throw new UnauthorizedAccessException("Seller account is not linked.");

        var seller = await userAuthRepository.GetSellerByIdAsync(sellerId.Value, cancellationToken);
        if (seller is null || seller.KycStatus != KycStatus.Approved || !seller.IsActive)
            throw new UnauthorizedAccessException("Seller account is awaiting admin approval.");
    }

    private async Task<IReadOnlyCollection<OtpDeliveryChannel>> ResolveOtpDeliveryChannelsAsync(CancellationToken cancellationToken)
    {
        var configurations = await mobileAppConfigurationRepository.GetAllAsync(cancellationToken);
        var otpConfig = configurations.FirstOrDefault(x =>
            string.Equals(x.ConfigKey, MobileAppConfigurationKeys.LoginOtpDeliveryChannels, StringComparison.OrdinalIgnoreCase)
            && x.IsEnabled);

        if (otpConfig is null || string.IsNullOrWhiteSpace(otpConfig.JsonValue))
            return [OtpDeliveryChannel.WhatsApp];

        try
        {
            var channels = ParseChannels(otpConfig.JsonValue);
            return channels.Count == 0 ? [OtpDeliveryChannel.WhatsApp] : channels;
        }
        catch (JsonException)
        {
            return [OtpDeliveryChannel.WhatsApp];
        }
    }

    private static IReadOnlyCollection<OtpDeliveryChannel> ParseChannels(string jsonValue)
    {
        using var document = JsonDocument.Parse(jsonValue);
        var root = document.RootElement;

        var rawChannels = root.ValueKind switch
        {
            JsonValueKind.Array => root.EnumerateArray().Select(x => x.GetString()),
            JsonValueKind.Object when root.TryGetProperty("channels", out var channelsNode) && channelsNode.ValueKind == JsonValueKind.Array
                => channelsNode.EnumerateArray().Select(x => x.GetString()),
            _ => Array.Empty<string?>()
        };

        return rawChannels
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Select(ParseChannel)
            .Distinct()
            .ToArray();
    }

    private static OtpDeliveryChannel ParseChannel(string? channel)
        => channel?.Trim().ToLowerInvariant() switch
        {
            "whatsapp" => OtpDeliveryChannel.WhatsApp,
            "email" => OtpDeliveryChannel.Email,
            _ => throw new JsonException("Unsupported OTP delivery channel.")
        };

    private static string GenerateOtpCode()
        => RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");

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
