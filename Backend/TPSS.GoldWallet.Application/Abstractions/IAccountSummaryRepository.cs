using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface IAccountSummaryRepository
{
    Task<AccountSummarySnapshot?> GetLatestByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
}
