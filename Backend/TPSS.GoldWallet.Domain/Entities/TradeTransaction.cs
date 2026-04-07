using TPSS.GoldWallet.Domain.Common;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class TradeTransaction : Entity
{
    private TradeTransaction() { }

    public TradeTransaction(Guid customerId, string title, string type, string status, DateTime dateUtc, string amount, string sellerName, string? secondaryAmount)
    {
        CustomerId = customerId;
        Title = title;
        Type = type;
        Status = status;
        DateUtc = dateUtc;
        Amount = amount;
        SellerName = sellerName;
        SecondaryAmount = secondaryAmount;
    }

    public Guid CustomerId { get; private set; }
    public string Title { get; private set; } = string.Empty;
    public string Type { get; private set; } = string.Empty;
    public string Status { get; private set; } = string.Empty;
    public DateTime DateUtc { get; private set; }
    public string Amount { get; private set; } = string.Empty;
    public string SellerName { get; private set; } = string.Empty;
    public string? SecondaryAmount { get; private set; }
}
