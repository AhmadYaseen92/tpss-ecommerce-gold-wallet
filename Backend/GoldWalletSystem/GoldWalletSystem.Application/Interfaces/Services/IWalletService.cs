using GoldWalletSystem.Application.DTOs.Wallet;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IWalletService
{
    Task<WalletDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
}
