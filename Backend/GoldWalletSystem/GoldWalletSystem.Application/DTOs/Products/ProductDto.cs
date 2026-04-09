namespace GoldWalletSystem.Application.DTOs.Products;

public sealed record ProductDto(int Id, string Name, string Sku, string Description, decimal Price, int AvailableStock);
