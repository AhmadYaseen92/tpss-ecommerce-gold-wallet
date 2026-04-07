using TPSS.GoldWallet.Domain.Common;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class NotificationMessage : Entity
{
    private NotificationMessage() { }

    public NotificationMessage(Guid customerId, string title, string description, string category, bool isRead = false)
    {
        CustomerId = customerId;
        Title = title;
        Description = description;
        Category = category;
        IsRead = isRead;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public Guid CustomerId { get; private set; }
    public string Title { get; private set; } = string.Empty;
    public string Description { get; private set; } = string.Empty;
    public string Category { get; private set; } = string.Empty;
    public bool IsRead { get; private set; }
    public DateTime CreatedAtUtc { get; private set; }
}
