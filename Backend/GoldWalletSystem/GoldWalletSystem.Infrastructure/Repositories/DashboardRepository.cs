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
        var isAdmin = currentUser.IsInRole("Admin");
        var sellerId = currentUser.SellerId;

        string displayName;

        if (!isAdmin && sellerId.HasValue)
        {
            // ✅ Get seller instead of user
            var seller = await dbContext.Sellers
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == sellerId.Value, cancellationToken);

            if (seller == null)
                throw new KeyNotFoundException($"Seller with ID {sellerId.Value} not found.");

            displayName = seller.Name;
        }
        else
        {
            // Admin fallback → use user
            var user = await dbContext.Users
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);

            if (user == null)
                throw new KeyNotFoundException($"User with ID {userId} not found.");

            displayName = user.FullName;
        }

        // Wallet balance (still per user)
        var walletBalance = await dbContext.Wallets
            .Where(x => x.UserId == userId)
            .Select(x => x.CashBalance)
            .FirstOrDefaultAsync(cancellationToken);

        // Cart items
        var cartItemsQuery = dbContext.CartItems.AsNoTracking();

        if (!isAdmin && sellerId.HasValue)
        {
            cartItemsQuery = cartItemsQuery
                .Where(x => (x.SellerId ?? x.Product.SellerId) == sellerId.Value);
        }
        else
        {
            cartItemsQuery = cartItemsQuery
                .Where(x => x.Cart.UserId == userId);
        }

        var cartItemsCount = await cartItemsQuery
            .SumAsync(x => (int?)x.Quantity, cancellationToken) ?? 0;

        // Notifications (still user-based)
        var unreadNotifications = await dbContext.AppNotifications
            .CountAsync(x => x.UserId == userId && !x.IsRead, cancellationToken);

        // Monthly spent
        var monthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);

        var monthlySpentQuery = dbContext.TransactionHistories
            .Where(x => x.CreatedAtUtc >= monthStart);

        if (!isAdmin && sellerId.HasValue)
        {
            monthlySpentQuery = monthlySpentQuery
                .Where(x => x.SellerId == sellerId.Value);
        }
        else
        {
            monthlySpentQuery = monthlySpentQuery
                .Where(x => x.UserId == userId);
        }

        var monthlySpent = await monthlySpentQuery
            .SumAsync(x => (decimal?)x.Amount, cancellationToken) ?? 0;

        return new DashboardDto(
            userId,
            displayName, // ✅ now from Seller when needed
            walletBalance,
            cartItemsCount,
            unreadNotifications,
            monthlySpent
        );
    }
}
