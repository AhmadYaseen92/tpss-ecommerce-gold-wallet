namespace GoldWalletSystem.Application.DTOs.Cart;

public sealed record CartItemDto(
    int CartItemId,
    int ProductId,
    string ProductName,
    string ProductDescription,
    string ProductImageUrl,
    int SellerId,
    string SellerName,
    int AvailableStock,
    decimal UnitPrice,
    decimal WeightValue,
    string WeightUnit,
    int Quantity,
    decimal LineTotal);
