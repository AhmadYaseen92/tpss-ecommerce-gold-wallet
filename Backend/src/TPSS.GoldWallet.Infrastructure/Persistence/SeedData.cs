using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Domain.ValueObjects;

namespace TPSS.GoldWallet.Infrastructure.Persistence;

public static class SeedData
{
    public static async Task EnsureSeededAsync(AppDbContext dbContext)
    {
        if (dbContext.Products.Any())
        {
            return;
        }

        var products = new[]
        {
            new Product("GW-24K-001", "24K Gold Wallet Card", "Premium 24K plated wallet card.", new Money(199.00m, "USD")),
            new Product("GW-NFC-002", "NFC Safe Wallet Sleeve", "RFID/NFC protection sleeve for metal wallets.", new Money(49.00m, "USD")),
            new Product("GW-LUX-003", "Luxury Gift Box", "Gift-ready premium package.", new Money(29.00m, "USD"))
        };

        await dbContext.Products.AddRangeAsync(products);
        await dbContext.SaveChangesAsync();
    }
}
