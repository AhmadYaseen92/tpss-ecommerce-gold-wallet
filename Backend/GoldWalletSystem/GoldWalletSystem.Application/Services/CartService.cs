using GoldWalletSystem.Application.DTOs.Cart;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Services;

public class CartService(ICartRepository cartRepository, IProductRepository productRepository) : ICartService
{
    public async Task<CartDto> GetCartByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var updated = false;

        foreach (var item in cart.Items.ToList())
        {
            var availableStock = item.Product?.AvailableStock ?? 0;
            if (availableStock <= 0)
            {
                cart.Items.Remove(item);
                updated = true;
                continue;
            }

            if (item.Quantity > availableStock)
            {
                item.Quantity = availableStock;
                item.LineTotal = item.UnitPrice * item.Quantity;
                item.UpdatedAtUtc = DateTime.UtcNow;
                updated = true;
            }
        }

        if (updated)
        {
            await cartRepository.SaveChangesAsync(cancellationToken);
        }

        return Map(cart);
    }

    public async Task<CartDto> AddItemAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0)
            throw new InvalidOperationException("Quantity should be greater than 0.");

        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var product = await productRepository.GetByIdAsync(productId, cancellationToken)
            ?? throw new InvalidOperationException($"Product id {productId} does not exist.");

        var existingItem = cart.Items.FirstOrDefault(x => x.ProductId == productId);
        var totalRequested = (existingItem?.Quantity ?? 0) + quantity;
        EnsureStockAvailability(product.AvailableStock, totalRequested, productId);

        if (existingItem is null)
        {
            cart.Items.Add(new CartItem
            {
                ProductId = productId,
                SellerId = product.SellerId,
                Category = product.Category,
                Quantity = quantity,
                UnitPrice = product.Price,
                LineTotal = product.Price * quantity,
            });
        }
        else
        {
            existingItem.Quantity += quantity;
            existingItem.LineTotal = existingItem.Quantity * existingItem.UnitPrice;
            existingItem.UpdatedAtUtc = DateTime.UtcNow;
        }

        await cartRepository.SaveChangesAsync(cancellationToken);
        return Map(cart);
    }

    public async Task<CartDto> UpdateItemQuantityAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default)
    {
        if (quantity < 0)
            throw new InvalidOperationException("Quantity should not be negative.");

        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var existingItem = cart.Items.FirstOrDefault(x => x.ProductId == productId)
            ?? throw new InvalidOperationException($"Product id {productId} is not in cart.");
        var product = await productRepository.GetByIdAsync(productId, cancellationToken)
            ?? throw new InvalidOperationException($"Product id {productId} does not exist.");

        if (quantity == 0)
        {
            cart.Items.Remove(existingItem);
        }
        else
        {
            EnsureStockAvailability(product.AvailableStock, quantity, productId);
            existingItem.Quantity = quantity;
            existingItem.LineTotal = quantity * existingItem.UnitPrice;
            existingItem.UpdatedAtUtc = DateTime.UtcNow;
        }

        await cartRepository.SaveChangesAsync(cancellationToken);
        return Map(cart);
    }

    public async Task<CartDto> RemoveItemAsync(int userId, int productId, CancellationToken cancellationToken = default)
    {
        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var existingItem = cart.Items.FirstOrDefault(x => x.ProductId == productId);

        if (existingItem is not null)
        {
            cart.Items.Remove(existingItem);
            await cartRepository.SaveChangesAsync(cancellationToken);
        }

        return Map(cart);
    }

    private static CartDto Map(Cart cart)
    {
        var items = cart.Items
            .Select(i => new CartItemDto(
                i.Id,
                i.ProductId,
                i.Product?.Name ?? $"Product #{i.ProductId}",
                i.Product?.Description ?? string.Empty,
                i.Product?.ImageUrl ?? string.Empty,
                i.SellerId ?? i.Product?.SellerId,
                i.Product?.Seller?.Name ?? string.Empty,
                i.Product?.AvailableStock ?? 0,
                i.UnitPrice,
                i.Product?.WeightValue ?? 0,
                i.Product is null ? string.Empty : i.Product.WeightUnit.ToString(),
                i.Quantity,
                i.LineTotal))
            .ToList();

        return new CartDto(cart.Id, cart.UserId, items, items.Sum(x => x.LineTotal));
    }

    private static void EnsureStockAvailability(int availableStock, int requestedQuantity, int productId)
    {
        if (availableStock <= 0)
            throw new InvalidOperationException($"Product id {productId} is out of stock.");

        if (requestedQuantity > availableStock)
            throw new InvalidOperationException($"Requested quantity {requestedQuantity} exceeds available stock {availableStock} for product id {productId}.");
    }
}
