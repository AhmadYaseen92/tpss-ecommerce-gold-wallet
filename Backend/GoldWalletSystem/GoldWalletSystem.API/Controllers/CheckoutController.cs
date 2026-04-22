using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/checkout")]
public class CheckoutController(
    AppDbContext dbContext,
    ICurrentUserService currentUser,
    IOtpService otpService,
    INotificationService notificationService,
    IFeeCalculationService feeCalculationService,
    API.Services.IMarketplaceRealtimeNotifier realtimeNotifier) : SecuredControllerBase(currentUser)
{
    [HttpPost("otp/request")]
    public async Task<IActionResult> RequestCheckoutOtp([FromBody] CheckoutOtpRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var actionReference = BuildCheckoutActionReference(request.UserId, request.ProductIds, request.ProductId, request.Quantity);
        var data = await otpService.RequestAsync(new RequestOtpRequestDto
        {
            UserId = request.UserId,
            ActionType = OtpActionTypes.Buy,
            ActionReferenceId = actionReference,
            ForceEmailFallback = request.ForceEmailFallback
        }, cancellationToken);

        return Ok(ApiResponse<OtpDispatchResponseDto>.Ok(data, "Checkout OTP sent"));
    }

    [HttpPost("otp/resend")]
    public async Task<IActionResult> ResendCheckoutOtp([FromBody] ResendCheckoutOtpRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var data = await otpService.ResendAsync(new ResendOtpRequestDto
        {
            UserId = request.UserId,
            OtpRequestId = request.OtpRequestId,
            ForceEmailFallback = request.ForceEmailFallback
        }, cancellationToken);

        return Ok(ApiResponse<OtpDispatchResponseDto>.Ok(data, "Checkout OTP resent"));
    }

    [HttpPost("otp/verify")]
    public async Task<IActionResult> VerifyCheckoutOtp([FromBody] VerifyCheckoutOtpRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var data = await otpService.VerifyAsync(new VerifyOtpRequestDto
        {
            UserId = request.UserId,
            OtpRequestId = request.OtpRequestId,
            OtpCode = request.OtpCode
        }, cancellationToken);

        return Ok(ApiResponse<VerifyOtpResponseDto>.Ok(data, "Checkout OTP verified"));
    }

    [HttpPost("confirm")]
    public async Task<IActionResult> Confirm([FromBody] CheckoutConfirmRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        await EnsureCheckoutOtpVerifiedAsync(request, cancellationToken);
        var isDirectCheckout = request.ProductId.HasValue && request.Quantity.HasValue && request.Quantity.Value > 0;
        var fromCart = !isDirectCheckout;

        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        if (wallet is null)
        {
            wallet = new Wallet
            {
                UserId = request.UserId,
                CurrencyCode = "USD",
                CashBalance = 0,
                CreatedAtUtc = DateTime.UtcNow,
            };
            dbContext.Wallets.Add(wallet);
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        var lines = new List<(Product Product, int Quantity)>();
        Cart? cart = null;

        if (fromCart)
        {
            cart = await dbContext.Carts
                .Include(x => x.Items)
                .ThenInclude(x => x.Product)
                .ThenInclude(x => x.Seller)
                .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken)
                ?? throw new InvalidOperationException("Cart not found.");

            if (cart.Items.Count == 0)
                throw new InvalidOperationException("Cart is empty.");

            var selectedItems = cart.Items.AsEnumerable();
            if (request.ProductIds is { Count: > 0 })
            {
                var productIdSet = request.ProductIds.ToHashSet();
                selectedItems = selectedItems.Where(item => productIdSet.Contains(item.ProductId));
            }

            var selectedList = selectedItems.ToList();
            if (selectedList.Count == 0)
                throw new InvalidOperationException("No matching cart items were selected for checkout.");

            lines.AddRange(selectedList.Select(item => (item.Product, item.Quantity)));
        }
        else
        {
            if (!request.ProductId.HasValue || !request.Quantity.HasValue || request.Quantity.Value <= 0)
                throw new InvalidOperationException("ProductId and positive Quantity are required.");

            var product = await dbContext.Products
                .Include(x => x.Seller)
                .FirstOrDefaultAsync(x => x.Id == request.ProductId.Value && x.IsActive, cancellationToken)
                ?? throw new InvalidOperationException("Product not found.");

            lines.Add((product, request.Quantity.Value));
        }

        decimal totalAmount = 0;
        var createdRequests = new List<TransactionHistory>();
        var pendingFeeBreakdowns = new List<(TransactionHistory History, int ProductId, int SellerId, Application.DTOs.Fees.FeeLineDto Line)>();
        foreach (var (product, quantity) in lines)
        {
            if (product.AvailableStock < quantity)
                throw new InvalidOperationException($"Insufficient stock for {product.Name}. Available {product.AvailableStock}, requested {quantity}.");

            var unitPrice = ResolveProductUnitPrice(product);
            var subTotal = unitPrice * quantity;
            totalAmount += subTotal;

            var feeResult = await feeCalculationService.CalculateAsync(
                new Application.DTOs.Fees.FeeCalculationRequest(
                    ActionType: "buy",
                    ProductId: product.Id,
                    SellerId: product.SellerId,
                    NotionalAmount: subTotal,
                    Quantity: quantity,
                    ClosePrice: unitPrice,
                    DaysHeldAfterGrace: 0),
                cancellationToken);

            var grams = ToGrams(product.WeightValue, product.WeightUnit) * quantity;
            var purity = ParsePurity(product.Description);

            var requestHistory = new TransactionHistory
            {
                UserId = request.UserId,
                SellerId = product.SellerId,
                ProductId = product.Id,
                TransactionType = "BUY",
                Status = "pending",
                Category = product.Category.ToString(),
                Quantity = quantity,
                UnitPrice = unitPrice,
                Weight = grams,
                Unit = "gram",
                Purity = purity,
                Notes = $"Checkout request from {(fromCart ? "cart" : "direct buy")}. SKU={product.Sku}",
                Amount = feeResult.FinalAmount,
                SubTotalAmount = feeResult.SubTotalAmount,
                TotalFeesAmount = feeResult.TotalFeesAmount,
                DiscountAmount = feeResult.DiscountAmount,
                FinalAmount = feeResult.FinalAmount,
                Currency = wallet.CurrencyCode,
                CreatedAtUtc = DateTime.UtcNow,
            };
            dbContext.TransactionHistories.Add(requestHistory);
            createdRequests.Add(requestHistory);

            foreach (var line in feeResult.Lines)
            {
                pendingFeeBreakdowns.Add((requestHistory, product.Id, product.SellerId, line));
            }
        }

        if (fromCart && cart is not null)
        {
            if (request.ProductIds is { Count: > 0 })
            {
                var productIdSet = request.ProductIds.ToHashSet();
                var matchedItems = cart.Items.Where(x => productIdSet.Contains(x.ProductId)).ToList();
                dbContext.CartItems.RemoveRange(matchedItems);
            }
            else
            {
                dbContext.CartItems.RemoveRange(cart.Items);
            }
        }

        dbContext.AuditLogs.Add(new AuditLog
        {
            UserId = request.UserId,
            Action = "CheckoutConfirmed",
            EntityName = "Checkout",
            Details = $"Items: {lines.Count}, Total: {totalAmount:F2}",
            CreatedAtUtc = DateTime.UtcNow,
        });

        await dbContext.SaveChangesAsync(cancellationToken);

        foreach (var pending in pendingFeeBreakdowns)
        {
            dbContext.TransactionFeeBreakdowns.Add(new TransactionFeeBreakdown
            {
                TransactionHistoryId = pending.History.Id,
                ProductId = pending.ProductId,
                SellerId = pending.SellerId,
                FeeCode = pending.Line.FeeCode,
                FeeName = pending.Line.FeeName,
                CalculationMode = pending.Line.CalculationMode,
                BaseAmount = pending.Line.BaseAmount,
                Quantity = pending.Line.Quantity,
                AppliedRate = pending.Line.AppliedRate,
                AppliedValue = pending.Line.AppliedValue,
                IsDiscount = pending.Line.IsDiscount,
                Currency = pending.Line.Currency,
                SourceType = pending.Line.SourceType,
                ConfigSnapshotJson = pending.Line.ConfigSnapshotJson ?? string.Empty,
                DisplayOrder = pending.Line.DisplayOrder,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        if (pendingFeeBreakdowns.Count > 0)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        var requestNumbers = createdRequests.Select(x => $"r-{x.Id}").ToList();
        var requestNumbersText = string.Join(", ", requestNumbers.Take(3));
        if (requestNumbers.Count > 3)
        {
            requestNumbersText = $"{requestNumbersText} +{requestNumbers.Count - 3} more";
        }

        var adminUserIds = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Role == "Admin" && x.IsActive)
            .Select(x => x.Id)
            .ToListAsync(cancellationToken);

        var distinctSellerIds = lines.Select(x => x.Product.SellerId).Distinct().ToList();
        var sellerUserIds = await dbContext.Sellers
            .AsNoTracking()
            .Where(x => distinctSellerIds.Contains(x.Id))
            .Select(x => x.UserId)
            .ToListAsync(cancellationToken);

        await notificationService.CreateAsync(new CreateNotificationRequestDto
        {
            UserId = request.UserId,
            Type = NotificationType.RequestUpdated,
            ReferenceType = NotificationReferenceType.Request,
            ReferenceId = createdRequests.FirstOrDefault()?.Id,
            ActionUrl = "/wallet/requests",
            Title = "Checkout submitted",
            Body = $"Your {(fromCart ? "cart" : "buy")} request is pending approval. Request: {requestNumbersText}."
        }, cancellationToken);

        var reviewerIds = adminUserIds.Concat(sellerUserIds).Distinct().ToList();
        foreach (var reviewerId in reviewerIds)
        {
            await notificationService.CreateAsync(new CreateNotificationRequestDto
            {
                UserId = reviewerId,
                Type = NotificationType.RequestUpdated,
                ReferenceType = NotificationReferenceType.Request,
                ReferenceId = createdRequests.FirstOrDefault()?.Id,
                ActionUrl = "/web-admin/requests",
                Role = "Admin",
                Priority = 1,
                Title = "New request needs your action",
                Body = $"Investor #{request.UserId} submitted {lines.Count} checkout request item(s). Request: {requestNumbersText}."
            }, cancellationToken);
        }

        await realtimeNotifier.BroadcastRefreshHintAsync($"checkout:{request.UserId}", cancellationToken);

        return Ok(ApiResponse<object>.Ok(new
        {
            userId = request.UserId,
            fromCart,
            itemsCount = lines.Count,
            subTotalAmount = createdRequests.Sum(x => x.SubTotalAmount),
            totalFeesAmount = createdRequests.Sum(x => x.TotalFeesAmount),
            discountAmount = createdRequests.Sum(x => x.DiscountAmount),
            finalAmount = createdRequests.Sum(x => x.FinalAmount),
            currency = wallet.CurrencyCode,
            feeBreakdowns = pendingFeeBreakdowns.Select(x => x.Line).ToList(),
        }, "Checkout completed"));
    }

    private static decimal ToGrams(decimal weightValue, ProductWeightUnit weightUnit) => weightUnit switch
    {
        ProductWeightUnit.Kilogram => weightValue * 1000m,
        ProductWeightUnit.Ounce => weightValue * 31.1035m,
        _ => weightValue
    };

    private static AssetType ToAssetType(ProductCategory category) => category switch
    {
        ProductCategory.Coins => AssetType.GoldCoin,
        ProductCategory.Jewelry or ProductCategory.Diamond => AssetType.Jewelry,
        ProductCategory.Silver => AssetType.Silver,
        ProductCategory.SpotMr => AssetType.GoldBar,
        ProductCategory.Gold => AssetType.GoldBar,
        _ => AssetType.GoldBar
    };

    private static decimal ParsePurity(string description)
    {
        if (description.Contains("24k", StringComparison.OrdinalIgnoreCase)) return 24m;
        if (description.Contains("22k", StringComparison.OrdinalIgnoreCase)) return 22m;
        if (description.Contains("18k", StringComparison.OrdinalIgnoreCase)) return 18m;
        return 0m;
    }

    public sealed class CheckoutConfirmRequest
    {
        public int UserId { get; set; }
        public bool FromCart { get; set; } = true;
        public List<int>? ProductIds { get; set; }
        public int? ProductId { get; set; }
        public int? Quantity { get; set; }
        public string OtpVerificationToken { get; set; } = string.Empty;
        public string OtpActionReferenceId { get; set; } = string.Empty;
        public string OtpRequestId { get; set; } = string.Empty;
        public string OtpCode { get; set; } = string.Empty;
    }

    public sealed class CheckoutOtpRequest
    {
        public int UserId { get; set; }
        public List<int>? ProductIds { get; set; }
        public int? ProductId { get; set; }
        public int? Quantity { get; set; }
        public bool ForceEmailFallback { get; set; }
    }

    public sealed class ResendCheckoutOtpRequest
    {
        public int UserId { get; set; }
        public string OtpRequestId { get; set; } = string.Empty;
        public bool ForceEmailFallback { get; set; }
    }

    public sealed class VerifyCheckoutOtpRequest
    {
        public int UserId { get; set; }
        public string OtpRequestId { get; set; } = string.Empty;
        public string OtpCode { get; set; } = string.Empty;
    }

    private async Task EnsureCheckoutOtpVerifiedAsync(CheckoutConfirmRequest request, CancellationToken cancellationToken)
    {
        var actionReference = string.IsNullOrWhiteSpace(request.OtpActionReferenceId)
            ? BuildCheckoutActionReference(request.UserId, request.ProductIds, request.ProductId, request.Quantity)
            : request.OtpActionReferenceId;

        if (!string.IsNullOrWhiteSpace(request.OtpVerificationToken))
        {
            await ConsumeCheckoutOrBuyGrantAsync(request.UserId, actionReference, request.OtpVerificationToken, cancellationToken);
            return;
        }

        if (string.IsNullOrWhiteSpace(request.OtpRequestId) || string.IsNullOrWhiteSpace(request.OtpCode))
            throw new InvalidOperationException("Checkout OTP is required. Call /api/checkout/otp/request then verify with /api/checkout/otp/verify.");

        var verified = await otpService.VerifyAsync(new VerifyOtpRequestDto
        {
            UserId = request.UserId,
            OtpRequestId = request.OtpRequestId,
            OtpCode = request.OtpCode
        }, cancellationToken);

        var verifiedAction = verified.ActionType.Trim().ToLowerInvariant();
        if (verifiedAction is not (OtpActionTypes.Checkout or OtpActionTypes.Buy))
            throw new InvalidOperationException("OTP action is invalid for checkout.");

        await otpService.ConsumeVerificationGrantAsync(
            request.UserId,
            verified.ActionType,
            string.IsNullOrWhiteSpace(verified.ActionReferenceId) ? actionReference : verified.ActionReferenceId,
            verified.VerificationToken,
            cancellationToken);
    }

    private static string BuildCheckoutActionReference(int userId, IReadOnlyCollection<int>? productIds, int? productId, int? quantity)
    {
        if (productId.HasValue && quantity.HasValue && quantity.Value > 0)
            return $"checkout:{userId}:product:{productId.Value}:qty:{quantity.Value}";

        if (productIds is { Count: > 0 })
        {
            var sorted = productIds.OrderBy(x => x).ToArray();
            return $"checkout:{userId}:cart:{string.Join('-', sorted)}";
        }

        return $"checkout:{userId}:cart:all";
    }

    private async Task ConsumeCheckoutOrBuyGrantAsync(int userId, string actionReference, string verificationToken, CancellationToken cancellationToken)
    {
        try
        {
            await otpService.ConsumeVerificationGrantAsync(
                userId,
                OtpActionTypes.Checkout,
                actionReference,
                verificationToken,
                cancellationToken);
            return;
        }
        catch (UnauthorizedAccessException)
        {
            // Try Buy action for mobile flows that label checkout OTP as "buy".
        }
        catch (InvalidOperationException)
        {
            // Try Buy action for mobile flows that label checkout OTP as "buy".
        }

        await otpService.ConsumeVerificationGrantAsync(
            userId,
            OtpActionTypes.Buy,
            actionReference,
            verificationToken,
            cancellationToken);
    }
}
