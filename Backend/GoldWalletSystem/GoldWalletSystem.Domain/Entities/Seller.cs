using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class Seller : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }
    public bool IsActive { get; set; }

    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Street { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;

    public string CompanyName { get; set; } = string.Empty;
    public string TradeLicenseNumber { get; set; } = string.Empty;
    public string VatNumber { get; set; } = string.Empty;

    public string NationalIdNumber { get; set; } = string.Empty;

    public string BankName { get; set; } = string.Empty;
    public string IBAN { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;

    public string NationalIdFrontPath { get; set; } = string.Empty;
    public string NationalIdBackPath { get; set; } = string.Empty;
    public string TradeLicensePath { get; set; } = string.Empty;

    public KycStatus KycStatus { get; set; } = KycStatus.Pending;
    public DateTime? ReviewedAtUtc { get; set; }
    public string? ReviewNotes { get; set; }

    public decimal? GoldPrice { get; set; }
    public decimal? SilverPrice { get; set; }
    public decimal? DiamondPrice { get; set; }

    public ICollection<User> Users { get; set; } = new List<User>();
    public ICollection<Product> Products { get; set; } = new List<Product>();
}
