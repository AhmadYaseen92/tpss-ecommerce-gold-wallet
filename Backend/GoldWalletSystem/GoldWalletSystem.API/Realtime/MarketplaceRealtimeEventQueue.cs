using System.Threading.Channels;
using GoldWalletSystem.Application.Interfaces.Realtime;
using GoldWalletSystem.Application.Realtime;

namespace GoldWalletSystem.API.Realtime;

public sealed class MarketplaceRealtimeEventQueue : IMarketplaceRealtimeEventPublisher
{
    private readonly Channel<MarketplaceRealtimeEvent> channel = Channel.CreateUnbounded<MarketplaceRealtimeEvent>(new UnboundedChannelOptions
    {
        SingleReader = true,
        SingleWriter = false
    });

    public ChannelReader<MarketplaceRealtimeEvent> Reader => channel.Reader;

    public ValueTask PublishAsync(MarketplaceRealtimeEvent @event, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return channel.Writer.WriteAsync(@event, cancellationToken);
    }
}
