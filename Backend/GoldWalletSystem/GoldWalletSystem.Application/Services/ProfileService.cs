using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class ProfileService(IProfileRepository profileRepository) : IProfileService
{
    public Task<ProfileDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
        => profileRepository.GetByUserIdAsync(userId, cancellationToken);
}
