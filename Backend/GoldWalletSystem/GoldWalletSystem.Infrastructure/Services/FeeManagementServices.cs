using GoldWalletSystem.Application.DTOs.Fees;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Services;

public class SystemFeeService(AppDbContext dbContext) : ISystemFeeService
{
    public async Task<IReadOnlyList<SystemFeeTypeDto>> GetAllAsync(CancellationToken cancellationToken = default)
        => await dbContext.SystemFeeTypes.AsNoTracking()
            .OrderBy(x => x.SortOrder)
            .Select(x => new SystemFeeTypeDto(
                x.FeeCode,
                x.Name,
                x.Description,
                x.IsEnabled,
                x.AppliesToBuy,
                x.AppliesToSell,
                x.AppliesToPickup,
                x.AppliesToTransfer,
                x.AppliesToGift,
                x.AppliesToInvoice,
                x.AppliesToReports,
                x.IsAdminManaged,
                x.SortOrder))
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<SystemFeeTypeDto>> GetEnabledSellerFeeTabsAsync(CancellationToken cancellationToken = default)
        => await dbContext.SystemFeeTypes.AsNoTracking()
            .Where(x => x.IsEnabled && FeeCodes.SellerManaged.Contains(x.FeeCode))
            .OrderBy(x => x.SortOrder)
            .Select(x => new SystemFeeTypeDto(
                x.FeeCode,
                x.Name,
                x.Description,
                x.IsEnabled,
                x.AppliesToBuy,
                x.AppliesToSell,
                x.AppliesToPickup,
                x.AppliesToTransfer,
                x.AppliesToGift,
                x.AppliesToInvoice,
                x.AppliesToReports,
                x.IsAdminManaged,
                x.SortOrder))
            .ToListAsync(cancellationToken);

    public async Task<SystemFeeTypeDto> UpsertAsync(UpsertSystemFeeTypeRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.SystemFeeTypes.FirstOrDefaultAsync(x => x.FeeCode == request.FeeCode, cancellationToken);
        if (entity is null)
        {
            entity = new SystemFeeType { FeeCode = request.FeeCode, CreatedAtUtc = DateTime.UtcNow };
            dbContext.SystemFeeTypes.Add(entity);
        }

        entity.Name = request.Name;
        entity.Description = request.Description;
        entity.IsEnabled = request.IsEnabled;
        entity.AppliesToBuy = request.AppliesToBuy;
        entity.AppliesToSell = request.AppliesToSell;
        entity.AppliesToPickup = request.AppliesToPickup;
        entity.AppliesToTransfer = request.AppliesToTransfer;
        entity.AppliesToGift = request.AppliesToGift;
        entity.AppliesToInvoice = request.AppliesToInvoice;
        entity.AppliesToReports = request.AppliesToReports;
        entity.IsAdminManaged = request.IsAdminManaged;
        entity.SortOrder = request.SortOrder;
        entity.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(entity);
    }

    public async Task<bool> IsFeeEnabledForActionAsync(string feeCode, string actionType, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.SystemFeeTypes.AsNoTracking().FirstOrDefaultAsync(x => x.FeeCode == feeCode && x.IsEnabled, cancellationToken);
        if (entity is null) return false;
        return AppliesToAction(entity, actionType);
    }

    private static bool AppliesToAction(SystemFeeType fee, string actionType) => actionType.ToLowerInvariant() switch
    {
        "buy" => fee.AppliesToBuy,
        "sell" => fee.AppliesToSell,
        "pickup" => fee.AppliesToPickup,
        "transfer" => fee.AppliesToTransfer,
        "gift" => fee.AppliesToGift,
        _ => false
    };

    private static SystemFeeTypeDto Map(SystemFeeType x) => new(
        x.FeeCode, x.Name, x.Description, x.IsEnabled, x.AppliesToBuy, x.AppliesToSell, x.AppliesToPickup, x.AppliesToTransfer, x.AppliesToGift, x.AppliesToInvoice, x.AppliesToReports, x.IsAdminManaged, x.SortOrder);
}

