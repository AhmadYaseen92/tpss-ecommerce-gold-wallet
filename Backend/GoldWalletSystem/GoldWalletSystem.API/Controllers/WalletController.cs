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
using System.Text;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/wallet")]
public class WalletController(
    IWalletService walletService,
    IWalletActionValidationService walletActionValidationService,
    ICurrentUserService currentUser,
    AppDbContext dbContext,
    IWebHostEnvironment environment,
    API.Services.IMarketplaceRealtimeNotifier realtimeNotifier) : SecuredControllerBase(currentUser)
{
    private const string SellExecutionConfigKey = "wallet.sell.execution";

    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await walletService.GetByUserIdAsync(request.UserId, cancellationToken);

        var assetIds = data.Assets.Select(x => x.Id).ToList();
        var invoiceByWalletAsset = new Dictionary<int, (int InvoiceId, string? PdfUrl, string? ProductName, int? FromPartyUserId, string? FromPartyType)>();
        if (assetIds.Count > 0)
        {
            var linkedInvoices = await dbContext.Invoices
                .AsNoTracking()
                .Where(x => x.InvestorUserId == request.UserId && x.WalletItemId.HasValue && assetIds.Contains(x.WalletItemId.Value))
                .OrderByDescending(x => x.IssuedOnUtc)
                .Select(x => new { x.WalletItemId, x.Id, x.PdfUrl, x.ProductName, x.FromPartyUserId, x.FromPartyType })
                .ToListAsync(cancellationToken);

            invoiceByWalletAsset = linkedInvoices
                .Where(x => x.WalletItemId.HasValue)
                .GroupBy(x => x.WalletItemId!.Value)
                .ToDictionary(
                    g => g.Key,
                    g => (
                        g.First().Id,
                        g.First().PdfUrl,
                        g.First().ProductName,
                        g.First().FromPartyUserId,
                        g.First().FromPartyType));
        }

        var sourceInvestorNames = new Dictionary<int, string>();
        var sourceInvestorIds = invoiceByWalletAsset.Values
            .Where(x => string.Equals(x.FromPartyType, "Investor", StringComparison.OrdinalIgnoreCase) && x.FromPartyUserId.HasValue)
            .Select(x => x.FromPartyUserId!.Value)
            .Distinct()
            .ToList();
        if (sourceInvestorIds.Count > 0)
        {
            sourceInvestorNames = await dbContext.Users
                .AsNoTracking()
                .Where(x => sourceInvestorIds.Contains(x.Id))
                .ToDictionaryAsync(x => x.Id, x => x.FullName, cancellationToken);
        }

        var walletAssetProductMeta = await ResolveWalletAssetProductMetaAsync(request.UserId, assetIds, cancellationToken);

        var (statusByAssetId, detailsByAssetId) = await ResolveAssetStatusesAsync(request.UserId, data.Assets, cancellationToken);
        var assets = data.Assets
            .Select(asset =>
            {
                var status = statusByAssetId.TryGetValue(asset.Id, out var resolvedStatus)
                    ? resolvedStatus
                    : "Bought";
                var statusDetails = detailsByAssetId.TryGetValue(asset.Id, out var resolvedDetails)
                    ? resolvedDetails
                    : null;
                var invoiceMeta = invoiceByWalletAsset.TryGetValue(asset.Id, out var resolvedInvoice)
                    ? resolvedInvoice
                    : (InvoiceId: 0, PdfUrl: (string?)null, ProductName: (string?)null, FromPartyUserId: (int?)null, FromPartyType: (string?)null);
                var sourceInvestorName = invoiceMeta.FromPartyUserId.HasValue &&
                                         sourceInvestorNames.TryGetValue(invoiceMeta.FromPartyUserId.Value, out var investorName)
                    ? investorName
                    : null;
                var resolvedDetailsWithFallback = statusDetails;
                if (string.IsNullOrWhiteSpace(resolvedDetailsWithFallback) &&
                    !string.IsNullOrWhiteSpace(sourceInvestorName) &&
                    (status.Contains("Gift", StringComparison.OrdinalIgnoreCase) ||
                     status.Contains("Transfer", StringComparison.OrdinalIgnoreCase)))
                {
                    resolvedDetailsWithFallback = status.Contains("Gift", StringComparison.OrdinalIgnoreCase)
                        ? $"Received as Gift from {sourceInvestorName}"
                        : $"Received as Transfer from {sourceInvestorName}";
                }
                return asset with
                {
                    Status = status,
                    IsDelivered = status == "Delivered",
                    StatusDetails = resolvedDetailsWithFallback,
                    InvoiceId = invoiceMeta.InvoiceId == 0 ? null : invoiceMeta.InvoiceId,
                    CertificateUrl = ToAbsoluteFileUrl(invoiceMeta.PdfUrl),
                    ProductName = string.IsNullOrWhiteSpace(invoiceMeta.ProductName)
                        ? walletAssetProductMeta.TryGetValue(asset.Id, out var productMeta) ? productMeta.ProductName : asset.ProductName
                        : invoiceMeta.ProductName,
                    ProductSku = walletAssetProductMeta.TryGetValue(asset.Id, out var meta) ? meta.ProductSku : asset.ProductSku,
                    SourceInvestorName = sourceInvestorName
                };
            })
            .ToList();
        return Ok(ApiResponse<WalletDto>.Ok(data with { Assets = assets }));
    }

    [HttpGet("actions/sell-configuration")]
    public async Task<IActionResult> GetSellConfiguration(CancellationToken cancellationToken = default)
    {
        var data = await ReadSellExecutionConfigurationAsync(cancellationToken);
        return Ok(ApiResponse<SellExecutionConfigurationResponse>.Ok(data));
    }

    [HttpGet("wallet-items/{walletItemId:int}/certificate")]
    public async Task<IActionResult> EnsureWalletItemCertificate(int walletItemId, CancellationToken cancellationToken = default)
    {
        var currentUserId = currentUser.UserId;
        if (!currentUserId.HasValue) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));

        var invoice = await dbContext.Invoices
            .Where(x => x.WalletItemId == walletItemId && x.InvestorUserId == currentUserId.Value)
            .OrderByDescending(x => x.IssuedOnUtc)
            .FirstOrDefaultAsync(cancellationToken);

        if (invoice is null)
        {
            invoice = await dbContext.Invoices
                .Where(x => x.InvestorUserId == currentUserId.Value && x.RelatedTransactionId.HasValue)
                .Join(
                    dbContext.TransactionHistories.AsNoTracking(),
                    inv => inv.RelatedTransactionId!.Value,
                    history => history.Id,
                    (inv, history) => new { Invoice = inv, history.WalletItemId })
                .Where(x => x.WalletItemId == walletItemId)
                .OrderByDescending(x => x.Invoice.IssuedOnUtc)
                .Select(x => x.Invoice)
                .FirstOrDefaultAsync(cancellationToken);
        }

        if (invoice is null)
            return NotFound(ApiResponse<object>.Fail("No invoice/certificate record exists for this wallet item.", 404));

        if (!invoice.WalletItemId.HasValue && invoice.RelatedTransactionId.HasValue)
        {
            invoice.WalletItemId = walletItemId;
            invoice.UpdatedAtUtc = DateTime.UtcNow;
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        var pdfUrl = invoice.PdfUrl;
        var fileExists = !string.IsNullOrWhiteSpace(pdfUrl) && InvoiceFileExists(pdfUrl);
        if (!fileExists)
        {
            var walletAsset = await dbContext.WalletAssets
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == walletItemId, cancellationToken);

            var fallbackAsset = walletAsset ?? new WalletAsset
            {
                Id = walletItemId,
                SellerId = null,
                Category = ParseProductCategory(invoice.InvoiceCategory),
                Weight = invoice.Weight > 0 ? invoice.Weight : 0.001m,
                Unit = "gram",
                Purity = invoice.Purity,
                Quantity = invoice.Quantity > 0 ? invoice.Quantity : 1,
                AverageBuyPrice = invoice.UnitPrice,
                CurrentMarketPrice = invoice.UnitPrice,
                SellerName = string.IsNullOrWhiteSpace(invoice.FromPartyType) ? "Wallet" : invoice.FromPartyType
            };

            pdfUrl = await SaveInvoiceDocumentAsync(
                investorUserId: invoice.InvestorUserId,
                actionType: invoice.InvoiceCategory,
                asset: fallbackAsset,
                quantity: Math.Max(1, invoice.Quantity),
                amount: invoice.TotalAmount > 0 ? invoice.TotalAmount : invoice.SubTotal,
                cancellationToken);

            invoice.PdfUrl = pdfUrl;
            invoice.InvoiceQrCode = pdfUrl ?? invoice.InvoiceQrCode;
            invoice.UpdatedAtUtc = DateTime.UtcNow;
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        return Ok(ApiResponse<EnsureWalletItemCertificateResponse>.Ok(new EnsureWalletItemCertificateResponse
        {
            InvoiceId = invoice.Id,
            InvoiceNumber = invoice.InvoiceNumber,
            PdfUrl = ToAbsoluteFileUrl(invoice.PdfUrl)
        }));
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

        var validationError = walletActionValidationService.ValidateExecuteActionRequest(actionType, request.Notes);
        if (!string.IsNullOrWhiteSpace(validationError))
            return BadRequest(ApiResponse<object>.Fail(validationError, 400));

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

        var shouldRequireSellerApproval = actionType is "sell" or "pickup";
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

        if (!shouldRequireSellerApproval && actionType is "sell" or "transfer" or "gift")
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
            WalletItemId = asset.Id,
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

        string? invoiceUrl = null;
        Invoice? createdInvoice = null;
        if (!shouldRequireSellerApproval && actionType is "certificate" or "invoice" or "sell" or "transfer" or "gift" or "pickup")
        {
            var sellerUserId = await dbContext.Users
                .Where(x => x.Role == "Seller" && x.SellerId == asset.SellerId)
                .Select(x => (int?)x.Id)
                .FirstOrDefaultAsync(cancellationToken) ?? 0;

            invoiceUrl = await SaveInvoiceDocumentAsync(
                investorUserId: request.UserId,
                actionType: actionType,
                asset,
                quantity: request.Quantity,
                amount: grossAmount,
                cancellationToken);

            createdInvoice = new Invoice
            {
                InvestorUserId = request.UserId,
                SellerUserId = sellerUserId,
                InvoiceNumber = $"INV-WAL-{DateTime.UtcNow:yyyyMMddHHmmssfff}",
                InvoiceCategory = NormalizeInvoiceCategory(actionType),
                SourceChannel = "MobileWallet",
                ExternalReference = $"WALLET-TX-{history.Id}",
                SubTotal = grossAmount,
                FeesAmount = 0,
                DiscountAmount = 0,
                TaxAmount = 0,
                TotalAmount = grossAmount,
                Currency = wallet.CurrencyCode,
                PaymentMethod = actionType is "sell" ? "WalletCredit" : "N/A",
                PaymentStatus = actionType is "sell" ? "Paid" : "Pending",
                PaymentTransactionId = null,
                WalletItemId = asset.Id,
                ProductName = asset.Category.ToString(),
                Quantity = request.Quantity,
                UnitPrice = unitPrice,
                Weight = requestedWeight,
                Purity = asset.Purity,
                FromPartyType = "Investor",
                ToPartyType = actionType is "transfer" or "gift" ? "Investor" : "Seller",
                FromPartyUserId = request.UserId,
                ToPartyUserId = actionType is "transfer" or "gift" ? request.RecipientInvestorUserId : sellerUserId,
                OwnershipEffectiveOnUtc = DateTime.UtcNow,
                InvoiceQrCode = invoiceUrl ?? string.Empty,
                PdfUrl = invoiceUrl,
                IssuedOnUtc = DateTime.UtcNow,
                PaidOnUtc = actionType is "sell" ? DateTime.UtcNow : null,
                Status = actionType is "sell" ? "Completed" : "Issued",
                CreatedAtUtc = DateTime.UtcNow
            };
            dbContext.Invoices.Add(createdInvoice);

            dbContext.AppNotifications.Add(new AppNotification
            {
                UserId = request.UserId,
                Title = "Invoice created",
                Body = $"Invoice {createdInvoice.InvoiceNumber} is now available.",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });

            if (actionType is "sell")
            {
                dbContext.AppNotifications.Add(new AppNotification
                {
                    UserId = request.UserId,
                    Title = "Invoice paid",
                    Body = $"Invoice {createdInvoice.InvoiceNumber} has been paid.",
                    IsRead = false,
                    CreatedAtUtc = DateTime.UtcNow
                });
            }

            dbContext.AppNotifications.Add(new AppNotification
            {
                UserId = request.UserId,
                Title = "Invoice PDF available",
                Body = $"Invoice {createdInvoice.InvoiceNumber} PDF is ready to view or download.",
                IsRead = false,
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

        if (createdInvoice is not null)
        {
            history.InvoiceId = createdInvoice.Id;
            history.UpdatedAtUtc = DateTime.UtcNow;
            createdInvoice.RelatedTransactionId = history.Id;
            createdInvoice.UpdatedAtUtc = DateTime.UtcNow;
            await dbContext.SaveChangesAsync(cancellationToken);
        }
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
            Message = shouldRequireSellerApproval
                ? $"{actionType} request submitted and pending seller approval."
                : "Wallet action processed successfully.",
            InvoiceUrl = invoiceUrl,
            InvoiceId = createdInvoice?.Id
        }));
    }

    [HttpPost("actions/cancel-request")]
    public async Task<IActionResult> CancelPendingRequest([FromBody] CancelWalletRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var history = await dbContext.TransactionHistories
            .OrderByDescending(x => x.CreatedAtUtc)
            .FirstOrDefaultAsync(x =>
                x.UserId == request.UserId &&
                string.Equals(x.Status, "pending", StringComparison.OrdinalIgnoreCase) &&
                (x.WalletItemId == request.WalletAssetId || TryExtractWalletAssetId(x.Notes) == request.WalletAssetId),
                cancellationToken);

        if (history is null)
            return NotFound(ApiResponse<object>.Fail("No pending request found for this wallet item.", 404));

        history.Status = "cancelled";
        history.UpdatedAtUtc = DateTime.UtcNow;
        history.Notes = string.IsNullOrWhiteSpace(history.Notes)
            ? $"wallet_asset_id={request.WalletAssetId}|cancelled_by_user={request.UserId}"
            : $"{history.Notes} | cancelled_by_user={request.UserId}";

        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"wallet-request-cancelled:{request.UserId}:{request.WalletAssetId}", cancellationToken);

        return Ok(ApiResponse<CancelWalletRequestResponse>.Ok(new CancelWalletRequestResponse
        {
            WalletAssetId = request.WalletAssetId,
            Status = "cancelled"
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

    private async Task<Dictionary<int, (string ProductName, string ProductSku)>> ResolveWalletAssetProductMetaAsync(
        int userId,
        IReadOnlyList<int> assetIds,
        CancellationToken cancellationToken)
    {
        if (assetIds.Count == 0) return new Dictionary<int, (string ProductName, string ProductSku)>();

        var histories = await dbContext.TransactionHistories
            .AsNoTracking()
            .Where(x => x.UserId == userId && (x.WalletItemId.HasValue || EF.Functions.Like(x.Notes, "%wallet_asset_id=%")))
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new { x.WalletItemId, x.Notes, x.SellerId, x.Category })
            .ToListAsync(cancellationToken);

        var sellerIds = histories
            .Where(x => x.SellerId.HasValue)
            .Select(x => x.SellerId!.Value)
            .Distinct()
            .ToList();

        var products = sellerIds.Count == 0
            ? []
            : await dbContext.Products
                .AsNoTracking()
                .Where(x => sellerIds.Contains(x.SellerId))
                .Select(x => new { x.SellerId, x.Sku, x.Name })
                .ToListAsync(cancellationToken);

        var productLookup = products.ToDictionary(x => (x.SellerId, x.Sku), x => x.Name);
        var result = new Dictionary<int, (string ProductName, string ProductSku)>();

        foreach (var history in histories)
        {
            var walletAssetId = history.WalletItemId ?? TryExtractWalletAssetId(history.Notes);
            if (!walletAssetId.HasValue || !assetIds.Contains(walletAssetId.Value) || result.ContainsKey(walletAssetId.Value))
                continue;

            var sku = TryExtractSku(history.Notes);
            if (!string.IsNullOrWhiteSpace(sku) && history.SellerId.HasValue && productLookup.TryGetValue((history.SellerId.Value, sku), out var productName))
            {
                result[walletAssetId.Value] = (productName, sku);
                continue;
            }

            result[walletAssetId.Value] = (history.Category, sku ?? string.Empty);
        }

        return result;
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

    public sealed class CancelWalletRequest
    {
        public int UserId { get; set; }
        public int WalletAssetId { get; set; }
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
        public string? InvoiceUrl { get; set; }
        public int? InvoiceId { get; set; }
    }

    public sealed class CancelWalletRequestResponse
    {
        public int WalletAssetId { get; set; }
        public string Status { get; set; } = "cancelled";
    }

    public sealed class SellExecutionConfigurationResponse
    {
        public string Mode { get; set; } = "locked_30_seconds";
        public int LockSeconds { get; set; } = 30;
    }

    public sealed class EnsureWalletItemCertificateResponse
    {
        public int InvoiceId { get; set; }
        public string InvoiceNumber { get; set; } = string.Empty;
        public string? PdfUrl { get; set; }
    }

    private async Task<(Dictionary<int, string> StatusByAssetId, Dictionary<int, string?> DetailsByAssetId)> ResolveAssetStatusesAsync(
        int userId,
        IReadOnlyList<WalletAssetDto> assets,
        CancellationToken cancellationToken)
    {
        var histories = await dbContext.TransactionHistories
            .AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new
            {
                x.TransactionType,
                x.Status,
                x.Notes,
                x.SellerId,
                x.Category
            })
            .ToListAsync(cancellationToken);

        var results = assets.ToDictionary(x => x.Id, _ => "Bought");
        var details = assets.ToDictionary(x => x.Id, _ => (string?)null);
        var resolvedAssetIds = new HashSet<int>();

        foreach (var history in histories)
        {
            var walletAssetId = TryExtractWalletAssetId(history.Notes);
            if (walletAssetId.HasValue && results.ContainsKey(walletAssetId.Value))
            {
                if (!resolvedAssetIds.Contains(walletAssetId.Value))
                {
                    results[walletAssetId.Value] = MapStatus(history.TransactionType, history.Status, isReceived: false);
                    details[walletAssetId.Value] = null;
                    resolvedAssetIds.Add(walletAssetId.Value);
                }
                continue;
            }

            var isReceived = (history.Notes ?? string.Empty).Contains("direction=received", StringComparison.OrdinalIgnoreCase);
            if (!isReceived || history.SellerId is null) continue;

            var status = MapStatus(history.TransactionType, history.Status, isReceived: true);
            if (status == "Bought") continue;

            var candidateAsset = assets.FirstOrDefault(x =>
                x.SellerId == history.SellerId &&
                x.Category.Equals(history.Category, StringComparison.OrdinalIgnoreCase) &&
                results[x.Id] == "Bought");

            if (candidateAsset is not null)
            {
                results[candidateAsset.Id] = status;
                details[candidateAsset.Id] = BuildReceivedStatusDetails(history.TransactionType, history.Notes);
                resolvedAssetIds.Add(candidateAsset.Id);
            }
        }

        return (results, details);
    }

    private static string MapStatus(string? transactionType, string? status, bool isReceived)
    {
        var type = (transactionType ?? string.Empty).Trim().ToLowerInvariant();
        var state = (status ?? string.Empty).Trim().ToLowerInvariant();

        return (type, state, isReceived) switch
        {
            ("sell", "pending", _) => "Pending - Sell",
            ("pickup", "pending", _) => "Pending - Pickup",
            ("pickup", "approved", _) => "Pending - Delivered",
            ("pickup", "pending_delivered", _) => "Pending - Delivered",
            ("transfer", "pending", _) => "Pending - Transfer",
            ("gift", "pending", _) => "Pending - Gift",
            ("transfer", "approved", false) => "Transfer",
            ("gift", "approved", false) => "Gift",
            ("transfer", "approved", true) => "Transfer",
            ("gift", "approved", true) => "Gift",
            ("delivered_completed", _, _) => "Delivered",
            _ => "Bought"
        };
    }

    private static string NormalizeInvoiceCategory(string actionType)
    {
        var normalized = actionType.Trim().ToLowerInvariant();
        return normalized switch
        {
            "sell" => "Sell",
            "gift" => "Gift",
            "transfer" => "Transfer",
            "pickup" or "certificate" or "invoice" => "Pickup",
            _ => "Buy"
        };
    }

    private static ProductCategory ParseProductCategory(string? categoryOrAction)
    {
        var normalized = (categoryOrAction ?? string.Empty).Trim().ToLowerInvariant();
        return normalized switch
        {
            "silver" => ProductCategory.Silver,
            "diamond" => ProductCategory.Diamond,
            "jewelry" => ProductCategory.Jewelry,
            "coin" or "coins" => ProductCategory.Coins,
            _ => ProductCategory.Gold
        };
    }

    private static int? TryExtractWalletAssetId(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;
        const string marker = "wallet_asset_id=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;
        var tail = notes[valueStart..].Trim();
        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        var rawValue = stopAt > 0 ? tail[..stopAt].Trim() : tail;
        return int.TryParse(rawValue, out var id) ? id : null;
    }

    private static string? BuildReceivedStatusDetails(string? transactionType, string? notes)
    {
        var type = (transactionType ?? string.Empty).Trim().ToLowerInvariant();
        if (type is not ("gift" or "transfer")) return null;

        var sourceInvestorName = TryExtractMeta(notes, "from_investor_name")
            ?? TryExtractMeta(notes, "from_investor_user_id");
        if (string.IsNullOrWhiteSpace(sourceInvestorName)) return null;

        return type == "gift"
            ? $"Received as Gift from {sourceInvestorName}"
            : $"Received as Transfer from {sourceInvestorName}";
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
        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        var rawValue = stopAt > 0 ? tail[..stopAt].Trim() : tail;
        return string.IsNullOrWhiteSpace(rawValue) ? null : rawValue;
    }

    private static string? TryExtractMeta(string? notes, string key)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;

        var marker = $"{key}=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;

        var tail = notes[valueStart..].Trim();
        var stopAt = tail.IndexOfAny(['|', ',', ';']);
        var rawValue = stopAt > 0 ? tail[..stopAt].Trim() : tail.Trim();
        return string.IsNullOrWhiteSpace(rawValue) ? null : rawValue;
    }

    private async Task<string?> SaveInvoiceDocumentAsync(
        int investorUserId,
        string actionType,
        WalletAsset asset,
        int quantity,
        decimal amount,
        CancellationToken cancellationToken)
    {
        var root = environment.WebRootPath;
        if (string.IsNullOrWhiteSpace(root))
        {
            root = Path.Combine(environment.ContentRootPath, "wwwroot");
        }

        var folder = Path.Combine(root, "Certificats", investorUserId.ToString());
        Directory.CreateDirectory(folder);

        var fileName = $"invoice-{Guid.NewGuid():N}.pdf";
        var filePath = Path.Combine(folder, fileName);
        var lines = new[]
        {
            "Gold Wallet Invoice",
            $"Date (UTC): {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}",
            $"Action: {actionType}",
            $"Investor User Id: {investorUserId}",
            $"Asset Id: {asset.Id}",
            $"Asset Type: {asset.AssetType}",
            $"Category: {asset.Category}",
            $"Quantity: {quantity}",
            $"Weight: {asset.Weight} {asset.Unit}",
            $"Purity: {asset.Purity}",
            $"Amount: {amount}"
        };
        var pdfBytes = BuildSimplePdf(lines);
        await System.IO.File.WriteAllBytesAsync(filePath, pdfBytes, cancellationToken);
        return $"/Certificats/{investorUserId}/{fileName}";
    }

    private static byte[] BuildSimplePdf(IEnumerable<string> lines)
    {
        static string EscapePdf(string value) => value
            .Replace("\\", "\\\\")
            .Replace("(", "\\(")
            .Replace(")", "\\)");

        var contentBuilder = new StringBuilder();
        contentBuilder.AppendLine("BT");
        contentBuilder.AppendLine("/F1 12 Tf");
        contentBuilder.AppendLine("50 780 Td");
        var first = true;
        foreach (var line in lines)
        {
            if (!first)
            {
                contentBuilder.AppendLine("0 -16 Td");
            }
            contentBuilder.AppendLine($"({EscapePdf(line)}) Tj");
            first = false;
        }
        contentBuilder.AppendLine("ET");

        var streamContent = contentBuilder.ToString();
        var objects = new List<string>
        {
            "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n",
            "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n",
            "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\nendobj\n",
            $"4 0 obj\n<< /Length {Encoding.ASCII.GetByteCount(streamContent)} >>\nstream\n{streamContent}endstream\nendobj\n",
            "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n"
        };

        var pdf = new StringBuilder();
        pdf.Append("%PDF-1.4\n");
        var offsets = new List<int> { 0 };
        foreach (var obj in objects)
        {
            offsets.Add(Encoding.ASCII.GetByteCount(pdf.ToString()));
            pdf.Append(obj);
        }

        var xrefStart = Encoding.ASCII.GetByteCount(pdf.ToString());
        pdf.Append($"xref\n0 {objects.Count + 1}\n");
        pdf.Append("0000000000 65535 f \n");
        foreach (var offset in offsets.Skip(1))
        {
            pdf.Append($"{offset:D10} 00000 n \n");
        }
        pdf.Append($"trailer\n<< /Size {objects.Count + 1} /Root 1 0 R >>\nstartxref\n{xrefStart}\n%%EOF");

        return Encoding.ASCII.GetBytes(pdf.ToString());
    }

    private string? ToAbsoluteFileUrl(string? fileUrl)
    {
        if (string.IsNullOrWhiteSpace(fileUrl)) return null;
        if (Uri.TryCreate(fileUrl, UriKind.Absolute, out _)) return fileUrl;

        var request = HttpContext.Request;
        var normalized = fileUrl.StartsWith('/') ? fileUrl : $"/{fileUrl}";
        return $"{request.Scheme}://{request.Host}{normalized}";
    }

    private bool InvoiceFileExists(string? fileUrl)
    {
        if (string.IsNullOrWhiteSpace(fileUrl)) return false;
        var root = environment.WebRootPath;
        if (string.IsNullOrWhiteSpace(root))
        {
            root = Path.Combine(environment.ContentRootPath, "wwwroot");
        }

        var relative = fileUrl.Trim().TrimStart('/');
        var physicalPath = Path.Combine(root, relative.Replace('/', Path.DirectorySeparatorChar));
        return System.IO.File.Exists(physicalPath);
    }
}
