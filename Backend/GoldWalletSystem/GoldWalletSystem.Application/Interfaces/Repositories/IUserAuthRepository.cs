using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IUserAuthRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetByPhoneAsync(string phoneNumber, CancellationToken cancellationToken = default);
    Task<User?> GetByIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<Seller?> GetSellerByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<Seller?> GetSellerByIdAsync(int sellerId, CancellationToken cancellationToken = default);
    Task<Seller> AddSellerProfileAsync(Seller seller, CancellationToken cancellationToken = default);
    Task<(User User, Seller? Seller)> AddWithOptionalSellerAsync(User user, UserProfile? profile, Seller? seller, CancellationToken cancellationToken = default);
    Task<User> AddAsync(User user, UserProfile? profile = null, CancellationToken cancellationToken = default);
    Task ActivateUserAsync(int userId, CancellationToken cancellationToken = default);
    Task UpdatePasswordAsync(int userId, string passwordHash, CancellationToken cancellationToken = default);
    Task AddRefreshTokenAsync(RefreshToken refreshToken, CancellationToken cancellationToken = default);
    Task<RefreshToken?> GetActiveRefreshTokenAsync(int userId, string tokenHash, CancellationToken cancellationToken = default);
    Task RevokeRefreshTokenAsync(int refreshTokenId, CancellationToken cancellationToken = default);
    Task RevokeAllRefreshTokensAsync(int userId, CancellationToken cancellationToken = default);
}
