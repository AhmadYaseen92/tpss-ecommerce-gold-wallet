using GoldWalletSystem.API.Models;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;

namespace GoldWalletSystem.API.Services;

public interface IWebAdminDashboardService
{
    Task<WebDashboardDto> BuildAsync(string period, int? sellerId = null, CancellationToken cancellationToken = default);
}

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

        var requestsQuery = dbContext.TransactionHistories.AsNoTracking().AsQueryable();
        if (sellerId.HasValue)
        {
            requestsQuery = requestsQuery.Where(x => x.SellerId == sellerId.Value);
        }
        requestsQuery = requestsQuery.Where(x => x.CreatedAtUtc >= monthStart);
        var requests = await requestsQuery.OrderByDescending(x => x.CreatedAtUtc).Take(100).ToListAsync(cancellationToken);

        var cartItemsQuery = dbContext.CartItems
            .AsNoTracking()
            .Include(x => x.Product)
            .Where(x => x.CreatedAtUtc >= monthStart)
            .AsQueryable();

        if (sellerId.HasValue)
        {
            cartItemsQuery = cartItemsQuery.Where(x => (x.SellerId ?? x.Product.SellerId) == sellerId.Value);
        }

        var cartItems = await cartItemsQuery.ToListAsync(cancellationToken);

        var totalSales = products.Sum(p => p.Price * p.AvailableStock);
        var goldAvg = products.Where(p => p.Category == ProductCategory.Gold).Select(p => p.Price).DefaultIfEmpty(0).Average();

        var statusCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
        {
            ["pending"] = requests.Count(x => ParseStatus(x.Reference) == "pending"),
            ["approved"] = requests.Count(x => ParseStatus(x.Reference) == "approved"),
            ["rejected"] = requests.Count(x => ParseStatus(x.Reference) == "rejected")
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
                InvestorName = investors.FirstOrDefault(i => i.Id == request.UserId)?.FullName ?? $"User {request.UserId}",
                ProductName = products.Count > 0 ? products[idx % products.Count].Name : "N/A",
                Type = request.TransactionType,
                Amount = request.Amount,
                Status = ParseStatus(request.Reference),
                CreatedAt = request.CreatedAtUtc
            })
            .ToList();

        var productSkuToCategory = products
            .GroupBy(x => x.Sku, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First().Category.ToString(), StringComparer.OrdinalIgnoreCase);

        var categoryTransactionSeries = requests
            .Where(request => ParseStatus(request.Reference) == "approved")
            .GroupBy(request =>
            {
                var sku = ExtractSku(request.Reference);
                if (!string.IsNullOrWhiteSpace(sku) && productSkuToCategory.TryGetValue(sku, out var mappedCategory))
                {
                    return mappedCategory;
                }

                return string.Empty;
            })
            .Where(group => !string.IsNullOrWhiteSpace(group.Key))
            .Select(group => new WebDashboardPointDto
            {
                Label = group.Key,
                Value = group.Count()
            })
            .OrderByDescending(x => x.Value)
            .ThenBy(x => x.Label)
            .ToList();

        var categoryCartSeries = cartItems
            .GroupBy(item => item.Product.Category.ToString())
            .Select(group => new WebDashboardPointDto
            {
                Label = group.Key,
                Value = group.Sum(x => x.Quantity)
            })
            .OrderByDescending(x => x.Value)
            .ThenBy(x => x.Label)
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
            CategorySegments = categoryCounts
                .Select(x => new WebDashboardSegmentDto
                {
                    Key = x.Key,
                    Label = x.Key,
                    Value = x.Value,
                    Percent = (int)Math.Round((x.Value * 100m) / categoryTotal)
                })
                .ToList(),
            CategoryTransactionSeries = categoryTransactionSeries,
            CategoryCartSeries = categoryCartSeries,
            RecentTransactions = recent
        };
    }

    public static string ParseStatus(string reference)
    {
        if (reference.Contains("status=approved", StringComparison.OrdinalIgnoreCase)) return "approved";
        if (reference.Contains("status=rejected", StringComparison.OrdinalIgnoreCase)) return "rejected";
        return "pending";
    }

    private static string? ExtractSku(string reference)
    {
        if (string.IsNullOrWhiteSpace(reference))
        {
            return null;
        }

        var match = Regex.Match(reference, @"SKU:([^|]+)", RegexOptions.IgnoreCase);
        return match.Success ? match.Groups[1].Value.Trim() : null;
    }
}
