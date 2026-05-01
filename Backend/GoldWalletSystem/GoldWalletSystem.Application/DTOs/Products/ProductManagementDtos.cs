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
    public decimal AskPrice { get; set; }
    public string CurrencyCode { get; set; } = "USD";
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
    public decimal GoldBidPerOunce { get; set; }
    public decimal GoldAskPerOunce { get; set; }
    public decimal SilverBidPerOunce { get; set; }
    public decimal SilverAskPerOunce { get; set; }
    public decimal DiamondPerCarat { get; set; }
}
