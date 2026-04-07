namespace TPSS.GoldWallet.Application.DTOs;

public sealed record WalletDto(Guid CustomerId, decimal Balance, string Currency, IReadOnlyList<WalletTransactionDto> Transactions);

public sealed record WalletTransactionDto(decimal Amount, string Currency, string Type, string Reference, DateTime CreatedAtUtc);
