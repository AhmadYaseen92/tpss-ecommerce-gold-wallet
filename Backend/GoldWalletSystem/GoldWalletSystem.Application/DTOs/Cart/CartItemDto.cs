namespace GoldWalletSystem.Application.DTOs.Cart;

public sealed record CartItemDto(int CartItemId, int ProductId, string ProductName, decimal UnitPrice, int Quantity, decimal LineTotal);
