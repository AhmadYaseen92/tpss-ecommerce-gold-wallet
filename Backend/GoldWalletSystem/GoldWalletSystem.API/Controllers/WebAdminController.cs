using System.Text.Json;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.API.Models;
using GoldWalletSystem.API.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/web-admin")]
public class WebAdminController(AppDbContext dbContext, IWebAdminDashboardService dashboardService) : ControllerBase
{
    private const string FeesConfigKey = "webadmin.fees";

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(CancellationToken cancellationToken)
    {
        var investorsCount = await dbContext.Users.CountAsync(x => x.Role == SystemRoles.Investor, cancellationToken);
        var pendingRequestsCount = await dbContext.TransactionHistories.CountAsync(x => x.Reference.Contains("status=pending"), cancellationToken);
        var invoicesCount = await dbContext.Invoices.CountAsync(cancellationToken);
        var unreadNotificationsCount = await dbContext.AppNotifications.CountAsync(x => !x.IsRead, cancellationToken);

        var summary = new WebSummaryDto
        {
            InvestorsCount = investorsCount,
            PendingRequestsCount = pendingRequestsCount,
            InvoicesCount = invoicesCount,
            UnreadNotificationsCount = unreadNotificationsCount
        };

        return Ok(ApiResponse<WebSummaryDto>.Ok(summary));
    }

    [HttpGet("sellers")]
    public async Task<IActionResult> GetSellers(CancellationToken cancellationToken)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : 0;

        var query = dbContext.Sellers.AsNoTracking();
        if (!User.IsInRole(SystemRoles.Admin))
        {
            query = query.Where(x => x.Id == currentSellerId);
        }

