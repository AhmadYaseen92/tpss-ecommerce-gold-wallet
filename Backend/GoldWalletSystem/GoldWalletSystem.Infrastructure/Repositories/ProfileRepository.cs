using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;

namespace GoldWalletSystem.Infrastructure.Repositories;

public partial class ProfileRepository(AppDbContext dbContext, IPasswordHasher passwordHasher) : IProfileRepository
{
    public async Task<ProfileDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);
        if (user is null) return null;

        var profile = await dbContext.UserProfiles
            .AsNoTracking()
            .Include(x => x.PaymentMethods)
            .Include(x => x.LinkedBankAccounts)
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

        return Map(user, profile);
    }

    public async Task<ProfileDto> UpdatePersonalInfoAsync(UpdateProfilePersonalInfoRequestDto request, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == request.UserId, cancellationToken)
            ?? throw new InvalidOperationException($"User {request.UserId} not found.");
        ValidatePersonalInfoRequest(request, user.Id);

        var profile = await GetOrCreateProfileAsync(request.UserId, cancellationToken);

        user.FullName = request.FullName.Trim();
        user.Email = request.Email.Trim().ToLowerInvariant();
        user.PhoneNumber = request.PhoneNumber?.Trim();
        user.UpdatedAtUtc = DateTime.UtcNow;

        profile.DateOfBirth = request.DateOfBirth;
        profile.Nationality = request.Nationality.Trim();
        profile.DocumentType = request.DocumentType.Trim();
        profile.IdNumber = request.IdNumber.Trim();
        profile.ProfilePhotoUrl = request.ProfilePhotoUrl.Trim();
        profile.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return (await GetByUserIdAsync(request.UserId, cancellationToken))!;
    }

    public async Task<ProfileDto> UpdateSettingsAsync(UpdateProfileSettingsRequestDto request, CancellationToken cancellationToken = default)
    {
        await GetOrCreateProfileAsync(request.UserId, cancellationToken);
        var profile = await dbContext.UserProfiles.FirstAsync(x => x.UserId == request.UserId, cancellationToken);
        profile.PreferredLanguage = string.IsNullOrWhiteSpace(request.PreferredLanguage) ? "en" : request.PreferredLanguage.Trim();
        profile.PreferredTheme = string.IsNullOrWhiteSpace(request.PreferredTheme) ? "light" : request.PreferredTheme.Trim();
        profile.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return (await GetByUserIdAsync(request.UserId, cancellationToken))!;
    }

    public async Task ChangePasswordAsync(UpdatePasswordRequestDto request, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == request.UserId, cancellationToken)
            ?? throw new InvalidOperationException($"User {request.UserId} not found.");

        if (!passwordHasher.Verify(request.CurrentPassword, user.PasswordHash))
            throw new InvalidOperationException("Current password is invalid.");

        user.PasswordHash = passwordHasher.Hash(request.NewPassword);
        user.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<ProfileDto> UpsertPaymentMethodAsync(UpsertPaymentMethodRequestDto request, CancellationToken cancellationToken = default)
    {
        ValidatePaymentMethodRequest(request);
        var profile = await GetOrCreateProfileAsync(request.UserId, cancellationToken);
        var paymentMethod = request.PaymentMethodId is int pmId
            ? await dbContext.PaymentMethods.FirstOrDefaultAsync(x => x.Id == pmId && x.UserProfileId == profile.Id, cancellationToken)
            : null;

        if (paymentMethod is null)
        {
            paymentMethod = new PaymentMethod { UserProfileId = profile.Id, CreatedAtUtc = DateTime.UtcNow };
            dbContext.PaymentMethods.Add(paymentMethod);
        }

        paymentMethod.Type = request.Type.Trim();
        paymentMethod.MaskedNumber = request.MaskedNumber.Trim();
        paymentMethod.IsDefault = request.IsDefault;
        paymentMethod.UpdatedAtUtc = DateTime.UtcNow;

        if (request.IsDefault)
        {
            await dbContext.PaymentMethods
                .Where(x => x.UserProfileId == profile.Id && x.Id != paymentMethod.Id)
                .ExecuteUpdateAsync(setters => setters.SetProperty(x => x.IsDefault, false), cancellationToken);
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return (await GetByUserIdAsync(request.UserId, cancellationToken))!;
    }

    public async Task<ProfileDto> UpsertLinkedBankAccountAsync(UpsertLinkedBankAccountRequestDto request, CancellationToken cancellationToken = default)
    {
        ValidateLinkedBankRequest(request);
        var profile = await GetOrCreateProfileAsync(request.UserId, cancellationToken);
        var bank = request.LinkedBankAccountId is int bankId
            ? await dbContext.LinkedBankAccounts.FirstOrDefaultAsync(x => x.Id == bankId && x.UserProfileId == profile.Id, cancellationToken)
            : null;

        if (bank is null)
        {
            bank = new LinkedBankAccount { UserProfileId = profile.Id, CreatedAtUtc = DateTime.UtcNow };
            dbContext.LinkedBankAccounts.Add(bank);
        }

        bank.BankName = request.BankName.Trim();
        bank.IbanMasked = request.IbanMasked.Trim();
        bank.IsVerified = request.IsVerified;
        bank.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return (await GetByUserIdAsync(request.UserId, cancellationToken))!;
    }

    private async Task<UserProfile> GetOrCreateProfileAsync(int userId, CancellationToken cancellationToken)
    {
        var userExists = await dbContext.Users.AnyAsync(x => x.Id == userId, cancellationToken);
        if (!userExists)
            throw new InvalidOperationException($"User {userId} not found.");

        var profile = await dbContext.UserProfiles.FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);
        if (profile is not null) return profile;

        profile = new UserProfile
        {
            UserId = userId,
            Nationality = string.Empty,
            DocumentType = string.Empty,
            IdNumber = string.Empty,
            ProfilePhotoUrl = string.Empty,
            PreferredLanguage = "en",
            PreferredTheme = "light",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        dbContext.UserProfiles.Add(profile);
        await dbContext.SaveChangesAsync(cancellationToken);
        return profile;
    }

    private static ProfileDto Map(User user, UserProfile? profile)
        => new(
            user.Id,
            user.FullName,
            user.Email,
            user.PhoneNumber,
            profile?.DateOfBirth,
            profile?.Nationality ?? string.Empty,
            profile?.DocumentType ?? string.Empty,
            profile?.IdNumber ?? string.Empty,
            profile?.ProfilePhotoUrl ?? string.Empty,
            profile?.PreferredLanguage ?? "en",
            profile?.PreferredTheme ?? "light",
            (profile?.PaymentMethods ?? []).Select(x => new PaymentMethodDto(x.Id, x.Type, x.MaskedNumber, x.IsDefault)).ToList(),
            (profile?.LinkedBankAccounts ?? []).Select(x => new LinkedBankAccountDto(x.Id, x.BankName, x.IbanMasked, x.IsVerified)).ToList());

    private void ValidatePersonalInfoRequest(UpdateProfilePersonalInfoRequestDto request, int currentUserId)
    {
        if (string.IsNullOrWhiteSpace(request.FullName))
            throw new InvalidOperationException("Full name is required.");
        if (string.IsNullOrWhiteSpace(request.Email))
            throw new InvalidOperationException("Email is required.");
        if (!EmailRegex().IsMatch(request.Email))
            throw new InvalidOperationException("Email format is invalid.");
        if (dbContext.Users.Any(x => x.Email == request.Email.Trim() && x.Id != currentUserId))
            throw new InvalidOperationException("Email is already in use.");
        if (string.IsNullOrWhiteSpace(request.PhoneNumber) || !PhoneRegex().IsMatch(request.PhoneNumber))
            throw new InvalidOperationException("Phone number must be 8-15 digits.");
        if (request.DateOfBirth is null)
            throw new InvalidOperationException("Date of birth is required.");
        if (request.DateOfBirth > DateOnly.FromDateTime(DateTime.UtcNow))
            throw new InvalidOperationException("Date of birth cannot be in the future.");
        if (string.IsNullOrWhiteSpace(request.Nationality))
            throw new InvalidOperationException("Nationality is required.");
        if (string.IsNullOrWhiteSpace(request.DocumentType))
            throw new InvalidOperationException("Document type is required.");
        if (string.IsNullOrWhiteSpace(request.IdNumber) || !IdNumberRegex().IsMatch(request.IdNumber))
            throw new InvalidOperationException("ID Number format is invalid.");
    }

    private static void ValidatePaymentMethodRequest(UpsertPaymentMethodRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.Type))
            throw new InvalidOperationException("Payment method type is required.");
        if (string.IsNullOrWhiteSpace(request.MaskedNumber))
            throw new InvalidOperationException("Payment method details are required.");

        var type = request.Type.Trim().ToLowerInvariant();
        var value = request.MaskedNumber.Trim();
        if ((type.Contains("visa") || type.Contains("master")) && !CardRegex().IsMatch(value))
            throw new InvalidOperationException("Card number must be 12 to 19 digits.");
        if (type.Contains("apple") && !AppleTokenRegex().IsMatch(value))
            throw new InvalidOperationException("Apple Pay token format is invalid.");
        if ((type.Contains("zain") || type.Contains("orange") || type.Contains("dinar")) && !PhoneRegex().IsMatch(value))
            throw new InvalidOperationException("Wallet number format is invalid.");
        if (type.Contains("cliq") && !CliqAliasRegex().IsMatch(value))
            throw new InvalidOperationException("CliQ alias format is invalid.");
    }

    private static void ValidateLinkedBankRequest(UpsertLinkedBankAccountRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.BankName))
            throw new InvalidOperationException("Bank name is required.");
        if (string.IsNullOrWhiteSpace(request.IbanMasked))
            throw new InvalidOperationException("IBAN is required.");
        if (!IbanRegex().IsMatch(request.IbanMasked.Trim().ToUpperInvariant()))
            throw new InvalidOperationException("IBAN format is invalid.");
    }

    [GeneratedRegex(@"^[^\s@]+@[^\s@]+\.[^\s@]+$")]
    private static partial Regex EmailRegex();
    [GeneratedRegex(@"^[+0-9]{8,15}$")]
    private static partial Regex PhoneRegex();
    [GeneratedRegex(@"^[A-Za-z0-9-]{4,30}$")]
    private static partial Regex IdNumberRegex();
    [GeneratedRegex(@"^[0-9]{12,19}$")]
    private static partial Regex CardRegex();
    [GeneratedRegex(@"^[A-Za-z0-9_\-]{8,64}$")]
    private static partial Regex AppleTokenRegex();
    [GeneratedRegex(@"^[A-Za-z0-9._-]{4,40}$")]
    private static partial Regex CliqAliasRegex();
    [GeneratedRegex(@"^[A-Z]{2}[A-Z0-9]{13,32}$")]
    private static partial Regex IbanRegex();
}
