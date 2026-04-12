using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class Product : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Sku { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public ProductCategory Category { get; set; } = ProductCategory.Gold;
    public decimal WeightValue { get; set; }
    public ProductWeightUnit WeightUnit { get; set; } = ProductWeightUnit.Gram;
    public decimal Price { get; set; }
    public int AvailableStock { get; set; }
    public bool IsActive { get; set; } = true;
    public int SellerId { get; set; }

    public Seller Seller { get; set; } = null!;
}
