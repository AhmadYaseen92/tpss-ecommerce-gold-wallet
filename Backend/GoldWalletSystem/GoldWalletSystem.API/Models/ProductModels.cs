using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.API.Models;

public sealed record EnumItemDto(int Value, string Name);

public sealed class ProductManagementDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Sku { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
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
    public decimal ManualSellPrice { get; set; }
    public decimal DeliveryFee { get; set; }
    public decimal StorageFee { get; set; }
    public decimal ServiceCharge { get; set; }
    public decimal OfferPercent { get; set; }
    public decimal OfferNewPrice { get; set; }
    public ProductOfferType OfferType { get; set; }
    public bool IsHasOffer { get; set; }
    public decimal Price { get; set; }
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

public sealed class ProductUpsertRequest
{
    public string Name { get; set; } = string.Empty;
    public string Sku { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public IFormFile? Image { get; set; }
    public string? ExistingImageUrl { get; set; }
    public ProductMaterialType MaterialType { get; set; } = ProductMaterialType.Gold;
    public ProductFormType FormType { get; set; } = ProductFormType.Jewelry;
    public ProductPricingMode PricingMode { get; set; } = ProductPricingMode.Auto;
    public ProductPurityKarat PurityKarat { get; set; } = ProductPurityKarat.None;
    public decimal PurityFactor { get; set; }
    public decimal WeightValue { get; set; }
    public ProductWeightUnit WeightUnit { get; set; } = ProductWeightUnit.Gram;
    public decimal ManualSellPrice { get; set; }
    public decimal DeliveryFee { get; set; }
    public decimal StorageFee { get; set; }
    public decimal ServiceCharge { get; set; }
    public decimal OfferPercent { get; set; }
    public decimal OfferNewPrice { get; set; }
    public ProductOfferType OfferType { get; set; } = ProductOfferType.None;
    public int AvailableStock { get; set; }
    public bool IsActive { get; set; } = true;
    public int? SellerId { get; set; }
}
