using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class AccountSummaryRepository(AppDbContext dbContext) : IAccountSummaryRepository
{
    public Task<AccountSummarySnapshot?> GetLatestByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        => dbContext.AccountSummaries.Where(x => x.CustomerId == customerId).OrderByDescending(x => x.CreatedAtUtc).FirstOrDefaultAsync(cancellationToken);
}
