using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Transactions;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface ITransactionHistoryReadRepository
{
    Task<PagedResult<TransactionHistoryDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
}
