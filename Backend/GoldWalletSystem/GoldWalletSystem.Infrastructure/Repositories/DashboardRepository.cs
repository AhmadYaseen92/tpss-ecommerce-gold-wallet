using GoldWalletSystem.Application.DTOs.Dashboard;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class DashboardRepository(AppDbContext dbContext, ICurrentUserService currentUser) : IDashboardRepository
{
    public async Task<DashboardDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.AsNoTracking().FirstAsync(x => x.Id == userId, cancellationToken);
        var sellerScope = !currentUser.IsInRole("Admin") ? currentUser.SellerId : null;

        var walletBalance = await dbContext.Wallets.Where(x => x.UserId == userId).Select(x => x.CashBalance).FirstOrDefaultAsync(cancellationToken);
        var cartItemsQuery = dbContext.CartItems.AsNoTracking().AsQueryable();
        if (sellerScope.HasValue)
        {
            cartItemsQuery = cartItemsQuery.Where(x => (x.SellerId ?? x.Product.SellerId) == sellerScope.Value);
        }
        else
        {
            cartItemsQuery = cartItemsQuery.Where(x => x.Cart.UserId == userId);
        }

        var cartItemsCount = await cartItemsQuery.SumAsync(x => (int?)x.Quantity, cancellationToken) ?? 0;
        var unreadNotifications = await dbContext.AppNotifications.CountAsync(x => x.UserId == userId && !x.IsRead, cancellationToken);

        var monthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
        var monthlySpentQuery = dbContext.TransactionHistories.Where(x => x.TransactionType == "Purchase" && x.CreatedAtUtc >= monthStart);
        monthlySpentQuery = sellerScope.HasValue
            ? monthlySpentQuery.Where(x => x.SellerId == sellerScope.Value)
            : monthlySpentQuery.Where(x => x.UserId == userId);
        var monthlySpent = await monthlySpentQuery.SumAsync(x => (decimal?)x.FinalAmount, cancellationToken) ?? 0;

        return new DashboardDto(userId, user.FullName, walletBalance, cartItemsCount, unreadNotifications, monthlySpent);
    }
}
