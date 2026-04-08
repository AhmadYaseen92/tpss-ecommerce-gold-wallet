using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class Order : BaseEntity
{
    public int UserId { get; set; }
    public OrderType OrderType { get; set; }
    public OrderStatus Status { get; set; } = OrderStatus.Pending;

    public AssetType AssetType { get; set; }
    public decimal Weight { get; set; }
    public string Unit { get; set; } = "gram";
    public decimal UnitPrice { get; set; }
    public decimal TotalAmount { get; set; }

    public string? OtpCode { get; set; }
    public DateTime? PriceLockedUntilUtc { get; set; }

    public User User { get; set; } = null!;
}