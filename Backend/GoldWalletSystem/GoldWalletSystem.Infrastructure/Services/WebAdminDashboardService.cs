using GoldWalletSystem.Application.DTOs.Admin;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Services;

public class WebAdminDashboardService(AppDbContext dbContext) : IWebAdminDashboardService
{
    public async Task<WebDashboardDto> BuildAsync(string period, int? sellerId = null, CancellationToken cancellationToken = default)
    {
        var monthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);

        var productsQuery = dbContext.Products.AsNoTracking().AsQueryable();
        if (sellerId.HasValue)
        {
            productsQuery = productsQuery.Where(x => x.SellerId == sellerId.Value);
        }
        var products = await productsQuery.ToListAsync(cancellationToken);

        var investors = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Role == SystemRoles.Investor)
            .ToListAsync(cancellationToken);
        var sellers = await dbContext.Sellers
            .AsNoTracking()
            .ToDictionaryAsync(x => x.Id, x => x.Name, cancellationToken);

        var requestsQuery = dbContext.TransactionHistories.AsNoTracking().AsQueryable();
        if (sellerId.HasValue)
        {
            requestsQuery = requestsQuery.Where(x => x.SellerId == sellerId.Value);
        }
        requestsQuery = requestsQuery.Where(x => x.CreatedAtUtc >= monthStart);
        var requests = await requestsQuery.OrderByDescending(x => x.CreatedAtUtc).Take(100).ToListAsync(cancellationToken);

        var cartItemsQuery = dbContext.CartItems.AsNoTracking().AsQueryable();
        if (sellerId.HasValue)
        {
            cartItemsQuery = cartItemsQuery.Where(x => x.SellerId == sellerId.Value);
        }

        var cartItems = await cartItemsQuery.ToListAsync(cancellationToken);

        var totalSales = products.Sum(p => p.Price * p.AvailableStock);
        var goldAvg = products.Where(p => p.Category == ProductCategory.Gold).Select(p => p.Price).DefaultIfEmpty(0).Average();

        var statusCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
        {
            ["pending"] = requests.Count(x => x.Status == "pending"),
            ["approved"] = requests.Count(x => x.Status == "approved"),
            ["rejected"] = requests.Count(x => x.Status == "rejected")
        };

        var statusTotal = Math.Max(statusCounts.Values.Sum(), 1);

        var categoryCounts = products
            .GroupBy(p => p.Category.ToString())
            .Select(g => new { Key = g.Key, Value = g.Count() })
            .OrderByDescending(x => x.Value)
            .ToList();
        var categoryTotal = Math.Max(categoryCounts.Sum(x => x.Value), 1);

        var recent = requests
            .Take(6)
            .Select((request, idx) => new WebRecentTransactionDto
            {
                Id = $"r-{request.Id}",
                SellerName = request.SellerId.HasValue && sellers.TryGetValue(request.SellerId.Value, out var sellerName) ? sellerName : "N/A",
                InvestorName = investors.FirstOrDefault(i => i.Id == request.UserId)?.FullName ?? $"User {request.UserId}",
                ProductName = products.Count > 0 ? products[idx % products.Count].Name : "N/A",
                Type = request.TransactionType,
                Amount = request.Amount,
                Status = request.Status,
                CreatedAt = request.CreatedAtUtc
            })
            .ToList();

        var allCategoryNames = Enum.GetValues<ProductCategory>().Select(x => x.ToString()).ToList();
        var transactionCountByCategory = allCategoryNames.ToDictionary(x => x, _ => 0, StringComparer.OrdinalIgnoreCase);
        var cartCountByCategory = allCategoryNames.ToDictionary(x => x, _ => 0, StringComparer.OrdinalIgnoreCase);

        var walletAssetsQuery = dbContext.WalletAssets.AsNoTracking().AsQueryable();
        if (sellerId.HasValue)
        {
            walletAssetsQuery = walletAssetsQuery.Where(x => x.SellerId == sellerId.Value);
        }

        var walletAssetGroups = await walletAssetsQuery
            .GroupBy(x => x.Category)
            .Select(group => new { Category = group.Key, Count = group.Sum(x => x.Quantity) })
            .ToListAsync(cancellationToken);

        foreach (var group in walletAssetGroups)
        {
            var categoryName = group.Category.ToString();
            if (!transactionCountByCategory.ContainsKey(categoryName)) continue;
            transactionCountByCategory[categoryName] = (int)group.Count;
        }

        var categoryTransactionSeries = allCategoryNames
            .Select(categoryName => new WebDashboardPointDto { Label = categoryName, Value = transactionCountByCategory.TryGetValue(categoryName, out var count) ? count : 0 })
            .ToList();

        foreach (var group in cartItems.GroupBy(item => item.Category.ToString()))
        {
            cartCountByCategory[group.Key] = group.Sum(x => x.Quantity);
        }

        var categoryCartSeries = allCategoryNames
            .Select(categoryName => new WebDashboardPointDto { Label = categoryName, Value = cartCountByCategory.TryGetValue(categoryName, out var count) ? count : 0 })
            .ToList();

        return new WebDashboardDto
        {
            Cards =
            [
                new WebDashboardCardDto { Title = "Total Transactions", Value = requests.Count.ToString(), Trend = "This month" },
                new WebDashboardCardDto { Title = "Total Sales", Value = totalSales.ToString("0.00"), Trend = "This month" },
                new WebDashboardCardDto { Title = "Total Products", Value = products.Count.ToString(), Trend = "All" },
                new WebDashboardCardDto { Title = "Active Products", Value = products.Count(p => p.IsActive).ToString(), Trend = "Active" },
                new WebDashboardCardDto { Title = "Out of Stock Products", Value = products.Count(p => p.AvailableStock == 0).ToString(), Trend = "AvailableStock=0" },
                new WebDashboardCardDto { Title = "Gold Market Price", Value = goldAvg.ToString("0.00"), Trend = "Current" }
            ],
            StatusSegments =
            [
                new WebDashboardSegmentDto { Key = "pending", Label = "Pending", Value = statusCounts["pending"], Percent = (int)Math.Round((statusCounts["pending"] * 100m) / statusTotal) },
                new WebDashboardSegmentDto { Key = "approved", Label = "Approved", Value = statusCounts["approved"], Percent = (int)Math.Round((statusCounts["approved"] * 100m) / statusTotal) },
                new WebDashboardSegmentDto { Key = "rejected", Label = "Rejected", Value = statusCounts["rejected"], Percent = (int)Math.Round((statusCounts["rejected"] * 100m) / statusTotal) }
            ],
            CategorySegments = categoryCounts.Select(x => new WebDashboardSegmentDto { Key = x.Key, Label = x.Key, Value = x.Value, Percent = (int)Math.Round((x.Value * 100m) / categoryTotal) }).ToList(),
            CategoryTransactionSeries = categoryTransactionSeries,
            CategoryCartSeries = categoryCartSeries,
            RecentTransactions = recent
        };
    }
}
