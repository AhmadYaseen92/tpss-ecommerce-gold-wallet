namespace TPSS.GoldWallet.Application.DTOs;

public sealed record ProductDto(Guid Id, string Sku, string Name, string Description, decimal Price, string Currency);
