namespace TPSS.GoldWallet.Application.DTOs;

public sealed record CartDto(Guid CustomerId, IReadOnlyList<CartItemDto> Items, decimal Subtotal, string Currency);
