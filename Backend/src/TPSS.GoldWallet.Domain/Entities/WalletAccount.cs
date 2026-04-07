using TPSS.GoldWallet.Domain.Common;
using TPSS.GoldWallet.Domain.Enums;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class WalletAccount : Entity
{
    private readonly List<WalletTransaction> _transactions = [];

    private WalletAccount() { }

    public WalletAccount(Guid customerId, string currency)
    {
        CustomerId = customerId;
        Currency = currency;
        Balance = 0m;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public Guid CustomerId { get; private set; }
    public string Currency { get; private set; } = "USD";
    public decimal Balance { get; private set; }
    public DateTime CreatedAtUtc { get; private set; }
    public IReadOnlyCollection<WalletTransaction> Transactions => _transactions.AsReadOnly();

    public WalletTransaction RecordTransaction(decimal amount, WalletTransactionType type, string reference)
    {
        if (amount <= 0) throw new ArgumentOutOfRangeException(nameof(amount));

        if (type is WalletTransactionType.Withdrawal or WalletTransactionType.Purchase)
        {
            if (Balance < amount) throw new InvalidOperationException("Insufficient balance.");
            Balance -= amount;
        }
        else
        {
            Balance += amount;
        }

        var transaction = new WalletTransaction(Id, amount, Currency, type, reference);
        _transactions.Add(transaction);
        return transaction;
    }
}
