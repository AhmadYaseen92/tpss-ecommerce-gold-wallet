using GoldWalletSystem.API.Hubs;
using GoldWalletSystem.Application.Realtime;
using Microsoft.AspNetCore.SignalR;

namespace GoldWalletSystem.API.Realtime;

public sealed class MarketplaceRealtimeDispatcher(
    MarketplaceRealtimeEventQueue queue,
    IHubContext<MarketplaceHub> hubContext,
    ILogger<MarketplaceRealtimeDispatcher> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await foreach (var @event in queue.Reader.ReadAllAsync(stoppingToken))
        {
            try
            {
                await BroadcastAsync(@event, stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Failed to broadcast realtime event {Entity}:{Action}", @event.Entity, @event.Action);
            }
        }
    }

    private async Task BroadcastAsync(MarketplaceRealtimeEvent @event, CancellationToken cancellationToken)
    {
        await hubContext.Clients.Group("marketplace").SendAsync("marketplaceEvent", @event, cancellationToken);

        if (@event.UserId.HasValue)
        {
            await hubContext.Clients.Group($"user:{@event.UserId.Value}").SendAsync("marketplaceEvent", @event, cancellationToken);
        }

        if (@event.SellerId.HasValue)
        {
            await hubContext.Clients.Group($"seller:{@event.SellerId.Value}").SendAsync("marketplaceEvent", @event, cancellationToken);
        }
    }
}
