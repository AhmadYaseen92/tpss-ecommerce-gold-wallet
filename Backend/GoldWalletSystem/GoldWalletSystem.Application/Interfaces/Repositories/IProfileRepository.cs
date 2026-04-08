using GoldWalletSystem.Application.DTOs.Profile;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IProfileRepository
{
    Task<ProfileDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
}