        var sellers = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new WebSellerDto
            {
                Id = $"s-{x.Id}",
                Name = x.Name,
                Email = x.Email,
                BusinessName = x.CompanyName,
                KycStatus = x.KycStatus.ToString().ToLowerInvariant(),
                SubmittedAt = x.CreatedAtUtc
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebSellerDto>>.Ok(sellers));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpPut("sellers/{id}/kyc-status")]
    public async Task<IActionResult> UpdateSellerKycStatus(string id, [FromBody] UpdateSellerKycRequest request, CancellationToken cancellationToken)
    {
        var sellerId = TryParsePrefixedId(id, "s-");
        if (sellerId is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        var seller = await dbContext.Sellers.FirstOrDefaultAsync(x => x.Id == sellerId, cancellationToken);
        if (seller is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        if (!Enum.TryParse<KycStatus>(request.Status, true, out var status))
            return BadRequest(ApiResponse<object>.Fail("Invalid KYC status", 400));

        seller.KycStatus = status;
        seller.ReviewNotes = request.ReviewNotes;
        seller.ReviewedAtUtc = DateTime.UtcNow;
        seller.UpdatedAtUtc = DateTime.UtcNow;
        seller.IsActive = status == KycStatus.Approved;

        var sellerUsers = await dbContext.Users
            .Where(x => x.SellerId == seller.Id && x.Role == SystemRoles.Seller)
            .ToListAsync(cancellationToken);

        foreach (var sellerUser in sellerUsers)
        {
            sellerUser.IsActive = status == KycStatus.Approved;
            sellerUser.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("investors")]
    public async Task<IActionResult> GetInvestors(CancellationToken cancellationToken)
    {
        var investors = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Role == SystemRoles.Investor)
            .Select(x => new WebInvestorDto
            {
                Id = $"i-{x.Id}",
                FullName = x.FullName,
                RiskLevel = "medium",
                WalletBalance = dbContext.Wallets.Where(w => w.UserId == x.Id).Select(w => w.CashBalance).FirstOrDefault(),
                Status = x.IsActive ? "active" : "blocked"
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebInvestorDto>>.Ok(investors));
    }

    [HttpPut("investors/{id}/status")]
    public async Task<IActionResult> UpdateInvestorStatus(string id, [FromBody] UpdateStatusRequest request, CancellationToken cancellationToken)
    {
        if (!int.TryParse(id.Replace("i-", string.Empty), out var userId))
            return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        var investor = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId && x.Role == SystemRoles.Investor, cancellationToken);
        if (investor is null) return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        investor.IsActive = !request.Status.Equals("blocked", StringComparison.OrdinalIgnoreCase);
        investor.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("requests")]
    public async Task<IActionResult> GetRequests(CancellationToken cancellationToken)
    {
        var requests = await dbContext.TransactionHistories
            .AsNoTracking()
            .OrderByDescending(x => x.CreatedAtUtc)
            .Take(100)
            .Select(x => new WebRequestDto
            {
                Id = $"r-{x.Id}",
                InvestorId = $"i-{x.UserId}",
                Type = x.TransactionType,
                Amount = x.Amount,
                Status = WebAdminDashboardService.ParseStatus(x.Reference),
                CreatedAt = x.CreatedAtUtc
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebRequestDto>>.Ok(requests));
    }

    [HttpPut("requests/{id}/status")]
    public async Task<IActionResult> UpdateRequestStatus(string id, [FromBody] UpdateStatusRequest request, CancellationToken cancellationToken)
    {
        if (!int.TryParse(id.Replace("r-", string.Empty), out var requestId))
            return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        var item = await dbContext.TransactionHistories.FirstOrDefaultAsync(x => x.Id == requestId, cancellationToken);
        if (item is null) return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        item.Reference = SetStatus(item.Reference, request.Status);
        item.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("invoices")]
    public async Task<IActionResult> GetInvoices(CancellationToken cancellationToken)
    {
        var invoices = await dbContext.Invoices
            .AsNoTracking()
            .OrderByDescending(x => x.IssuedOnUtc)
            .Select(x => new WebInvoiceDto
            {
                Id = $"inv-{x.Id}",
                SellerId = $"s-{x.SellerUserId}",
                InvestorName = dbContext.Users.Where(u => u.Id == x.InvestorUserId).Select(u => u.FullName).FirstOrDefault() ?? $"User {x.InvestorUserId}",
                TotalAmount = x.TotalAmount,
                IssuedAt = x.IssuedOnUtc,
                Status = x.Status
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebInvoiceDto>>.Ok(invoices));
    }

    [HttpPost("invoices")]
    public async Task<IActionResult> AddInvoice([FromBody] WebInvoiceDto request, CancellationToken cancellationToken)
    {
        var investorUserId = TryParsePrefixedId(request.InvestorName, "i-") ??
                             await dbContext.Users.Where(x => x.FullName == request.InvestorName).Select(x => (int?)x.Id).FirstOrDefaultAsync(cancellationToken) ??
                             await dbContext.Users.Where(x => x.Role == SystemRoles.Investor).Select(x => x.Id).FirstOrDefaultAsync(cancellationToken);

        var sellerUserId = TryParsePrefixedId(request.SellerId, "s-") ??
                           await dbContext.Users.Where(x => x.Role == SystemRoles.Seller).Select(x => (int?)x.Id).FirstOrDefaultAsync(cancellationToken) ?? 0;

        var entity = new Domain.Entities.Invoice
        {
            InvestorUserId = investorUserId,
            SellerUserId = sellerUserId,
            InvoiceNumber = string.IsNullOrWhiteSpace(request.Id) ? $"INV-{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}" : request.Id,
            InvoiceCategory = "Trade",
            SourceChannel = "WebAdmin",
            SubTotal = request.TotalAmount,
            TaxAmount = 0,
            TotalAmount = request.TotalAmount,
            InvoiceQrCode = string.Empty,
            IssuedOnUtc = request.IssuedAt == default ? DateTime.UtcNow : request.IssuedAt,
            Status = request.Status,
            CreatedAtUtc = DateTime.UtcNow
        };

        dbContext.Invoices.Add(entity);
        await dbContext.SaveChangesAsync(cancellationToken);

        request.Id = $"inv-{entity.Id}";
        return Ok(ApiResponse<WebInvoiceDto>.Ok(request));
    }

    [HttpPut("invoices/{id}")]
    public async Task<IActionResult> UpdateInvoice(string id, [FromBody] WebInvoiceDto request, CancellationToken cancellationToken)
    {
        var invoiceId = TryParsePrefixedId(id, "inv-");
        if (invoiceId is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));

        var invoice = await dbContext.Invoices.FirstOrDefaultAsync(x => x.Id == invoiceId, cancellationToken);
        if (invoice is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));

        invoice.TotalAmount = request.TotalAmount;
        invoice.SubTotal = request.TotalAmount;
        invoice.Status = request.Status;
        invoice.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpDelete("invoices/{id}")]
    public async Task<IActionResult> DeleteInvoice(string id, CancellationToken cancellationToken)
    {
        var invoiceId = TryParsePrefixedId(id, "inv-");
        if (invoiceId is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));

        var invoice = await dbContext.Invoices.FirstOrDefaultAsync(x => x.Id == invoiceId, cancellationToken);
        if (invoice is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));

        dbContext.Invoices.Remove(invoice);
        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("deleted"));
    }

    [HttpGet("fees")]
    public async Task<IActionResult> GetFees(CancellationToken cancellationToken)
    {
        var fees = await ReadFeesAsync(cancellationToken);
        return Ok(ApiResponse<WebFeesDto>.Ok(fees));
    }

    [HttpPut("fees")]
    public async Task<IActionResult> UpdateFees([FromBody] WebFeesDto request, CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.FirstOrDefaultAsync(x => x.ConfigKey == FeesConfigKey, cancellationToken);
        if (config is null)
        {
            config = new Domain.Entities.MobileAppConfiguration
            {
                ConfigKey = FeesConfigKey,
                JsonValue = JsonSerializer.Serialize(request),
                IsEnabled = true,
                Description = "Web admin fees configuration",
                CreatedAtUtc = DateTime.UtcNow
            };
            dbContext.MobileAppConfigurations.Add(config);
        }
        else
        {
            config.JsonValue = JsonSerializer.Serialize(request);
            config.IsEnabled = true;
            config.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<WebFeesDto>.Ok(request));
    }

    [HttpGet("notifications")]
    public async Task<IActionResult> GetNotifications(CancellationToken cancellationToken)
    {
        var notifications = await dbContext.AppNotifications
            .AsNoTracking()
            .OrderByDescending(x => x.CreatedAtUtc)
            .Take(50)
            .Select(x => new WebNotificationDto
            {
                Id = $"n-{x.Id}",
                Title = x.Title,
                Message = x.Body,
                Severity = "info",
                IsRead = x.IsRead,
                CreatedAt = x.CreatedAtUtc
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebNotificationDto>>.Ok(notifications));
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard([FromQuery] string period = "today", CancellationToken cancellationToken = default)
    {
        var dashboard = await dashboardService.BuildAsync(period, cancellationToken);
        return Ok(ApiResponse<WebDashboardDto>.Ok(dashboard));
    }

    [HttpPut("notifications/{id}/read")]
    public async Task<IActionResult> MarkNotificationAsRead(string id, CancellationToken cancellationToken)
    {
        var notificationId = TryParsePrefixedId(id, "n-");
        if (notificationId is null) return NotFound(ApiResponse<object>.Fail("Notification not found", 404));

        var item = await dbContext.AppNotifications.FirstOrDefaultAsync(x => x.Id == notificationId, cancellationToken);
        if (item is null) return NotFound(ApiResponse<object>.Fail("Notification not found", 404));

        item.IsRead = true;
        item.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("updated"));
    }

    private async Task<WebFeesDto> ReadFeesAsync(CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.ConfigKey == FeesConfigKey && x.IsEnabled, cancellationToken);

        if (config is null || string.IsNullOrWhiteSpace(config.JsonValue))
            return new WebFeesDto { DeliveryFee = 12, StorageFee = 4, ServiceChargePercent = 2.5m };

        return JsonSerializer.Deserialize<WebFeesDto>(config.JsonValue) ?? new WebFeesDto { DeliveryFee = 12, StorageFee = 4, ServiceChargePercent = 2.5m };
    }

    private static int? TryParsePrefixedId(string value, string prefix)
    {
        var clean = value.StartsWith(prefix, StringComparison.OrdinalIgnoreCase) ? value[prefix.Length..] : value;
        return int.TryParse(clean, out var id) ? id : null;
    }

    private static string SetStatus(string reference, string status)
    {
        var safeStatus = string.IsNullOrWhiteSpace(status) ? "pending" : status.Trim().ToLowerInvariant();
        var tokens = (reference ?? string.Empty)
            .Split('|', StringSplitOptions.RemoveEmptyEntries)
            .Where(x => !x.StartsWith("status=", StringComparison.OrdinalIgnoreCase))
            .ToList();
        tokens.Add($"status={safeStatus}");
        return string.Join('|', tokens);
    }
}
