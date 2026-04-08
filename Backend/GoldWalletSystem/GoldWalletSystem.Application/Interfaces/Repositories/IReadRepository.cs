using GoldWalletSystem.Application.DTOs.Common;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IReadRepository<T>
{
    Task<PagedResult<T>> GetPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
}
