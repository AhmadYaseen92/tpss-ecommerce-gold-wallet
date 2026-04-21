namespace GoldWalletSystem.Domain.Entities;

public class SellerBankAccount : BaseEntity
{
    public int SellerId { get; set; }
    public string BankName { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string IBAN { get; set; } = string.Empty;
    public string SwiftCode { get; set; } = string.Empty;
    public string BankCountry { get; set; } = string.Empty;
    public string BankCity { get; set; } = string.Empty;
    public string BranchName { get; set; } = string.Empty;
    public string BranchAddress { get; set; } = string.Empty;
    public string Currency { get; set; } = string.Empty;
    public bool IsMainAccount { get; set; }

    public Seller Seller { get; set; } = null!;
}
