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
public class WebAdminController(AppDbContext dbContext, IWebAdminDashboardService dashboardService, IMarketplaceRealtimeNotifier realtimeNotifier) : ControllerBase
{
    private const string FeesConfigKey = "webadmin.fees";
    private const string WalletSellConfigKey = "wallet.sell.execution";

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(CancellationToken cancellationToken)
    {
        var investorsCount = await dbContext.Users.CountAsync(x => x.Role == SystemRoles.Investor, cancellationToken);
        var pendingRequestsCount = await dbContext.TransactionHistories.CountAsync(x => x.Status == "pending", cancellationToken);
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
        await realtimeNotifier.BroadcastRefreshHintAsync($"investor-status:{userId}:{request.Status}", cancellationToken);

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("requests")]
    public async Task<IActionResult> GetRequests(CancellationToken cancellationToken)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : 0;

        var query = dbContext.TransactionHistories.AsNoTracking().AsQueryable();
        if (!User.IsInRole(SystemRoles.Admin))
        {
            query = query.Where(x => x.SellerId == currentSellerId);
        }

        var requests = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Take(100)
            .Join(
                dbContext.Users.AsNoTracking(),
                history => history.UserId,
                user => user.Id,
                (history, user) => new WebRequestDto
                {
                    Id = $"r-{history.Id}",
                    InvestorId = $"i-{history.UserId}",
                    InvestorName = user.FullName,
                    Type = history.TransactionType,
                    ProductName = history.Category,
                    Category = history.Category,
                    Quantity = history.Quantity,
                    UnitPrice = history.UnitPrice,
                    Weight = history.Weight,
                    Unit = history.Unit,
                    Purity = history.Purity,
                    Amount = history.Amount,
                    Status = history.Status,
                    Currency = history.Currency,
                    Notes = history.Notes,
                    CreatedAt = history.CreatedAtUtc,
                    UpdatedAt = history.UpdatedAtUtc
                })
            .ToListAsync(cancellationToken);

