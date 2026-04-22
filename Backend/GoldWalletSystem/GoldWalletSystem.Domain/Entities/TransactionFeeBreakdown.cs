namespace GoldWalletSystem.Domain.Entities;

public class TransactionFeeBreakdown : BaseEntity
{
    public int? TransactionHistoryId { get; set; }
    public int? WalletActionId { get; set; }
    public int? ProductId { get; set; }
    public int? SellerId { get; set; }
    public string FeeCode { get; set; } = string.Empty;
    public string FeeName { get; set; } = string.Empty;
    public string CalculationMode { get; set; } = string.Empty;
    public decimal BaseAmount { get; set; }
    public decimal Quantity { get; set; }
    public decimal? AppliedRate { get; set; }
    public decimal AppliedValue { get; set; }
    public string Currency { get; set; } = "USD";
    public string SourceType { get; set; } = string.Empty;
    public string ConfigSnapshotJson { get; set; } = string.Empty;
    public bool IsDiscount { get; set; }
    public int DisplayOrder { get; set; }
}
