namespace GoldWalletSystem.Domain.Entities;

public class SystemFeeType : BaseEntity
{
    public string FeeCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool IsEnabled { get; set; }
    public bool AppliesToBuy { get; set; }
    public bool AppliesToSell { get; set; }
    public bool AppliesToPickup { get; set; }
    public bool AppliesToTransfer { get; set; }
    public bool AppliesToGift { get; set; }
    public bool AppliesToInvoice { get; set; }
    public bool AppliesToReports { get; set; }
    public int SortOrder { get; set; }
}
