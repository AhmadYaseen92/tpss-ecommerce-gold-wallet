using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Products;

public sealed record ProductDto(
    int Id,
    string Name,
    string Sku,
    string Description,
    string ImageUrl,
    ProductCategory Category,
    ProductMaterialType MaterialType,
    ProductFormType FormType,
    string DisplayCategoryLabel,
    ProductPricingMode PricingMode,
    ProductPurityKarat PurityKarat,
    decimal PurityFactor,
    decimal WeightValue,
    ProductWeightUnit WeightUnit,
    decimal BaseMarketPrice,
    decimal DeliveryFee,
    decimal StorageFee,
    decimal ServiceCharge,
    decimal OfferPercent,
    decimal OfferNewPrice,
    ProductOfferType OfferType,
    decimal Price,
    decimal FinalPrice,
    int AvailableStock,
    int SellerId,
    string SellerName);
