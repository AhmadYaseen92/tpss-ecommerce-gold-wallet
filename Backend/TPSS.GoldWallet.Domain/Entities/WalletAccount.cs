using TPSS.GoldWallet.Domain.Common;

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

    public void SetBalance(decimal balance) => Balance = balance;

    public void AddTransaction(WalletTransaction transaction) => _transactions.Add(transaction);
}
