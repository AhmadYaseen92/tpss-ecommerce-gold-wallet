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
        SetQuantity(quantity);
    }

    public Guid ProductId { get; private set; }
    public string ProductName { get; private set; } = string.Empty;
    public Money UnitPrice { get; private set; }
    public int Quantity { get; private set; }
    public Money LineTotal => UnitPrice.Multiply(Quantity);

    public void SetQuantity(int quantity)
    {
        if (quantity <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(quantity), "Quantity must be greater than zero.");
        }

        Quantity = quantity;
    }

    public void Increase(int amount)
    {
        if (amount <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(amount), "Increase amount must be greater than zero.");
        }

        Quantity += amount;
    }
}
