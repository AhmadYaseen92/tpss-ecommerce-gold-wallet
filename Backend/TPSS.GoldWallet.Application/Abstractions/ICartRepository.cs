using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface ICartRepository
{
    Task<Cart?> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
    Task AddAsync(Cart cart, CancellationToken cancellationToken = default);
    void Update(Cart cart);
}
