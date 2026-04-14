using GoldWalletSystem.API.Models;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Services;

public interface IWebAdminDashboardService
{
    Task<WebDashboardDto> BuildAsync(string period, IReadOnlyList<WebRequestDto> requests, IReadOnlyList<WebInvestorDto> investors, CancellationToken cancellationToken = default);
}

public class WebAdminDashboardService(AppDbContext dbContext) : IWebAdminDashboardService
{
    public async Task<WebDashboardDto> BuildAsync(string period, IReadOnlyList<WebRequestDto> requests, IReadOnlyList<WebInvestorDto> investors, CancellationToken cancellationToken = default)
    {
        var products = await dbContext.Products.AsNoTracking().ToListAsync(cancellationToken);
        var totalSales = products.Sum(p => p.Price * p.AvailableStock);
        var goldAvg = products.Where(p => p.Category == ProductCategory.Gold).Select(p => p.Price).DefaultIfEmpty(0).Average();

        var statusCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
        {
            ["pending"] = requests.Count(x => x.Status.Equals("pending", StringComparison.OrdinalIgnoreCase)),
            ["approved"] = requests.Count(x => x.Status.Equals("approved", StringComparison.OrdinalIgnoreCase)),
            ["rejected"] = requests.Count(x => x.Status.Equals("rejected", StringComparison.OrdinalIgnoreCase))
        };

        var statusTotal = Math.Max(statusCounts.Values.Sum(), 1);

        var categoryCounts = products
            .GroupBy(p => p.Category.ToString())
            .Select(g => new { Key = g.Key, Value = g.Count() })
            .OrderByDescending(x => x.Value)
            .ToList();
        var categoryTotal = Math.Max(categoryCounts.Sum(x => x.Value), 1);

        var recent = requests
            .OrderByDescending(x => x.CreatedAt)
            .Take(6)
            .Select((request, idx) => new WebRecentTransactionDto
            {
                Id = request.Id,
                InvestorName = investors.FirstOrDefault(i => i.Id == request.InvestorId)?.FullName ?? request.InvestorId,
                ProductName = products.Count > 0 ? products[idx % products.Count].Name : "N/A",
                Type = request.Type,
                Amount = request.Amount,
                Status = request.Status,
                CreatedAt = request.CreatedAt
            })
            .ToList();

        return new WebDashboardDto
        {
            Cards =
            [
                new WebDashboardCardDto { Title = "Total Transactions", Value = requests.Count.ToString(), Trend = $"{period} period" },
                new WebDashboardCardDto { Title = "Total Sales", Value = totalSales.ToString("0.00"), Trend = $"{period} period" },
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
            RecentTransactions = recent
        };
    }
}
