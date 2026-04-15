namespace GoldWalletSystem.Application.Realtime;

public sealed record MarketplaceRealtimeEvent(
    string Entity,
    string Action,
    string? ItemId = null,
    int? UserId = null,
    int? SellerId = null,
    DateTime? OccurredAtUtc = null,
    Dictionary<string, string>? Metadata = null)
{
    public DateTime OccurredAtUtc { get; init; } = OccurredAtUtc ?? DateTime.UtcNow;

    public static MarketplaceRealtimeEvent Build(
        string entity,
        string action,
        string? itemId = null,
        int? userId = null,
        int? sellerId = null,
        Dictionary<string, string>? metadata = null)
        => new(entity, action, itemId, userId, sellerId, DateTime.UtcNow, metadata);
}

public static class MarketplaceRealtimeEntities
{
    public const string Product = "product";
    public const string Request = "request";
    public const string Wallet = "wallet";
    public const string Order = "order";
    public const string Invoice = "invoice";
    public const string Investor = "investor";
    public const string Seller = "seller";
    public const string Notification = "notification";
    public const string Dashboard = "dashboard";
}