        await PopulateRequestProductNamesAsync(requests, cancellationToken);
        return Ok(ApiResponse<List<WebRequestDto>>.Ok(requests));
    }

    [HttpPut("requests/{id}/status")]
    public async Task<IActionResult> UpdateRequestStatus(string id, [FromBody] UpdateStatusRequest request, CancellationToken cancellationToken)
    {
        if (!int.TryParse(id.Replace("r-", string.Empty), out var requestId))
            return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        var item = await dbContext.TransactionHistories.FirstOrDefaultAsync(x => x.Id == requestId, cancellationToken);
        if (item is null) return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        if (!string.Equals(item.Status, "pending", StringComparison.OrdinalIgnoreCase))
            return BadRequest(ApiResponse<object>.Fail("Only pending requests can be changed.", 400));

        var nextStatus = request.Status.Trim().ToLowerInvariant();
        if (nextStatus != "approved" && nextStatus != "rejected")
            return BadRequest(ApiResponse<object>.Fail("Invalid status", 400));

        var previousStatus = item.Status;
        item.Status = nextStatus;
        item.UpdatedAtUtc = DateTime.UtcNow;

        if (previousStatus == "pending")
        {
            await ApplyRequestStockSideEffectsAsync(item, nextStatus, cancellationToken);

            if (nextStatus == "approved")
            {
                await ApplyApprovedRequestSideEffectsAsync(item, cancellationToken);
                await CreateInvoiceForApprovedRequestAsync(item, cancellationToken);
            }
        }

        dbContext.AuditLogs.Add(new Domain.Entities.AuditLog
        {
            UserId = item.UserId,
            Action = "RequestStatusUpdated",
            EntityName = "TransactionHistory",
            EntityId = item.Id,
            Details = $"Request {item.Id}: {previousStatus} -> {nextStatus}, type={item.TransactionType}, amount={item.Amount} {item.Currency}",
            CreatedAtUtc = DateTime.UtcNow
        });
        dbContext.AppNotifications.Add(new Domain.Entities.AppNotification
        {
            UserId = item.UserId,
            Title = "Request Status Updated",
            Body = $"Your {item.TransactionType} request was {nextStatus}.",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        });

        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"request-status:{requestId}:{nextStatus}", cancellationToken);

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("requests/{id}")]
    public async Task<IActionResult> GetRequestDetails(string id, CancellationToken cancellationToken)
    {
        if (!int.TryParse(id.Replace("r-", string.Empty), out var requestId))
            return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        var details = await dbContext.TransactionHistories
            .AsNoTracking()
            .Where(x => x.Id == requestId)
            .Join(
                dbContext.Users.AsNoTracking(),
                history => history.UserId,
                user => user.Id,
                (history, user) => new WebRequestDto
                {
                    Id = $"r-{history.Id}",
                    InvestorId = $"i-{history.UserId}",
                    InvestorName = user.FullName,
                    Type = history.TransactionType,
                    ProductName = history.Category,
                    Category = history.Category,
                    Quantity = history.Quantity,
                    UnitPrice = history.UnitPrice,
                    Weight = history.Weight,
                    Unit = history.Unit,
                    Purity = history.Purity,
                    Amount = history.Amount,
                    Status = history.Status,
                    Currency = history.Currency,
                    Notes = history.Notes,
                    CreatedAt = history.CreatedAtUtc,
                    UpdatedAt = history.UpdatedAtUtc
                })
            .FirstOrDefaultAsync(cancellationToken);

        if (details is null) return NotFound(ApiResponse<object>.Fail("Request not found", 404));
        await PopulateRequestProductNamesAsync([details], cancellationToken);
        return Ok(ApiResponse<WebRequestDto>.Ok(details));
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


    [Authorize(Roles = SystemRoles.Admin)]
    [HttpGet("wallet/sell-configuration")]
    public async Task<IActionResult> GetWalletSellConfiguration(CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.ConfigKey == WalletSellConfigKey && x.IsEnabled, cancellationToken);

        var payload = config?.JsonValue;
        if (string.IsNullOrWhiteSpace(payload))
        {
            payload = JsonSerializer.Serialize(new { mode = "locked_30_seconds", lockSeconds = 30 });
        }

        return Ok(ApiResponse<string>.Ok(payload));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpPut("wallet/sell-configuration")]
    public async Task<IActionResult> UpdateWalletSellConfiguration([FromBody] JsonElement request, CancellationToken cancellationToken)
    {
        var mode = request.TryGetProperty("mode", out var modeElement)
            ? (modeElement.GetString() ?? string.Empty).Trim().ToLowerInvariant()
            : string.Empty;

        if (mode is not ("locked_30_seconds" or "live_price"))
        {
            return BadRequest(ApiResponse<object>.Fail("mode must be locked_30_seconds or live_price", 400));
        }

        var lockSeconds = request.TryGetProperty("lockSeconds", out var lockElement)
            ? Math.Clamp(lockElement.GetInt32(), 5, 300)
            : 30;

        var payload = JsonSerializer.Serialize(new { mode, lockSeconds });

        var config = await dbContext.MobileAppConfigurations
            .FirstOrDefaultAsync(x => x.ConfigKey == WalletSellConfigKey, cancellationToken);

        if (config is null)
        {
            config = new Domain.Entities.MobileAppConfiguration
            {
                ConfigKey = WalletSellConfigKey,
                JsonValue = payload,
                IsEnabled = true,
                Description = "Wallet sell execution behavior",
                CreatedAtUtc = DateTime.UtcNow
            };
            dbContext.MobileAppConfigurations.Add(config);
        }
        else
        {
            config.JsonValue = payload;
            config.IsEnabled = true;
            config.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok(payload));
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
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : (int?)null;
        var scopedSellerId = User.IsInRole(SystemRoles.Admin) ? null : currentSellerId;
        var dashboard = await dashboardService.BuildAsync(period, scopedSellerId, cancellationToken);
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

    private async Task PopulateRequestProductNamesAsync(List<WebRequestDto> requests, CancellationToken cancellationToken)
    {
        if (requests.Count == 0) return;

        var requestIds = requests
            .Select(x => TryParsePrefixedId(x.Id, "r-"))
            .Where(x => x.HasValue)
            .Select(x => x!.Value)
            .ToList();
        if (requestIds.Count == 0) return;

        var histories = await dbContext.TransactionHistories
            .AsNoTracking()
            .Where(x => requestIds.Contains(x.Id))
            .Select(x => new { x.Id, x.SellerId, x.Notes, x.Category })
            .ToListAsync(cancellationToken);

        var skuByRequestId = histories
            .Select(x => new { x.Id, x.SellerId, Sku = TryExtractSku(x.Notes) })
            .Where(x => x.SellerId.HasValue && !string.IsNullOrWhiteSpace(x.Sku))
            .ToList();

        var sellerIds = skuByRequestId.Select(x => x.SellerId!.Value).Distinct().ToList();
        var skuValues = skuByRequestId.Select(x => x.Sku!).Distinct(StringComparer.OrdinalIgnoreCase).ToList();

        var products = await dbContext.Products
            .AsNoTracking()
            .Where(x => sellerIds.Contains(x.SellerId) && skuValues.Contains(x.Sku))
            .Select(x => new { x.SellerId, x.Sku, x.Name })
            .ToListAsync(cancellationToken);

        var productLookup = products.ToDictionary(x => (x.SellerId, x.Sku), x => x.Name);

        foreach (var request in requests)
        {
            var requestId = TryParsePrefixedId(request.Id, "r-");
            if (!requestId.HasValue) continue;

            var history = histories.FirstOrDefault(x => x.Id == requestId.Value);
            if (history is null)
            {
                request.ProductName = request.Category;
                continue;
            }

            var sku = TryExtractSku(history.Notes);
            if (history.SellerId.HasValue && !string.IsNullOrWhiteSpace(sku) && productLookup.TryGetValue((history.SellerId.Value, sku), out var productName))
            {
                request.ProductName = productName;
            }
            else
            {
                request.ProductName = history.Category;
            }
        }
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

    private async Task ApplyApprovedRequestSideEffectsAsync(Domain.Entities.TransactionHistory request, CancellationToken cancellationToken)
    {
        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        if (wallet is null)
        {
            wallet = new Domain.Entities.Wallet
            {
                UserId = request.UserId,
                CurrencyCode = request.Currency,
                CashBalance = 0,
                CreatedAtUtc = DateTime.UtcNow
            };
            dbContext.Wallets.Add(wallet);
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        var action = request.TransactionType.Trim().ToLowerInvariant();
        if (action == "buy")
        {
            wallet.Assets.Add(new Domain.Entities.WalletAsset
            {
                WalletId = wallet.Id,
                SellerId = request.SellerId,
                SellerName = await dbContext.Sellers.Where(s => s.Id == request.SellerId).Select(s => s.Name).FirstOrDefaultAsync(cancellationToken) ?? string.Empty,
                Category = Enum.TryParse<ProductCategory>(request.Category, true, out var cat) ? cat : ProductCategory.Gold,
                AssetType = AssetType.GoldBar,
                Quantity = Math.Max(1, request.Quantity),
                AverageBuyPrice = request.UnitPrice,
                CurrentMarketPrice = request.UnitPrice,
                Weight = request.Weight,
                Unit = request.Unit,
                Purity = request.Purity,
                CreatedAtUtc = DateTime.UtcNow
            });
        }
        else if (action is "sell" or "pickup" or "transfer" or "gift")
        {
            var asset = wallet.Assets.FirstOrDefault(x => x.SellerId == request.SellerId && x.Category.ToString().Equals(request.Category, StringComparison.OrdinalIgnoreCase));
            if (asset is not null)
            {
                var qtyToRemove = Math.Max(1, request.Quantity);
                asset.Quantity = Math.Max(asset.Quantity - qtyToRemove, 0);
                asset.Weight = Math.Max(asset.Weight - request.Weight, 0);
                asset.UpdatedAtUtc = DateTime.UtcNow;
                if (asset.Quantity == 0 && asset.Weight <= 0)
                {
                    dbContext.WalletAssets.Remove(asset);
                }
            }

            if (action is "sell" or "pickup")
            {
                wallet.CashBalance += request.Amount;
                wallet.UpdatedAtUtc = DateTime.UtcNow;
            }
        }
    }

    private async Task ApplyRequestStockSideEffectsAsync(
        Domain.Entities.TransactionHistory request,
        string nextStatus,
        CancellationToken cancellationToken)
    {
        if (request.SellerId is null || request.Quantity <= 0) return;

        var action = request.TransactionType.Trim().ToLowerInvariant();
        var categoryValue = request.Category.Trim();

        var productsQuery = dbContext.Products
            .Where(x => x.SellerId == request.SellerId && x.IsActive);

        var skuFromNotes = TryExtractSku(request.Notes);
        if (!string.IsNullOrWhiteSpace(skuFromNotes))
        {
            productsQuery = productsQuery.Where(x => x.Sku == skuFromNotes);
        }
        else if (Enum.TryParse<ProductCategory>(categoryValue, true, out var parsedCategory))
        {
            productsQuery = productsQuery.Where(x => x.Category == parsedCategory);
        }
        else
        {
            var categoryLower = categoryValue.ToLowerInvariant();
            productsQuery = productsQuery.Where(x => x.Category.ToString().ToLower().Contains(categoryLower));
        }

        var product = await productsQuery.OrderBy(x => x.Id).FirstOrDefaultAsync(cancellationToken);
        if (product is null) return;

        var quantity = Math.Max(1, request.Quantity);

        if (action == "buy")
        {
            if (nextStatus == "approved")
            {
                if (product.AvailableStock < quantity)
                {
                    throw new InvalidOperationException($"Insufficient stock for {product.Name}. Available {product.AvailableStock}, requested {quantity}.");
                }

                product.AvailableStock -= quantity;
            }
        }
        else if (action is "sell" or "pickup" or "transfer" or "gift")
        {
            if (nextStatus == "approved")
            {
                product.AvailableStock += quantity;
            }
        }

        product.UpdatedAtUtc = DateTime.UtcNow;
    }

    private static string? TryExtractSku(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;

        const string marker = "SKU=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;

        var tail = notes[valueStart..].Trim();
        if (tail.Length == 0) return null;

        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        return stopAt > 0 ? tail[..stopAt].Trim() : tail;
    }

    private async Task CreateInvoiceForApprovedRequestAsync(Domain.Entities.TransactionHistory request, CancellationToken cancellationToken)
    {
        var sellerUserId = await dbContext.Users
            .Where(x => x.Role == SystemRoles.Seller && x.SellerId == request.SellerId)
            .Select(x => (int?)x.Id)
            .FirstOrDefaultAsync(cancellationToken) ?? 0;

        dbContext.Invoices.Add(new Domain.Entities.Invoice
        {
            InvestorUserId = request.UserId,
            SellerUserId = sellerUserId,
            InvoiceNumber = $"INV-REQ-{request.Id}-{DateTime.UtcNow:yyyyMMddHHmmss}",
            InvoiceCategory = request.Category,
            SourceChannel = "RequestApproval",
            SubTotal = request.Amount,
            TaxAmount = 0,
            TotalAmount = request.Amount,
            InvoiceQrCode = string.Empty,
            IssuedOnUtc = DateTime.UtcNow,
            Status = "approved",
            CreatedAtUtc = DateTime.UtcNow
        });
    }
}
