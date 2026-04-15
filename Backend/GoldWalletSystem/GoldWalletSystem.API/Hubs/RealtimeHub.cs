using Microsoft.AspNetCore.SignalR;

namespace GoldWalletSystem.API.Hubs
{
    public class RealtimeHub : Hub
    {
        // Methods for sending updates to clients
        // Example: public async Task SendStockUpdate(object stock) => await Clients.All.SendAsync("StockUpdated", stock);
    }
}
