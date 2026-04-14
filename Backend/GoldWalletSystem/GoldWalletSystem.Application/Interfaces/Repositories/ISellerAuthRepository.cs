using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface ISellerAuthRepository
{
    Task<Seller?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetUserBySellerIdAsync(int sellerId, CancellationToken cancellationToken = default);
}
