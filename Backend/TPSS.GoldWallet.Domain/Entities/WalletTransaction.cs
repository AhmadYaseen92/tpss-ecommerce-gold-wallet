using TPSS.GoldWallet.Domain.Common;
using TPSS.GoldWallet.Domain.Enums;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class WalletTransaction : Entity
{
    private WalletTransaction() { }

    public WalletTransaction(Guid walletAccountId, decimal amount, string currency, WalletTransactionType type, string reference)
    {
        WalletAccountId = walletAccountId;
        Amount = amount;
        Currency = currency;
        Type = type;
        Reference = reference;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public Guid WalletAccountId { get; private set; }
    public decimal Amount { get; private set; }
    public string Currency { get; private set; } = "USD";
    public WalletTransactionType Type { get; private set; }
    public string Reference { get; private set; } = string.Empty;
    public DateTime CreatedAtUtc { get; private set; }
}
