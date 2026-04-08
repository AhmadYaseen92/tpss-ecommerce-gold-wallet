namespace GoldWalletSystem.Application.DTOs.Cart;

public sealed record CartDto(int CartId, int UserId, IReadOnlyList<CartItemDto> Items, decimal TotalAmount);
