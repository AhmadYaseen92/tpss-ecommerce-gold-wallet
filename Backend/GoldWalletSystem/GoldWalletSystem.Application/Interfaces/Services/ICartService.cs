using GoldWalletSystem.Application.DTOs.Cart;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ICartService
{
    Task<CartDto> GetCartByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<CartDto> AddItemAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default);
    Task<CartDto> UpdateItemQuantityAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default);
    Task<CartDto> RemoveItemAsync(int userId, int productId, CancellationToken cancellationToken = default);
}
