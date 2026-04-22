namespace GoldWalletSystem.Application.DTOs.Fees;

public record SystemFeeTypeDto(
    string FeeCode,
    string Name,
    string Description,
    bool IsEnabled,
    bool AppliesToBuy,
    bool AppliesToSell,
    bool AppliesToPickup,
    bool AppliesToTransfer,
    bool AppliesToGift,
    bool AppliesToInvoice,
    bool AppliesToReports,
    int SortOrder);

public class UpsertSystemFeeTypeRequest
{
    public string FeeCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool IsEnabled { get; set; }
    public bool AppliesToBuy { get; set; }
    public bool AppliesToSell { get; set; }
    public bool AppliesToPickup { get; set; }
    public bool AppliesToTransfer { get; set; }
    public bool AppliesToGift { get; set; }
    public bool AppliesToInvoice { get; set; }
    public bool AppliesToReports { get; set; }
    public int SortOrder { get; set; }
}

public class AdminServiceFeeSettingsDto
{
    public bool IsEnabled { get; set; }
    public string CalculationMode { get; set; } = "fixed";
    public decimal? RatePercent { get; set; }
    public decimal? FixedAmount { get; set; }
    public bool AppliesToBuy { get; set; }
    public bool AppliesToSell { get; set; }
    public bool AppliesToPickup { get; set; }
    public bool AppliesToTransfer { get; set; }
    public bool AppliesToGift { get; set; }
}

public class SellerProductFeeUpsertRequest
{
    public int ProductId { get; set; }
    public string FeeCode { get; set; } = string.Empty;
    public bool IsEnabled { get; set; }
    public string CalculationMode { get; set; } = string.Empty;
    public decimal? RatePercent { get; set; }
    public decimal? MinimumAmount { get; set; }
    public decimal? FlatAmount { get; set; }
    public string? PremiumDiscountType { get; set; }
    public decimal? ValuePerUnit { get; set; }
    public decimal? FeePercent { get; set; }
    public int? GracePeriodDays { get; set; }
    public decimal? FixedAmount { get; set; }
    public decimal? FeePerUnit { get; set; }
    public bool IsOverride { get; set; }
}

public class SellerProductFeeBulkRequest
{
    public string FeeCode { get; set; } = string.Empty;
    public bool ApplyToAll { get; set; }
    public List<int> ProductIds { get; set; } = [];
    public SellerProductFeeUpsertRequest Template { get; set; } = new();
}

public class SellerProductFeeDto : SellerProductFeeUpsertRequest
{
    public int SellerId { get; set; }
}

public record FeeCalculationRequest(
    string ActionType,
    int? ProductId,
    int? SellerId,
    decimal NotionalAmount,
    decimal Quantity,
    decimal ClosePrice,
    int DaysHeldAfterGrace);

public record FeeLineDto(
    string FeeCode,
    string FeeName,
    string CalculationMode,
    decimal BaseAmount,
    decimal Quantity,
    decimal? AppliedRate,
    decimal AppliedValue,
    bool IsDiscount,
    int DisplayOrder);

public record FeeCalculationResultDto(
    decimal TotalFees,
    decimal TotalDiscounts,
    decimal NetFees,
    IReadOnlyList<FeeLineDto> Lines);
