using GoldWalletSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Database.Context;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<UserProfile> UserProfiles => Set<UserProfile>();
    public DbSet<PaymentMethod> PaymentMethods => Set<PaymentMethod>();
    public DbSet<LinkedBankAccount> LinkedBankAccounts => Set<LinkedBankAccount>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<TransactionHistory> TransactionHistories => Set<TransactionHistory>();
    public DbSet<Invoice> Invoices => Set<Invoice>();
    public DbSet<AppNotification> AppNotifications => Set<AppNotification>();
    public DbSet<Wallet> Wallets => Set<Wallet>();
    public DbSet<WalletAsset> WalletAssets => Set<WalletAsset>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>();
    public DbSet<MobileAppConfiguration> MobileAppConfigurations => Set<MobileAppConfiguration>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>().HasIndex(x => x.Email).IsUnique();
        modelBuilder.Entity<Product>().HasIndex(x => x.Sku).IsUnique();
        modelBuilder.Entity<Cart>().HasOne(x => x.User).WithOne(x => x.Cart).HasForeignKey<Cart>(x => x.UserId);
        modelBuilder.Entity<CartItem>().HasOne(x => x.Cart).WithMany(x => x.Items).HasForeignKey(x => x.CartId);
        modelBuilder.Entity<CartItem>().HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId);
        modelBuilder.Entity<UserProfile>().HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId);
        modelBuilder.Entity<PaymentMethod>().HasOne(x => x.UserProfile).WithMany(x => x.PaymentMethods).HasForeignKey(x => x.UserProfileId);
        modelBuilder.Entity<LinkedBankAccount>().HasOne(x => x.UserProfile).WithMany(x => x.LinkedBankAccounts).HasForeignKey(x => x.UserProfileId);

        modelBuilder.Entity<Product>().HasData(
            new Product { Id = 1, Name = "Gold Ring", Sku = "PRD-GOLD-RING", Description = "18k gold ring", Price = 250m, AvailableStock = 200 },
            new Product { Id = 2, Name = "Silver Necklace", Sku = "PRD-SLV-NECK", Description = "Silver necklace", Price = 120m, AvailableStock = 350 },
            new Product { Id = 3, Name = "Gold Coin", Sku = "PRD-GOLD-COIN", Description = "Investment gold coin", Price = 500m, AvailableStock = 50 }
        );

        modelBuilder.Entity<User>().HasData(
            new User { Id = 1, Email = "admin@wallet.com", FullName = "Admin User", PasswordHash = "seeded", Role = GoldWalletSystem.Domain.Constants.SystemRoles.Admin, IsActive = true, PhoneNumber = "+1-202-555-0123" },
            new User { Id = 2, Email = "investor@wallet.com", FullName = "Investor User", PasswordHash = "seeded", Role = GoldWalletSystem.Domain.Constants.SystemRoles.Investor, IsActive = true, PhoneNumber = "+1-202-555-0199" },
            new User { Id = 3, Email = "seller@wallet.com", FullName = "Seller User", PasswordHash = "seeded", Role = GoldWalletSystem.Domain.Constants.SystemRoles.Seller, IsActive = true, PhoneNumber = "+1-202-555-0177" }
        );

        modelBuilder.Entity<Cart>().HasData(new Cart { Id = 1, UserId = 1 }, new Cart { Id = 2, UserId = 2 }, new Cart { Id = 3, UserId = 3 });

        modelBuilder.Entity<UserProfile>().HasData(new UserProfile { Id = 1, UserId = 1, Nationality = "Jordanian", PreferredLanguage = "en", PreferredTheme = "light", DateOfBirth = new DateOnly(1990, 1, 1) });
        modelBuilder.Entity<PaymentMethod>().HasData(new PaymentMethod { Id = 1, UserProfileId = 1, Type = "Visa", MaskedNumber = "**** **** **** 3021", IsDefault = true });
        modelBuilder.Entity<LinkedBankAccount>().HasData(new LinkedBankAccount { Id = 1, UserProfileId = 1, BankName = "Arab Bank", IbanMasked = "JO** **** **** 1188", IsVerified = true });

        modelBuilder.Entity<Wallet>().HasData(new Wallet { Id = 1, UserId = 1, CashBalance = 2500, CurrencyCode = "USD" });
        modelBuilder.Entity<WalletAsset>().HasData(new WalletAsset { Id = 1, WalletId = 1, AssetType = GoldWalletSystem.Domain.Enums.AssetType.GoldBar, Weight = 10, Unit = "gram", Purity = 24, Quantity = 2, AverageBuyPrice = 200, CurrentMarketPrice = 220 });

        modelBuilder.Entity<AuditLog>().HasData(
            new AuditLog { Id = 1, UserId = 1, Action = "Seed", EntityName = "Database", Details = "Initial seed completed", CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
        );

        modelBuilder.Entity<TransactionHistory>().HasData(
            new TransactionHistory { Id = 1, UserId = 1, TransactionType = "WalletTopup", Amount = 1000, Currency = "USD", Reference = "TXN-0001", CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new TransactionHistory { Id = 2, UserId = 1, TransactionType = "Purchase", Amount = 250, Currency = "USD", Reference = "TXN-0002", CreatedAtUtc = new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc) }
        );

        modelBuilder.Entity<Invoice>().HasData(
            new Invoice { Id = 1, UserId = 1, InvoiceNumber = "INV-0001", SubTotal = 500, TaxAmount = 25, TotalAmount = 525, Status = "Paid", IssuedOnUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc), CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc) }
        );

        modelBuilder.Entity<MobileAppConfiguration>().HasData(
            new MobileAppConfiguration { Id = 1, ConfigKey = "tabs.home", JsonValue = "{\"enabled\":true}", IsEnabled = true, Description = "Home tab visibility" },
            new MobileAppConfiguration { Id = 2, ConfigKey = "actions.sell", JsonValue = "{\"enabled\":true,\"requireKyc\":true}", IsEnabled = true, Description = "Sell action rules" },
            new MobileAppConfiguration { Id = 3, ConfigKey = "features.notifications", JsonValue = "{\"enabled\":true}", IsEnabled = true, Description = "Notification feature toggle" }
        );

        modelBuilder.Entity<AppNotification>().HasData(
            new AppNotification { Id = 1, UserId = 1, Title = "Welcome", Body = "Your wallet is ready.", IsRead = false, CreatedAtUtc = new DateTime(2026, 1, 3, 0, 0, 0, DateTimeKind.Utc) },
            new AppNotification { Id = 2, UserId = 1, Title = "Invoice generated", Body = "Invoice INV-0001 was generated.", IsRead = true, CreatedAtUtc = new DateTime(2026, 1, 4, 0, 0, 0, DateTimeKind.Utc) }
        );
    }
}
