using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IUserAuthRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetByIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<Seller?> GetSellerByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<Seller?> GetSellerByIdAsync(int sellerId, CancellationToken cancellationToken = default);
    Task<Seller> AddSellerProfileAsync(Seller seller, CancellationToken cancellationToken = default);
    Task<User> AddAsync(User user, UserProfile? profile = null, CancellationToken cancellationToken = default);
    Task ActivateUserAsync(int userId, CancellationToken cancellationToken = default);
    Task UpdatePasswordAsync(int userId, string passwordHash, CancellationToken cancellationToken = default);
}
