using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class KycRepository(AppDbContext dbContext) : IKycRepository
{
    public Task AddAsync(KycVerification verification, CancellationToken cancellationToken = default)
        => dbContext.KycVerifications.AddAsync(verification, cancellationToken).AsTask();

    public Task<KycVerification?> GetLatestByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        => dbContext.KycVerifications
            .Where(x => x.CustomerId == customerId)
            .OrderByDescending(x => x.SubmittedAtUtc)
            .FirstOrDefaultAsync(cancellationToken);
}