public class SellerProductFeeService(AppDbContext dbContext, ISystemFeeService systemFeeService) : ISellerProductFeeService
{
    public async Task<IReadOnlyList<SellerProductFeeDto>> GetSellerProductFeesAsync(int sellerId, string feeCode, CancellationToken cancellationToken = default)
    {
        var enabled = await systemFeeService.IsFeeEnabledForActionAsync(feeCode, "buy", cancellationToken)
            || await systemFeeService.IsFeeEnabledForActionAsync(feeCode, "sell", cancellationToken)
            || await systemFeeService.IsFeeEnabledForActionAsync(feeCode, "pickup", cancellationToken);
        if (!enabled) return [];

        return await dbContext.SellerProductFees.AsNoTracking()
            .Where(x => x.SellerId == sellerId && x.FeeCode == feeCode)
            .Select(x => new SellerProductFeeDto
            {
                SellerId = x.SellerId,
                ProductId = x.ProductId,
                FeeCode = x.FeeCode,
                IsEnabled = x.IsEnabled,
                CalculationMode = x.CalculationMode,
                RatePercent = x.RatePercent,
                MinimumAmount = x.MinimumAmount,
                FlatAmount = x.FlatAmount,
                PremiumDiscountType = x.PremiumDiscountType,
                ValuePerUnit = x.ValuePerUnit,
                FeePercent = x.FeePercent,
                GracePeriodDays = x.GracePeriodDays,
                FixedAmount = x.FixedAmount,
                FeePerUnit = x.FeePerUnit,
                IsOverride = x.IsOverride
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<SellerProductFeeDto> UpsertAsync(int sellerId, SellerProductFeeUpsertRequest request, CancellationToken cancellationToken = default)
    {
        if (!FeeCodes.SellerManaged.Contains(request.FeeCode)) throw new InvalidOperationException("Fee is not seller-managed.");

        var entity = await dbContext.SellerProductFees.FirstOrDefaultAsync(x => x.SellerId == sellerId && x.ProductId == request.ProductId && x.FeeCode == request.FeeCode, cancellationToken);
        if (entity is null)
        {
            entity = new SellerProductFee { SellerId = sellerId, ProductId = request.ProductId, FeeCode = request.FeeCode, CreatedAtUtc = DateTime.UtcNow };
            dbContext.SellerProductFees.Add(entity);
        }

        Apply(entity, request);
        entity.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(entity);
    }

    public async Task<int> BulkApplyAsync(int sellerId, SellerProductFeeBulkRequest request, CancellationToken cancellationToken = default)
    {
        if (!FeeCodes.SellerManaged.Contains(request.FeeCode)) throw new InvalidOperationException("Fee is not seller-managed.");
        var productIds = request.ApplyToAll
            ? await dbContext.Products.AsNoTracking().Where(x => x.SellerId == sellerId).Select(x => x.Id).ToListAsync(cancellationToken)
            : request.ProductIds.Distinct().ToList();

        foreach (var productId in productIds)
        {
            var upsert = new SellerProductFeeUpsertRequest
            {
                ProductId = productId,
                FeeCode = request.FeeCode,
                IsEnabled = request.Template.IsEnabled,
                CalculationMode = request.Template.CalculationMode,
                RatePercent = request.Template.RatePercent,
                MinimumAmount = request.Template.MinimumAmount,
                FlatAmount = request.Template.FlatAmount,
                PremiumDiscountType = request.Template.PremiumDiscountType,
                ValuePerUnit = request.Template.ValuePerUnit,
                FeePercent = request.Template.FeePercent,
                GracePeriodDays = request.Template.GracePeriodDays,
                FixedAmount = request.Template.FixedAmount,
                FeePerUnit = request.Template.FeePerUnit,
                IsOverride = request.Template.IsOverride
            };
            await UpsertAsync(sellerId, upsert, cancellationToken);
        }

        return productIds.Count;
    }

    private static void Apply(SellerProductFee entity, SellerProductFeeUpsertRequest request)
    {
        entity.IsEnabled = request.IsEnabled;
        entity.CalculationMode = request.CalculationMode;
        entity.RatePercent = request.RatePercent;
        entity.MinimumAmount = request.MinimumAmount;
        entity.FlatAmount = request.FlatAmount;
        entity.PremiumDiscountType = request.PremiumDiscountType;
        entity.ValuePerUnit = request.ValuePerUnit;
        entity.FeePercent = request.FeePercent;
        entity.GracePeriodDays = request.GracePeriodDays;
        entity.FixedAmount = request.FixedAmount;
        entity.FeePerUnit = request.FeePerUnit;
        entity.IsOverride = request.IsOverride;
    }

    private static SellerProductFeeDto Map(SellerProductFee x) => new()
    {
        SellerId = x.SellerId,
        ProductId = x.ProductId,
        FeeCode = x.FeeCode,
        IsEnabled = x.IsEnabled,
        CalculationMode = x.CalculationMode,
        RatePercent = x.RatePercent,
        MinimumAmount = x.MinimumAmount,
        FlatAmount = x.FlatAmount,
        PremiumDiscountType = x.PremiumDiscountType,
        ValuePerUnit = x.ValuePerUnit,
        FeePercent = x.FeePercent,
        GracePeriodDays = x.GracePeriodDays,
        FixedAmount = x.FixedAmount,
        FeePerUnit = x.FeePerUnit,
        IsOverride = x.IsOverride
    };
}

public class AdminTransactionFeeService(AppDbContext dbContext) : IAdminTransactionFeeService
{
    public async Task<AdminServiceFeeSettingsDto> GetServiceFeeAsync(CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.AdminTransactionFees.AsNoTracking().FirstOrDefaultAsync(x => x.FeeCode == FeeCodes.ServiceFee, cancellationToken);
        return entity is null ? new AdminServiceFeeSettingsDto() : Map(entity);
    }

    public async Task<AdminServiceFeeSettingsDto> UpsertServiceFeeAsync(AdminServiceFeeSettingsDto request, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.AdminTransactionFees.FirstOrDefaultAsync(x => x.FeeCode == FeeCodes.ServiceFee, cancellationToken);
        if (entity is null)
        {
            entity = new AdminTransactionFee { FeeCode = FeeCodes.ServiceFee, CreatedAtUtc = DateTime.UtcNow };
            dbContext.AdminTransactionFees.Add(entity);
        }

        entity.IsEnabled = request.IsEnabled;
        entity.CalculationMode = request.CalculationMode;
        entity.RatePercent = request.RatePercent;
        entity.FixedAmount = request.FixedAmount;
        entity.AppliesToBuy = request.AppliesToBuy;
        entity.AppliesToSell = request.AppliesToSell;
        entity.AppliesToPickup = request.AppliesToPickup;
        entity.AppliesToTransfer = request.AppliesToTransfer;
        entity.AppliesToGift = request.AppliesToGift;
        entity.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(entity);
    }

    private static AdminServiceFeeSettingsDto Map(AdminTransactionFee x) => new()
    {
        IsEnabled = x.IsEnabled,
        CalculationMode = x.CalculationMode,
        RatePercent = x.RatePercent,
        FixedAmount = x.FixedAmount,
        AppliesToBuy = x.AppliesToBuy,
        AppliesToSell = x.AppliesToSell,
        AppliesToPickup = x.AppliesToPickup,
        AppliesToTransfer = x.AppliesToTransfer,
        AppliesToGift = x.AppliesToGift
    };
}

public class FeeCalculationService(AppDbContext dbContext) : IFeeCalculationService
{
    public async Task<FeeCalculationResultDto> CalculateAsync(FeeCalculationRequest request, CancellationToken cancellationToken = default)
    {
        var lines = new List<FeeLineDto>();
        var action = request.ActionType.ToLowerInvariant();
        var currency = "USD";

        if (request.ProductId.HasValue && request.SellerId.HasValue)
        {
            var sellerFees = await dbContext.SellerProductFees.AsNoTracking()
                .Where(x => x.ProductId == request.ProductId.Value && x.SellerId == request.SellerId.Value && x.IsEnabled)
                .ToListAsync(cancellationToken);

            var feeCodes = sellerFees.Select(x => x.FeeCode).Distinct().ToList();
            var systemFeeLookup = feeCodes.Count == 0
                ? new Dictionary<string, SystemFeeType>(StringComparer.OrdinalIgnoreCase)
                : await dbContext.SystemFeeTypes.AsNoTracking()
                    .Where(x => feeCodes.Contains(x.FeeCode) && x.IsEnabled)
                    .ToDictionaryAsync(x => x.FeeCode, x => x, StringComparer.OrdinalIgnoreCase, cancellationToken);

            foreach (var fee in sellerFees)
            {
                if (!systemFeeLookup.TryGetValue(fee.FeeCode, out var systemFee)) continue;
                if (!AppliesToAction(systemFee, action)) continue;
                if (!IsActionCompatible(fee.FeeCode, action)) continue;
                var line = CalculateSellerLine(fee, request, lines.Count + 1, currency);
                if (line is not null) lines.Add(line);
            }
        }

        var serviceFeeType = await dbContext.SystemFeeTypes.AsNoTracking()
            .FirstOrDefaultAsync(x => x.FeeCode == FeeCodes.ServiceFee && x.IsEnabled && x.IsAdminManaged, cancellationToken);

        var serviceFee = await dbContext.AdminTransactionFees.AsNoTracking().FirstOrDefaultAsync(x => x.FeeCode == FeeCodes.ServiceFee && x.IsEnabled, cancellationToken);
        if (serviceFee is not null && serviceFeeType is not null && AppliesToAction(serviceFeeType, action) && IsServiceFeeActionEnabled(serviceFee, action))
        {
            var amount = serviceFee.CalculationMode.Equals("percent", StringComparison.OrdinalIgnoreCase)
                ? request.NotionalAmount * (serviceFee.RatePercent ?? 0m) / 100m
                : (serviceFee.FixedAmount ?? 0m);
            lines.Add(new FeeLineDto(FeeCodes.ServiceFee, "Service Fee", serviceFee.CalculationMode, request.NotionalAmount, request.Quantity, serviceFee.RatePercent, decimal.Round(amount, 2), false, currency, "AdminServiceFee", $"{{\"feeCode\":\"{FeeCodes.ServiceFee}\",\"mode\":\"{serviceFee.CalculationMode}\"}}", lines.Count + 1));
        }

        var totalFees = lines.Where(x => !x.IsDiscount).Sum(x => x.AppliedValue);
        var totalDiscounts = lines.Where(x => x.IsDiscount).Sum(x => x.AppliedValue);
        var finalAmount = request.NotionalAmount + totalFees - totalDiscounts;
        return new FeeCalculationResultDto(request.NotionalAmount, totalFees, totalDiscounts, finalAmount, currency, lines);
    }

    private static FeeLineDto? CalculateSellerLine(SellerProductFee fee, FeeCalculationRequest request, int order, string currency)
    {
        var code = fee.FeeCode;
        decimal amount = 0m;
        var isDiscount = false;

        switch (code)
        {
            case var _ when code == FeeCodes.CommissionPerTransaction:
                amount = fee.CalculationMode == "percent_with_minimum"
                    ? Math.Max(request.NotionalAmount * (fee.RatePercent ?? 0m) / 100m, fee.MinimumAmount ?? 0m)
                    : (fee.FlatAmount ?? 0m);
                break;
            case var _ when code == FeeCodes.PremiumDiscount:
                amount = request.Quantity * (fee.ValuePerUnit ?? 0m);
                isDiscount = string.Equals(fee.PremiumDiscountType, "discount", StringComparison.OrdinalIgnoreCase);
                break;
            case var _ when code == FeeCodes.StorageCustodyFee:
                var daysHeldAfterGrace = Math.Max(0, request.DaysHeldAfterGrace - (fee.GracePeriodDays ?? 0));
                amount = request.Quantity * request.ClosePrice * ((fee.FeePercent ?? 0m) / 100m) / 360m * daysHeldAfterGrace;
                break;
            case var _ when code == FeeCodes.DeliveryFee:
            case var _ when code == FeeCodes.ServiceCharge:
                amount = fee.CalculationMode == "per_unit" ? request.Quantity * (fee.FeePerUnit ?? 0m) : (fee.FixedAmount ?? 0m);
                break;
            default:
                return null;
        }

        return new FeeLineDto(code, code.Replace("_", " "), fee.CalculationMode, request.NotionalAmount, request.Quantity, fee.RatePercent, decimal.Round(amount, 2), isDiscount, currency, "SellerProductFee", $"{{\"feeCode\":\"{code}\",\"mode\":\"{fee.CalculationMode}\"}}", order);
    }

    private static bool IsActionCompatible(string feeCode, string action) => feeCode switch
    {
        var c when c == FeeCodes.CommissionPerTransaction => action is "buy" or "sell",
        var c when c == FeeCodes.PremiumDiscount => action == "pickup",
        var c when c == FeeCodes.StorageCustodyFee => action == "pickup",
        var c when c == FeeCodes.DeliveryFee => action == "pickup",
        var c when c == FeeCodes.ServiceCharge => action is "buy" or "sell" or "pickup",
        _ => false
    };

    private static bool AppliesToAction(SystemFeeType fee, string action) => action switch
    {
        "buy" => fee.AppliesToBuy,
        "sell" => fee.AppliesToSell,
        "pickup" => fee.AppliesToPickup,
        "transfer" => fee.AppliesToTransfer,
        "gift" => fee.AppliesToGift,
        _ => false
    };

    private static bool IsServiceFeeActionEnabled(AdminTransactionFee fee, string action) => action switch
    {
        "buy" => fee.AppliesToBuy,
        "sell" => fee.AppliesToSell,
        "pickup" => fee.AppliesToPickup,
        "transfer" => fee.AppliesToTransfer,
        "gift" => fee.AppliesToGift,
        _ => false
    };
}
