namespace TPSS.GoldWallet.Application.DTOs;

public sealed record CartItemDto(Guid ProductId, string ProductName, int Quantity, decimal UnitPrice, decimal LineTotal, string Currency);
