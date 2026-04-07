using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface IWalletRepository
{
    Task<WalletAccount?> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
    Task AddAsync(WalletAccount account, CancellationToken cancellationToken = default);
    void Update(WalletAccount account);
}
