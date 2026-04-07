using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface IKycRepository
{
    Task AddAsync(KycVerification verification, CancellationToken cancellationToken = default);
    Task<KycVerification?> GetLatestByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
}
