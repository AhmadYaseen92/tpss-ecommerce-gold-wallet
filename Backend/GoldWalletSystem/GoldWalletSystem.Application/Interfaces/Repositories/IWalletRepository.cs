using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IWalletRepository
{
    Task<Wallet?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
}
