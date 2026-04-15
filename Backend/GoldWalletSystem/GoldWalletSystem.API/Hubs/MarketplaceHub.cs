using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace GoldWalletSystem.API.Hubs;

[Authorize]
public class MarketplaceHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "marketplace");

        var role = Context.User?.FindFirst("role")?.Value;
        if (!string.IsNullOrWhiteSpace(role))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"role:{role.ToLowerInvariant()}");
        }

        var userId = Context.User?.FindFirst("sub")?.Value;
        if (!string.IsNullOrWhiteSpace(userId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user:{userId}");
        }

        var sellerId = Context.User?.FindFirst("seller_id")?.Value;
        if (!string.IsNullOrWhiteSpace(sellerId) && int.TryParse(sellerId, out var parsedSellerId) && parsedSellerId > 0)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"seller:{parsedSellerId}");
        }

        await base.OnConnectedAsync();
    }
}
