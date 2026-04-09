using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class ProfileRepository(AppDbContext dbContext) : IProfileRepository
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

        return new ProfileDto(
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
}
