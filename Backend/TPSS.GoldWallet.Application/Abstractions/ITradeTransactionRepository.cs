using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface ITradeTransactionRepository
{
    Task<IReadOnlyList<TradeTransaction>> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
}
