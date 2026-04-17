using System.Text.Json;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Wallet;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/wallet")]
public class WalletController(
    IWalletService walletService,
    ICurrentUserService currentUser,
    AppDbContext dbContext,
    API.Services.IMarketplaceRealtimeNotifier realtimeNotifier) : SecuredControllerBase(currentUser)
{
    private const string SellExecutionConfigKey = "wallet.sell.execution";

    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await walletService.GetByUserIdAsync(request.UserId, cancellationToken);
        return Ok(ApiResponse<WalletDto>.Ok(data));
    }

    [HttpGet("actions/sell-configuration")]
    public async Task<IActionResult> GetSellConfiguration(CancellationToken cancellationToken = default)
    {
        var data = await ReadSellExecutionConfigurationAsync(cancellationToken);
        return Ok(ApiResponse<SellExecutionConfigurationResponse>.Ok(data));
    }

    [HttpGet("investors")]
    public async Task<IActionResult> GetInvestors([FromQuery] string? query = null, CancellationToken cancellationToken = default)
    {
        var investorsQuery = dbContext.Users
            .AsNoTracking()
            .Where(x => x.Role == "Investor" && x.IsActive);

        if (!string.IsNullOrWhiteSpace(query))
        {
            var term = query.Trim();
            investorsQuery = investorsQuery.Where(x =>
                x.FullName.Contains(term) ||
                x.Email.Contains(term) ||
                x.Id.ToString() == term);
        }

        var investors = await investorsQuery
            .OrderBy(x => x.FullName)
            .Take(50)
            .Select(x => new InvestorRecipientDto
            {
                InvestorUserId = x.Id,
                InvestorName = x.FullName,
                AccountNumber = x.Id.ToString()
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<InvestorRecipientDto>>.Ok(investors));
    }

    [HttpGet("investors/lookup")]
    public async Task<IActionResult> LookupInvestor([FromQuery] string accountNumber, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(accountNumber))
            return Ok(ApiResponse<InvestorRecipientDto?>.Ok(null));

        var investor = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Role == "Investor" && x.IsActive && x.Id.ToString() == accountNumber.Trim())
            .Select(x => new InvestorRecipientDto
            {
                InvestorUserId = x.Id,
                InvestorName = x.FullName,
                AccountNumber = x.Id.ToString()
            })
            .FirstOrDefaultAsync(cancellationToken);

        return Ok(ApiResponse<InvestorRecipientDto?>.Ok(investor));
    }

    [HttpPost("actions/execute")]
    public async Task<IActionResult> ExecuteWalletAction([FromBody] ExecuteWalletActionRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var actionType = request.ActionType.Trim().ToLowerInvariant();
        if (actionType is not ("sell" or "transfer" or "gift" or "pickup" or "certificate" or "invoice"))
            return BadRequest(ApiResponse<object>.Fail("Unsupported wallet action.", 400));

        if (request.Quantity <= 0)
            return BadRequest(ApiResponse<object>.Fail("Quantity must be greater than zero.", 400));

        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        if (wallet is null)
            return NotFound(ApiResponse<object>.Fail("Wallet not found.", 404));

        var asset = wallet.Assets.FirstOrDefault(x => x.Id == request.WalletAssetId);
        if (asset is null)
            return NotFound(ApiResponse<object>.Fail("Wallet asset not found.", 404));

        if (request.Quantity > asset.Quantity)
            return BadRequest(ApiResponse<object>.Fail("Quantity exceeds available holdings.", 400));

        var perUnitWeight = asset.Quantity == 0 ? 0 : asset.Weight / asset.Quantity;
        var requestedWeight = request.Weight > 0 ? request.Weight : perUnitWeight * request.Quantity;
        var maxWeightForRequestedQty = perUnitWeight > 0 ? perUnitWeight * request.Quantity : requestedWeight;
        if (maxWeightForRequestedQty > 0)
        {
            requestedWeight = Math.Min(requestedWeight, maxWeightForRequestedQty);
        }
        requestedWeight = Math.Min(requestedWeight, asset.Weight);
        if (requestedWeight <= 0)
            return BadRequest(ApiResponse<object>.Fail("Weight must be greater than zero.", 400));

        var unitPrice = request.UnitPrice > 0 ? request.UnitPrice : asset.CurrentMarketPrice;
        var grossAmount = request.Amount > 0 ? request.Amount : unitPrice * request.Quantity;

        var sellConfig = await ReadSellExecutionConfigurationAsync(cancellationToken);
        var executionMode = sellConfig.Mode;
        var lockUntilUtc = executionMode == "locked_30_seconds" ? DateTime.UtcNow.AddSeconds(Math.Max(5, sellConfig.LockSeconds)) : (DateTime?)null;

        if (actionType == "sell" && executionMode == "locked_30_seconds" && request.QuoteLockedUntilUtc is DateTime lockedUntil && lockedUntil < DateTime.UtcNow)
            return BadRequest(ApiResponse<object>.Fail("Locked sell quote expired. Please refresh and retry.", 400));

        var oldQty = asset.Quantity;
        var oldWeight = asset.Weight;
        var oldCash = wallet.CashBalance;

        var shouldRequireSellerApproval = actionType == "sell";
        var status = shouldRequireSellerApproval ? "pending" : "approved";

        string? recipientInvestorName = null;
        if (actionType is "transfer" or "gift")
        {
            if (request.RecipientInvestorUserId is null || request.RecipientInvestorUserId <= 0)
                return BadRequest(ApiResponse<object>.Fail("Recipient investor is required for transfer/gift.", 400));

            recipientInvestorName = await dbContext.Users
                .AsNoTracking()
                .Where(x => x.Id == request.RecipientInvestorUserId.Value && x.Role == "Investor" && x.IsActive)
                .Select(x => x.FullName)
                .FirstOrDefaultAsync(cancellationToken);

            if (string.IsNullOrWhiteSpace(recipientInvestorName))
                return BadRequest(ApiResponse<object>.Fail("Recipient investor account does not exist.", 400));
        }

        if (!shouldRequireSellerApproval && actionType is "sell" or "transfer" or "gift" or "pickup")
        {
            asset.Quantity = Math.Max(0, asset.Quantity - request.Quantity);
            asset.Weight = Math.Max(0, asset.Weight - requestedWeight);
            asset.UpdatedAtUtc = DateTime.UtcNow;

            if (asset.Quantity == 0 || asset.Weight <= 0)
            {
                dbContext.WalletAssets.Remove(asset);
            }
        }

        if (!shouldRequireSellerApproval && actionType is "transfer" or "gift" && request.RecipientInvestorUserId.HasValue)
        {
            var recipientWallet = await GetOrCreateWalletAsync(request.RecipientInvestorUserId.Value, wallet.CurrencyCode, cancellationToken);
            AddOrUpdateRecipientAsset(
                recipientWallet,
                asset,
                request.Quantity,
                requestedWeight,
                unitPrice);
            recipientWallet.UpdatedAtUtc = DateTime.UtcNow;

            var senderName = await dbContext.Users
                .Where(x => x.Id == request.UserId)
                .Select(x => x.FullName)
                .FirstOrDefaultAsync(cancellationToken) ?? $"Investor {request.UserId}";

            dbContext.TransactionHistories.Add(new TransactionHistory
            {
                UserId = request.RecipientInvestorUserId.Value,
                SellerId = asset.SellerId,
                TransactionType = actionType,
                Status = status,
                Category = asset.Category.ToString(),
                Quantity = request.Quantity,
                UnitPrice = unitPrice,
                Weight = requestedWeight,
                Unit = asset.Unit,
                Purity = asset.Purity,
                Amount = grossAmount,
                Currency = recipientWallet.CurrencyCode,
                Notes = $"direction=received|from_investor_user_id={request.UserId}|from_investor_name={senderName}|{BuildNotes(request, executionMode)}",
                CreatedAtUtc = DateTime.UtcNow
            });

            dbContext.AppNotifications.Add(new AppNotification
            {
                UserId = request.RecipientInvestorUserId.Value,
                Title = actionType == "gift" ? "Gift received" : "Transfer received",
                Body = $"{request.Quantity} unit(s) received from {senderName}.",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        if (!shouldRequireSellerApproval && actionType is "sell")
        {
            wallet.CashBalance += grossAmount;
        }

        wallet.UpdatedAtUtc = DateTime.UtcNow;

        var history = new TransactionHistory
        {
            UserId = request.UserId,
            SellerId = asset.SellerId,
            TransactionType = actionType,
            Status = status,
            Category = asset.Category.ToString(),
            Quantity = request.Quantity,
            UnitPrice = unitPrice,
            Weight = requestedWeight,
            Unit = asset.Unit,
            Purity = asset.Purity,
            Amount = grossAmount,
            Currency = wallet.CurrencyCode,
            Notes = BuildNotes(request, executionMode, recipientInvestorName),
            CreatedAtUtc = DateTime.UtcNow
        };
        dbContext.TransactionHistories.Add(history);

        if (!shouldRequireSellerApproval && actionType is "certificate" or "invoice" or "sell" or "pickup")
        {
            var sellerUserId = await dbContext.Users
                .Where(x => x.Role == "Seller" && x.SellerId == asset.SellerId)
                .Select(x => (int?)x.Id)
                .FirstOrDefaultAsync(cancellationToken) ?? 0;

            dbContext.Invoices.Add(new Invoice
            {
                InvestorUserId = request.UserId,
                SellerUserId = sellerUserId,
                InvoiceNumber = $"INV-WAL-{DateTime.UtcNow:yyyyMMddHHmmssfff}",
                InvoiceCategory = actionType,
                SourceChannel = "MobileWallet",
                SubTotal = grossAmount,
                TaxAmount = 0,
                TotalAmount = grossAmount,
                InvoiceQrCode = string.Empty,
                IssuedOnUtc = DateTime.UtcNow,
                Status = status,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        dbContext.AuditLogs.Add(new AuditLog
        {
            UserId = request.UserId,
            Action = shouldRequireSellerApproval ? "WalletActionRequested" : "WalletActionExecuted",
            EntityName = nameof(WalletAsset),
            EntityId = request.WalletAssetId,
            Details = $"action={actionType}, status={status}, qty={oldQty}->{Math.Max(oldQty - request.Quantity, 0)}, weight={oldWeight}->{Math.Max(oldWeight - requestedWeight, 0)}, cash={oldCash}->{wallet.CashBalance}",
            CreatedAtUtc = DateTime.UtcNow
        });

        dbContext.AppNotifications.Add(new AppNotification
        {
            UserId = request.UserId,
            Title = shouldRequireSellerApproval ? "Wallet action submitted" : "Wallet action completed",
            Body = shouldRequireSellerApproval
                ? $"{actionType} request submitted and pending seller approval."
                : $"{actionType} completed for {request.Quantity} unit(s).",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        });

        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"wallet-action:{actionType}:{request.UserId}", cancellationToken);
        if (!shouldRequireSellerApproval && actionType is "transfer" or "gift" && request.RecipientInvestorUserId.HasValue)
        {
            await realtimeNotifier.BroadcastRefreshHintAsync(
                $"wallet-action:{actionType}:{request.RecipientInvestorUserId.Value}",
                cancellationToken);
        }

        var portfolioValue = await dbContext.WalletAssets
            .Where(x => x.WalletId == wallet.Id)
            .Select(x => (decimal?)(x.CurrentMarketPrice * x.Quantity))
            .SumAsync(cancellationToken) ?? 0m;

        return Ok(ApiResponse<ExecuteWalletActionResponse>.Ok(new ExecuteWalletActionResponse
        {
            ReferenceId = $"wtx-{history.Id}",
            Status = status,
            LockedPriceUntilUtc = lockUntilUtc,
            CashBalance = wallet.CashBalance,
            TotalPortfolioValue = portfolioValue,
            Message = shouldRequireSellerApproval ? "Sell request submitted and pending seller approval." : "Wallet action processed successfully."
        }));
    }

    [HttpPost("actions/request")]
    public async Task<IActionResult> CreateWalletActionRequest([FromBody] WalletActionRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var wallet = await dbContext.Wallets
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        var entity = new TransactionHistory
        {
            UserId = request.UserId,
            SellerId = request.SellerId,
            TransactionType = request.ActionType.Trim().ToLowerInvariant(),
            Status = "pending",
            Category = request.Category,
            Quantity = Math.Max(1, request.Quantity),
            UnitPrice = request.UnitPrice,
            Weight = request.Weight,
            Unit = string.IsNullOrWhiteSpace(request.Unit) ? "gram" : request.Unit,
            Purity = request.Purity,
            Amount = request.Amount,
            Currency = wallet?.CurrencyCode ?? "USD",
            Notes = request.Notes ?? "Mobile wallet action request",
            CreatedAtUtc = DateTime.UtcNow
        };

        dbContext.TransactionHistories.Add(entity);
        dbContext.AuditLogs.Add(new AuditLog
        {
            UserId = request.UserId,
            Action = "WalletActionRequested",
            EntityName = "TransactionHistory",
            Details = $"Action={entity.TransactionType}, amount={entity.Amount}, qty={entity.Quantity}, category={entity.Category}",
            CreatedAtUtc = DateTime.UtcNow
        });
        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"wallet-request:{entity.TransactionType}:{request.UserId}", cancellationToken);

        return Ok(ApiResponse<object>.Ok(new { id = $"r-{entity.Id}", status = entity.Status }, "Request submitted"));
    }

    private static string BuildNotes(ExecuteWalletActionRequest request, string executionMode, string? recipientInvestorName = null)
    {
        var meta = $"execution_mode={executionMode}|wallet_asset_id={request.WalletAssetId}";
        if (request.RecipientInvestorUserId.HasValue)
        {
            meta = $"{meta}|recipient_investor_user_id={request.RecipientInvestorUserId.Value}";
            if (!string.IsNullOrWhiteSpace(recipientInvestorName))
            {
                meta = $"{meta}|recipient_investor_name={recipientInvestorName}";
            }
        }
        return string.IsNullOrWhiteSpace(request.Notes)
            ? meta
            : $"{request.Notes.Trim()} | {meta}";
    }

    private async Task<Wallet> GetOrCreateWalletAsync(int userId, string currencyCode, CancellationToken cancellationToken)
    {
        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

        if (wallet is not null) return wallet;

        wallet = new Wallet
        {
            UserId = userId,
            CurrencyCode = string.IsNullOrWhiteSpace(currencyCode) ? "USD" : currencyCode,
            CashBalance = 0,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        dbContext.Wallets.Add(wallet);
        return wallet;
    }

    private static void AddOrUpdateRecipientAsset(
        Wallet recipientWallet,
        WalletAsset sourceAsset,
        int quantity,
        decimal weight,
        decimal unitPrice)
    {
        var qtyToAdd = Math.Max(1, quantity);
        var weightToAdd = Math.Max(0.001m, weight);

        var existing = recipientWallet.Assets.FirstOrDefault(x =>
            x.SellerId == sourceAsset.SellerId &&
            x.Category == sourceAsset.Category &&
            x.Unit == sourceAsset.Unit &&
            x.Purity == sourceAsset.Purity);

        if (existing is null)
        {
            recipientWallet.Assets.Add(new WalletAsset
            {
                SellerId = sourceAsset.SellerId,
                SellerName = sourceAsset.SellerName,
                Category = sourceAsset.Category,
                AssetType = sourceAsset.AssetType,
                Quantity = qtyToAdd,
                Weight = weightToAdd,
                Unit = sourceAsset.Unit,
                Purity = sourceAsset.Purity,
                AverageBuyPrice = unitPrice,
                CurrentMarketPrice = sourceAsset.CurrentMarketPrice > 0 ? sourceAsset.CurrentMarketPrice : unitPrice,
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            });
            return;
        }

        var newTotalQty = existing.Quantity + qtyToAdd;
        existing.AverageBuyPrice = newTotalQty <= 0
            ? existing.AverageBuyPrice
            : ((existing.AverageBuyPrice * existing.Quantity) + (unitPrice * qtyToAdd)) / newTotalQty;
        existing.Quantity = newTotalQty;
        existing.Weight += weightToAdd;
        existing.CurrentMarketPrice = sourceAsset.CurrentMarketPrice > 0 ? sourceAsset.CurrentMarketPrice : unitPrice;
        existing.UpdatedAtUtc = DateTime.UtcNow;
    }

    private async Task<SellExecutionConfigurationResponse> ReadSellExecutionConfigurationAsync(CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.ConfigKey == SellExecutionConfigKey && x.IsEnabled, cancellationToken);

        if (config is null || string.IsNullOrWhiteSpace(config.JsonValue))
        {
            return new SellExecutionConfigurationResponse { Mode = "locked_30_seconds", LockSeconds = 30 };
        }

        return JsonSerializer.Deserialize<SellExecutionConfigurationResponse>(config.JsonValue)
               ?? new SellExecutionConfigurationResponse { Mode = "locked_30_seconds", LockSeconds = 30 };
    }

    public sealed class WalletActionRequest
    {
        public int UserId { get; set; }
        public int? SellerId { get; set; }
        public string ActionType { get; set; } = "sell";
        public string Category { get; set; } = "Gold";
        public int Quantity { get; set; } = 1;
        public decimal UnitPrice { get; set; }
        public decimal Weight { get; set; }
        public string Unit { get; set; } = "gram";
        public decimal Purity { get; set; }
        public decimal Amount { get; set; }
        public string? Notes { get; set; }
    }

    public sealed class ExecuteWalletActionRequest
    {
        public int UserId { get; set; }
        public int WalletAssetId { get; set; }
        public string ActionType { get; set; } = "sell";
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Weight { get; set; }
        public decimal Amount { get; set; }
        public int? RecipientInvestorUserId { get; set; }
        public string? Notes { get; set; }
        public DateTime? QuoteLockedUntilUtc { get; set; }
    }

    public sealed class InvestorRecipientDto
    {
        public int InvestorUserId { get; set; }
        public string InvestorName { get; set; } = string.Empty;
        public string AccountNumber { get; set; } = string.Empty;
    }

    public sealed class ExecuteWalletActionResponse
    {
        public string ReferenceId { get; set; } = string.Empty;
        public string Status { get; set; } = "approved";
        public DateTime? LockedPriceUntilUtc { get; set; }
        public decimal CashBalance { get; set; }
        public decimal TotalPortfolioValue { get; set; }
        public string Message { get; set; } = string.Empty;
    }

    public sealed class SellExecutionConfigurationResponse
    {
        public string Mode { get; set; } = "locked_30_seconds";
        public int LockSeconds { get; set; } = 30;
    }
}
