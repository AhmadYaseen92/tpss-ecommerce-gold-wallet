namespace GoldWalletSystem.Domain.Entities;

public class SellerProductFee : BaseEntity
{
    public int SellerId { get; set; }
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

    public Product? Product { get; set; }
    public Seller? Seller { get; set; }
}
