namespace GoldWalletSystem.Domain.Entities;

public class SellerManager : BaseEntity
{
    public int SellerId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string PositionTitle { get; set; } = string.Empty;
    public string Nationality { get; set; } = string.Empty;
    public string MobileNumber { get; set; } = string.Empty;
    public string EmailAddress { get; set; } = string.Empty;
    public string IdType { get; set; } = string.Empty;
    public string IdNumber { get; set; } = string.Empty;
    public DateOnly? IdExpiryDate { get; set; }
    public bool IsPrimary { get; set; }

    public Seller Seller { get; set; } = null!;
}
