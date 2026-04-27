using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Products;

public sealed record EnumItemDto(int Value, string Name);

public sealed class ProductManagementDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Sku { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public string VideoUrl { get; set; } = string.Empty;
    public ProductCategory Category { get; set; }
    public ProductMaterialType MaterialType { get; set; }
    public ProductFormType FormType { get; set; }
    public string DisplayCategoryLabel { get; set; } = string.Empty;
    public ProductPricingMode PricingMode { get; set; }
    public ProductPurityKarat PurityKarat { get; set; }
    public decimal PurityFactor { get; set; }
    public decimal WeightValue { get; set; }
    public ProductWeightUnit WeightUnit { get; set; }
    public decimal BaseMarketPrice { get; set; }
    public decimal AutoPrice { get; set; }
    public decimal FixedPrice { get; set; }
    public decimal SellPrice { get; set; }
    public decimal OfferPercent { get; set; }
    public decimal OfferNewPrice { get; set; }
    public ProductOfferType OfferType { get; set; }
    public bool IsHasOffer { get; set; }
    public int AvailableStock { get; set; }
    public bool IsActive { get; set; }
    public int SellerId { get; set; }
}

public sealed class MarketPriceConfigDto
{
    public decimal GoldPerOunce { get; set; }
    public decimal SilverPerOunce { get; set; }
    public decimal DiamondPerCarat { get; set; }
}
