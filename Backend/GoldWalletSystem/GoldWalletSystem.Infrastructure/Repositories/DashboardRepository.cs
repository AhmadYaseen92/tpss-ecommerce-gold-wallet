using GoldWalletSystem.Application.DTOs.Dashboard;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class DashboardRepository(AppDbContext dbContext) : IDashboardRepository
{
    public async Task<DashboardDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.AsNoTracking().FirstAsync(x => x.Id == userId, cancellationToken);

        var walletBalance = await dbContext.Wallets.Where(x => x.UserId == userId).Select(x => x.CashBalance).FirstOrDefaultAsync(cancellationToken);
        var cartItemsCount = await dbContext.CartItems.Where(x => x.Cart.UserId == userId).SumAsync(x => (int?)x.Quantity, cancellationToken) ?? 0;
        var unreadNotifications = await dbContext.AppNotifications.CountAsync(x => x.UserId == userId && !x.IsRead, cancellationToken);

        var monthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
        var monthlySpent = await dbContext.TransactionHistories
            .Where(x => x.UserId == userId && x.TransactionType == "Purchase" && x.CreatedAtUtc >= monthStart)
            .SumAsync(x => (decimal?)x.Amount, cancellationToken) ?? 0;

        return new DashboardDto(userId, user.FullName, walletBalance, cartItemsCount, unreadNotifications, monthlySpent);
    }
}
