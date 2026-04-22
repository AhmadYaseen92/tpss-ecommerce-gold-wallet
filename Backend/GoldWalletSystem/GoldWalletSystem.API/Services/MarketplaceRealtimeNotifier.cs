using GoldWalletSystem.API.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace GoldWalletSystem.API.Services;

public interface IMarketplaceRealtimeNotifier
{
    Task BroadcastRefreshHintAsync(string reason, CancellationToken cancellationToken = default);
    Task NotifyWalletRefreshSignalAsync(
        int userId,
        string scope,
        string reason,
        int? walletAssetId = null,
        int? transactionId = null,
        CancellationToken cancellationToken = default);
}

public class MarketplaceRealtimeNotifier(IHubContext<MarketplaceHub> hubContext) : IMarketplaceRealtimeNotifier
{
    public Task BroadcastRefreshHintAsync(string reason, CancellationToken cancellationToken = default)
    {
        return hubContext.Clients.All.SendAsync("MarketplaceRefreshRequested", new
        {
            reason,
            triggeredAtUtc = DateTime.UtcNow
        }, cancellationToken);
    }

    public Task NotifyWalletRefreshSignalAsync(
        int userId,
        string scope,
        string reason,
        int? walletAssetId = null,
        int? transactionId = null,
        CancellationToken cancellationToken = default)
    {
        return hubContext.Clients.User(userId.ToString()).SendAsync("WalletRefreshSignal", new
        {
            scope,
            reason,
            walletAssetId,
            transactionId,
            triggeredAtUtc = DateTime.UtcNow
        }, cancellationToken);
    }
}
