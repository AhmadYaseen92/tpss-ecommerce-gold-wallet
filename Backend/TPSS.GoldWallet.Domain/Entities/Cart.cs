using TPSS.GoldWallet.Domain.Common;

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

    public void ReplaceItems(IEnumerable<CartItem> items)
    {
        _items.Clear();
        _items.AddRange(items);
    }
}
