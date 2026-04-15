using GoldWalletSystem.Application.Realtime;

namespace GoldWalletSystem.Application.Interfaces.Realtime;

public interface IMarketplaceRealtimeEventPublisher
{
    ValueTask PublishAsync(MarketplaceRealtimeEvent @event, CancellationToken cancellationToken = default);
}
