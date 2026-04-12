using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class ProfileRepository(AppDbContext dbContext, IPasswordHasher passwordHasher) : IProfileRepository
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

        var profile = await GetOrCreateProfileAsync(request.UserId, cancellationToken);

        user.FullName = request.FullName.Trim();
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
}
