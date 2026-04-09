using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Transactions;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class TransactionHistoryService(ITransactionHistoryReadRepository transactionHistoryReadRepository) : ITransactionHistoryService
{
    public Task<PagedResult<TransactionHistoryDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => transactionHistoryReadRepository.GetByUserIdAsync(userId, pageNumber, pageSize, cancellationToken);
}
