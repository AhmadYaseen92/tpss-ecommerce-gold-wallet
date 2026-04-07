using TPSS.GoldWallet.Domain.Common;
using TPSS.GoldWallet.Domain.ValueObjects;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class Cart : Entity
{
    private readonly List<CartItem> _items = [];

    private Cart() { }

    public Cart(Guid customerId)
    {
        CustomerId = customerId;
    }

    public Guid CustomerId { get; private set; }
    public IReadOnlyCollection<CartItem> Items => _items.AsReadOnly();

    public Money Subtotal => _items.Count == 0
        ? Money.Zero()
        : _items.Select(x => x.LineTotal).Aggregate((left, right) => left.Add(right));

    public void AddItem(Product product, int quantity)
    {
        var existing = _items.SingleOrDefault(x => x.ProductId == product.Id);
        if (existing is null)
        {
            _items.Add(new CartItem(product.Id, product.Name, product.Price, quantity));
            return;
        }

        existing.Increase(quantity);
    }

    public void RemoveItem(Guid productId)
    {
        var existing = _items.SingleOrDefault(x => x.ProductId == productId);
        if (existing is null)
        {
            return;
        }

        _items.Remove(existing);
    }
}
