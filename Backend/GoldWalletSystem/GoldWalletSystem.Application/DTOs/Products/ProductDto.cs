using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Products;

public sealed record ProductDto(
    int Id,
    string Name,
    string Sku,
    string Description,
    string ImageUrl,
    ProductCategory Category,
    decimal Price,
    int AvailableStock,
    int SellerId,
    string SellerName);
