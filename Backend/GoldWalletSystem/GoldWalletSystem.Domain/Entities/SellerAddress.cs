namespace GoldWalletSystem.Domain.Entities;

public class SellerAddress : BaseEntity
{
    public int SellerId { get; set; }
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Street { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;

    public Seller Seller { get; set; } = null!;
}
