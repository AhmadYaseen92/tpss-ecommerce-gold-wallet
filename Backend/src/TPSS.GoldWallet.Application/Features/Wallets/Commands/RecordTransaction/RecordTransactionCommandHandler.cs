using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Features.Wallets.Commands.RecordTransaction;

public sealed class RecordTransactionCommandHandler(
    IWalletRepository walletRepository,
    IAuditLogRepository auditLogRepository,
    IUnitOfWork unitOfWork)
    : IRequestHandler<RecordTransactionCommand, WalletDto>
{
    public async Task<WalletDto> Handle(RecordTransactionCommand request, CancellationToken cancellationToken)
    {
        var wallet = await walletRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken);
        if (wallet is null)
        {
            wallet = new WalletAccount(request.CustomerId, "USD");
            await walletRepository.AddAsync(wallet, cancellationToken);
        }

        var transaction = wallet.RecordTransaction(request.Amount, request.Type, request.Reference);
        walletRepository.Update(wallet);

        await auditLogRepository.AddAsync(new AuditLog(request.CustomerId, "wallet.transaction", "wallet", request.Type.ToString(), "system"), cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new WalletDto(
            wallet.CustomerId,
            wallet.Balance,
            wallet.Currency,
            wallet.Transactions.Select(x => new WalletTransactionDto(x.Amount, x.Currency, x.Type.ToString(), x.Reference, x.CreatedAtUtc)).ToList());
    }
}
