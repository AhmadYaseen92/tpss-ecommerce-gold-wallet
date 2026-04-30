using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class Seller : BaseEntity
{
    public int UserId { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public string CompanyCode { get; set; } = string.Empty;
    public string CommercialRegistrationNumber { get; set; } = string.Empty;
    public string VatNumber { get; set; } = string.Empty;
    public string BusinessActivity { get; set; } = string.Empty;
    public DateOnly? EstablishedDate { get; set; }
    public string CompanyPhone { get; set; } = string.Empty;
    public string CompanyEmail { get; set; } = string.Empty;
    public string? Website { get; set; }
    public string? Description { get; set; }
    public string MarketType { get; set; } = "UAE";
    public bool IsActive { get; set; }
    public KycStatus KycStatus { get; set; } = KycStatus.UnderReview;
    public DateTime? ReviewedAtUtc { get; set; }
    public string? ReviewNotes { get; set; }
    public decimal? GoldPrice { get; set; }
    public decimal? SilverPrice { get; set; }
    public decimal? DiamondPrice { get; set; }

    public User User { get; set; } = null!;
    public SellerAddress? Address { get; set; }
    public ICollection<SellerManager> Managers { get; set; } = new List<SellerManager>();
    public ICollection<SellerBranch> Branches { get; set; } = new List<SellerBranch>();
    public ICollection<SellerBankAccount> BankAccounts { get; set; } = new List<SellerBankAccount>();
    public ICollection<SellerDocument> Documents { get; set; } = new List<SellerDocument>();
    public ICollection<Product> Products { get; set; } = new List<Product>();
}
