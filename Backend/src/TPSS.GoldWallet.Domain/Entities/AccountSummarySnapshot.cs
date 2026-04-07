using TPSS.GoldWallet.Domain.Common;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class AccountSummarySnapshot : Entity
{
    private AccountSummarySnapshot() { }

    public AccountSummarySnapshot(Guid customerId, decimal holdMarketValue, decimal goldValue, decimal silverValue, decimal jewelleryValue, decimal availableCash, decimal usdtBalance, decimal eDirhamBalance)
    {
        CustomerId = customerId;
        HoldMarketValue = holdMarketValue;
        GoldValue = goldValue;
        SilverValue = silverValue;
        JewelleryValue = jewelleryValue;
        AvailableCash = availableCash;
        UsdtBalance = usdtBalance;
        EDirhamBalance = eDirhamBalance;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public Guid CustomerId { get; private set; }
    public decimal HoldMarketValue { get; private set; }
    public decimal GoldValue { get; private set; }
    public decimal SilverValue { get; private set; }
    public decimal JewelleryValue { get; private set; }
    public decimal AvailableCash { get; private set; }
    public decimal UsdtBalance { get; private set; }
    public decimal EDirhamBalance { get; private set; }
    public DateTime CreatedAtUtc { get; private set; }
}
