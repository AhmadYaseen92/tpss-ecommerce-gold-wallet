using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class CartItem : BaseEntity
{
    public int CartId { get; set; }
    public int ProductId { get; set; }
    public int? SellerId { get; set; }
    public ProductCategory Category { get; set; } = ProductCategory.Gold;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineTotal { get; set; }

    public Cart Cart { get; set; } = null!;
    public Product Product { get; set; } = null!;
}
