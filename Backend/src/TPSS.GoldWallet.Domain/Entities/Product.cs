using TPSS.GoldWallet.Domain.Common;
using TPSS.GoldWallet.Domain.ValueObjects;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class Product : Entity
{
    private Product() { }

    public Product(string sku, string name, string description, Money price, bool isActive = true)
    {
        Sku = sku;
        Name = name;
        Description = description;
        Price = price;
        IsActive = isActive;
    }

    public string Sku { get; private set; } = string.Empty;
    public string Name { get; private set; } = string.Empty;
    public string Description { get; private set; } = string.Empty;
    public Money Price { get; private set; }
    public bool IsActive { get; private set; }

    public void Deactivate() => IsActive = false;
}
