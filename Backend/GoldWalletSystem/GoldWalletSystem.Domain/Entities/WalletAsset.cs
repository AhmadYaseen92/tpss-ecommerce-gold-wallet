using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class WalletAsset : BaseEntity
{
    public int WalletId { get; set; }
    public int? ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? ProductSku { get; set; }
    public string? ProductImageUrl { get; set; }
    public string MaterialType { get; set; } = string.Empty;
    public string FormType { get; set; } = string.Empty;
    public string? PurityKarat { get; set; }
    public string? PurityDisplayName { get; set; }
    public decimal WeightValue { get; set; }
    public string WeightUnit { get; set; } = "gram";
    public AssetType AssetType { get; set; }
    public ProductCategory Category { get; set; } = ProductCategory.Gold;
    public int? SellerId { get; set; }
    public decimal Weight { get; set; }
    public string Unit { get; set; } = "gram";
    public decimal Purity { get; set; }
    public int Quantity { get; set; }
    public decimal AverageBuyPrice { get; set; }
    public decimal CurrentMarketPrice { get; set; }
    public decimal AcquisitionSubTotalAmount { get; set; }
    public decimal AcquisitionFeesAmount { get; set; }
    public decimal AcquisitionDiscountAmount { get; set; }
    public decimal AcquisitionFinalAmount { get; set; }
    public int? LastTransactionHistoryId { get; set; }
    public int? SourceInvoiceId { get; set; }
    public string SellerName { get; set; } = string.Empty;

    public Wallet Wallet { get; set; } = null!;
}
