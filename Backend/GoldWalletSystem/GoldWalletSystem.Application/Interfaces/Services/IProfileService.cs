using GoldWalletSystem.Application.DTOs.Profile;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IProfileService
{
    Task<ProfileDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
}
