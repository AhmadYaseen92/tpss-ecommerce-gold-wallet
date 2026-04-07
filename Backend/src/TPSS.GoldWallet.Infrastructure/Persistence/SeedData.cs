using Microsoft.AspNetCore.Identity;
using TPSS.GoldWallet.Application.Security;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Domain.ValueObjects;
using TPSS.GoldWallet.Infrastructure.Identity;

namespace TPSS.GoldWallet.Infrastructure.Persistence;

public static class SeedData
{
    public static async Task EnsureSeededAsync(
        AppDbContext dbContext,
        UserManager<AppIdentityUser> userManager,
        RoleManager<IdentityRole<Guid>> roleManager)
    {
        var roles = new[] { RoleNames.Customer, RoleNames.ComplianceOfficer, RoleNames.Admin };
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole<Guid>(role));
            }
        }

        if (!dbContext.Products.Any())
        {
            await dbContext.Products.AddRangeAsync([
                new Product("GW-24K-001", "24K Gold Wallet Card", "Premium 24K plated wallet card.", new Money(199.00m, "USD")),
                new Product("GW-NFC-002", "NFC Safe Wallet Sleeve", "RFID/NFC protection sleeve for metal wallets.", new Money(49.00m, "USD")),
                new Product("GW-LUX-003", "Luxury Gift Box", "Gift-ready premium package.", new Money(29.00m, "USD"))
            ]);
        }

        var adminEmail = "admin@goldwallet.local";
        var admin = await userManager.FindByEmailAsync(adminEmail);
        if (admin is null)
        {
            admin = new AppIdentityUser
            {
                Id = Guid.NewGuid(),
                UserName = adminEmail,
                Email = adminEmail,
                EmailConfirmed = true
            };

            var create = await userManager.CreateAsync(admin, "Admin#12345Secure");
            if (create.Succeeded)
            {
                await userManager.AddToRoleAsync(admin, RoleNames.Admin);
            }
        }

        if (!dbContext.UserProfiles.Any(x => x.Id == admin!.Id))
        {
            await dbContext.UserProfiles.AddAsync(new UserProfile(admin.Id, admin.Email!, "System", "Admin", "US"));
        }

        if (!dbContext.WalletAccounts.Any(x => x.CustomerId == admin.Id))
        {
            await dbContext.WalletAccounts.AddAsync(new WalletAccount(admin.Id, "USD"));
        }

        if (!dbContext.AccountSummaries.Any(x => x.CustomerId == admin.Id))
        {
            await dbContext.AccountSummaries.AddAsync(new AccountSummarySnapshot(admin.Id, 345200m, 340000m, 2200m, 3000m, 12500m, 500m, 300m));
        }

        if (!dbContext.TradeTransactions.Any(x => x.CustomerId == admin.Id))
        {
            await dbContext.TradeTransactions.AddRangeAsync([
                new TradeTransaction(admin.Id, "Buy Gold", "buy", "completed", DateTime.UtcNow.AddDays(-2), "+ 10g", "Imseeh", "- $650.00"),
                new TradeTransaction(admin.Id, "Deposit Funds", "deposit", "completed", DateTime.UtcNow.AddDays(-5), "+ $1000.00", "Sakkejha", null)
            ]);
        }

        if (!dbContext.Notifications.Any(x => x.CustomerId == admin.Id))
        {
            await dbContext.Notifications.AddRangeAsync([
                new NotificationMessage(admin.Id, "Gold Price Surge", "Gold prices hit a new daily high.", "market"),
                new NotificationMessage(admin.Id, "Security Alert", "New login attempt detected.", "security")
            ]);
        }

        await dbContext.SaveChangesAsync();
    }
}
