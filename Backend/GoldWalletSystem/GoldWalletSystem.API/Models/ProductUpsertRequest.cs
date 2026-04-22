using GoldWalletSystem.Domain.Enums;
using Microsoft.AspNetCore.Http;

namespace GoldWalletSystem.API.Models;

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
    public decimal OfferPercent { get; set; }
    public decimal OfferNewPrice { get; set; }
    public ProductOfferType OfferType { get; set; } = ProductOfferType.None;
    public int AvailableStock { get; set; }
    public bool IsActive { get; set; } = true;
    public int? SellerId { get; set; }
}
