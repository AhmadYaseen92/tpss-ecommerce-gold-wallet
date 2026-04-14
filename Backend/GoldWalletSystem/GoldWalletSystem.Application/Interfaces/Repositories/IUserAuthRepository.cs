using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IUserAuthRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetByIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<Seller?> GetSellerByIdAsync(int sellerId, CancellationToken cancellationToken = default);
    Task<int> GetDefaultSellerIdAsync(CancellationToken cancellationToken = default);
    Task<Seller> AddSellerAsync(Seller seller, CancellationToken cancellationToken = default);
    Task<User> AddAsync(User user, UserProfile? profile = null, CancellationToken cancellationToken = default);
}
