namespace GoldWalletSystem.Domain.Entities;

public class AdminTransactionFee : BaseEntity
{
    public string FeeCode { get; set; } = string.Empty;
    public bool IsEnabled { get; set; }
    public string CalculationMode { get; set; } = string.Empty;
    public decimal? RatePercent { get; set; }
    public decimal? FixedAmount { get; set; }
    public bool AppliesToBuy { get; set; }
    public bool AppliesToSell { get; set; }
    public bool AppliesToPickup { get; set; }
    public bool AppliesToTransfer { get; set; }
    public bool AppliesToGift { get; set; }
}
