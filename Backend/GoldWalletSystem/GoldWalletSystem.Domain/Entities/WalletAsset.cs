using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class WalletAsset : BaseEntity
{
    public int WalletId { get; set; }
    public AssetType AssetType { get; set; }
    public decimal Weight { get; set; }
    public string Unit { get; set; } = "gram";
    public decimal Purity { get; set; }
    public int Quantity { get; set; }
    public decimal AverageBuyPrice { get; set; }
    public decimal CurrentMarketPrice { get; set; }
    public string SellerName { get; set; } = string.Empty;

    public Wallet Wallet { get; set; } = null!;
}
