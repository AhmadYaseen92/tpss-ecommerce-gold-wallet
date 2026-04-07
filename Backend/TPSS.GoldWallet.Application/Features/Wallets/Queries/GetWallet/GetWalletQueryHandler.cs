using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Features.Wallets.Queries.GetWallet;

public sealed class GetWalletQueryHandler(IWalletRepository walletRepository)
    : IRequestHandler<GetWalletQuery, WalletDto>
{
    public async Task<WalletDto> Handle(GetWalletQuery request, CancellationToken cancellationToken)
    {
        var wallet = await walletRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken)
                     ?? new WalletAccount(request.CustomerId, "USD");

        return new WalletDto(
            wallet.CustomerId,
            wallet.Balance,
            wallet.Currency,
            wallet.Transactions
                .OrderByDescending(x => x.CreatedAtUtc)
                .Select(x => new WalletTransactionDto(x.Amount, x.Currency, x.Type.ToString(), x.Reference, x.CreatedAtUtc))
                .ToList());
    }
}
