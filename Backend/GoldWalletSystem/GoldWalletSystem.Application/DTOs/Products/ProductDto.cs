using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Products;

public sealed record ProductDto(
    int Id,
    string Name,
    string Sku,
    string Description,
    string ImageUrl,
    ProductCategory Category,
    PricingMaterialType PricingMaterialType,
    ProductPricingMode PricingMode,
    decimal WeightValue,
    ProductWeightUnit WeightUnit,
    decimal? PurityKarat,
    decimal MarketUnitPrice,
    decimal DeliveryFee,
    decimal StorageFee,
    decimal ServiceCharge,
    decimal FinalSellPrice,
    decimal Price,
    int AvailableStock,
    int SellerId,
    string SellerName,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);
