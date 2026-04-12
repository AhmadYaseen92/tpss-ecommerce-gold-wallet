namespace GoldWalletSystem.Application.DTOs.Cart;

public sealed record CartItemDto(
    int CartItemId,
    int ProductId,
    string ProductName,
    string SellerName,
    decimal UnitPrice,
    int Quantity,
    decimal LineTotal);
