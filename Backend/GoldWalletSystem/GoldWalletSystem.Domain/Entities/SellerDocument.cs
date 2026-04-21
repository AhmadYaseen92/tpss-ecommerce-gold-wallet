namespace GoldWalletSystem.Domain.Entities;

public class SellerDocument : BaseEntity
{
    public int SellerId { get; set; }
    public string DocumentType { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public bool IsRequired { get; set; }
    public DateTime UploadedAtUtc { get; set; }
    public string? RelatedEntityType { get; set; }
    public int? RelatedEntityId { get; set; }

    public Seller Seller { get; set; } = null!;
}
