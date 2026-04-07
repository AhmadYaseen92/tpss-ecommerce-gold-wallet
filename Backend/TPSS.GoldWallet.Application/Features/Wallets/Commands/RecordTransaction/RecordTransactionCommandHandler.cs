using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Domain.Enums;

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

        var isDebit = request.Type is WalletTransactionType.Withdrawal or WalletTransactionType.Purchase;
        var newBalance = isDebit ? wallet.Balance - request.Amount : wallet.Balance + request.Amount;

        if (newBalance < 0)
        {
            throw new InvalidOperationException("Insufficient balance.");
        }

        wallet.SetBalance(newBalance);
        wallet.AddTransaction(new WalletTransaction(wallet.Id, request.Amount, wallet.Currency, request.Type, request.Reference));

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
