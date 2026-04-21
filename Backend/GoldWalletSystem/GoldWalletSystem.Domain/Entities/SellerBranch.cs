namespace GoldWalletSystem.Domain.Entities;

public class SellerBranch : BaseEntity
{
    public int SellerId { get; set; }
    public string BranchName { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string FullAddress { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool IsMainBranch { get; set; }

    public Seller Seller { get; set; } = null!;
}
