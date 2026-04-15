using GoldWalletSystem.API.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace GoldWalletSystem.API.Services;

public interface IMarketplaceRealtimeNotifier
{
    Task BroadcastRefreshHintAsync(string reason, CancellationToken cancellationToken = default);
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
}
