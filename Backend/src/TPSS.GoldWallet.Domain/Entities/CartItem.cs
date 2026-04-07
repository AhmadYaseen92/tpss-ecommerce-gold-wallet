using TPSS.GoldWallet.Domain.Common;
using TPSS.GoldWallet.Domain.ValueObjects;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class CartItem : Entity
{
    private CartItem() { }

    public CartItem(Guid productId, string productName, Money unitPrice, int quantity)
    {
        ProductId = productId;
        ProductName = productName;
        UnitPrice = unitPrice;
        Quantity = quantity;
    }

    public Guid ProductId { get; private set; }
    public string ProductName { get; private set; } = string.Empty;
    public Money UnitPrice { get; private set; }
    public int Quantity { get; private set; }
}
