using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
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
    public DbSet<InvoiceItem> InvoiceItems => Set<InvoiceItem>();
    public DbSet<AppNotification> AppNotifications => Set<AppNotification>();
    public DbSet<Wallet> Wallets => Set<Wallet>();
    public DbSet<WalletAsset> WalletAssets => Set<WalletAsset>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>();
    public DbSet<MobileAppConfiguration> MobileAppConfigurations => Set<MobileAppConfiguration>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        ConfigureUser(modelBuilder);
        ConfigureUserProfile(modelBuilder);
        ConfigurePaymentMethod(modelBuilder);
        ConfigureLinkedBankAccount(modelBuilder);
        ConfigureProduct(modelBuilder);
        ConfigureCart(modelBuilder);
        ConfigureCartItem(modelBuilder);
        ConfigureAuditLog(modelBuilder);
        ConfigureTransactionHistory(modelBuilder);
        ConfigureWallet(modelBuilder);
        ConfigureWalletAsset(modelBuilder);
        ConfigureOrder(modelBuilder);
        ConfigurePaymentTransaction(modelBuilder);
        ConfigureInvoice(modelBuilder);
        ConfigureInvoiceItem(modelBuilder);
        ConfigureAppNotification(modelBuilder);
        ConfigureMobileAppConfiguration(modelBuilder);
    }

    private static void ConfigureUser(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("Users");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.FullName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.Email).IsRequired().HasMaxLength(200);
            entity.Property(x => x.PasswordHash).IsRequired().HasMaxLength(500);
            entity.Property(x => x.PhoneNumber).HasMaxLength(30);
            entity.Property(x => x.Role).IsRequired().HasMaxLength(50);
            entity.HasIndex(x => x.Email).IsUnique();
            entity.HasIndex(x => x.Role);
        });
    }

    private static void ConfigureUserProfile(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserProfile>(entity =>
        {
            entity.ToTable("UserProfiles");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Nationality).HasMaxLength(100);
            entity.Property(x => x.PreferredLanguage).HasMaxLength(10);
            entity.Property(x => x.PreferredTheme).HasMaxLength(20);
            entity.HasIndex(x => x.UserId).IsUnique();
            entity.HasOne(x => x.User).WithOne().HasForeignKey<UserProfile>(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigurePaymentMethod(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<PaymentMethod>(entity =>
        {
            entity.ToTable("PaymentMethods");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Type).IsRequired().HasMaxLength(50);
            entity.Property(x => x.MaskedNumber).IsRequired().HasMaxLength(50);
            entity.HasOne(x => x.UserProfile).WithMany(x => x.PaymentMethods).HasForeignKey(x => x.UserProfileId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureLinkedBankAccount(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<LinkedBankAccount>(entity =>
        {
            entity.ToTable("LinkedBankAccounts");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.BankName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.IbanMasked).IsRequired().HasMaxLength(50);
            entity.HasOne(x => x.UserProfile).WithMany(x => x.LinkedBankAccounts).HasForeignKey(x => x.UserProfileId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureProduct(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>(entity =>
        {
            entity.ToTable("Products");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Name).IsRequired().HasMaxLength(200);
            entity.Property(x => x.Sku).IsRequired().HasMaxLength(100);
            entity.Property(x => x.Description).HasMaxLength(1000);
            entity.Property(x => x.Price).HasPrecision(18, 2);
            entity.HasIndex(x => x.Sku).IsUnique();
            entity.HasIndex(x => x.Name);
        });
    }

    private static void ConfigureCart(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Cart>(entity =>
        {
            entity.ToTable("Carts");
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.UserId).IsUnique();
            entity.HasOne(x => x.User).WithOne(x => x.Cart).HasForeignKey<Cart>(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureCartItem(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<CartItem>(entity =>
        {
            entity.ToTable("CartItems");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.UnitPrice).HasPrecision(18, 2);
            entity.Property(x => x.LineTotal).HasPrecision(18, 2);
            entity.HasIndex(x => new { x.CartId, x.ProductId });
            entity.HasOne(x => x.Cart).WithMany(x => x.Items).HasForeignKey(x => x.CartId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureAuditLog(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.ToTable("AuditLogs");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Action).IsRequired().HasMaxLength(100);
            entity.Property(x => x.EntityName).IsRequired().HasMaxLength(100);
            entity.Property(x => x.Details).HasMaxLength(2000);
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => x.CreatedAtUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureTransactionHistory(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TransactionHistory>(entity =>
        {
            entity.ToTable("TransactionHistories");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TransactionType).IsRequired().HasMaxLength(100);
            entity.Property(x => x.Amount).HasPrecision(18, 2);
            entity.Property(x => x.Currency).IsRequired().HasMaxLength(10);
            entity.Property(x => x.Reference).IsRequired().HasMaxLength(100);
            entity.HasIndex(x => x.Reference).IsUnique();
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => x.CreatedAtUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureWallet(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Wallet>(entity =>
        {
            entity.ToTable("Wallets");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.CashBalance).HasPrecision(18, 2);
            entity.Property(x => x.CurrencyCode).IsRequired().HasMaxLength(10);
            entity.HasIndex(x => x.UserId).IsUnique();
            entity.HasOne(x => x.User).WithOne(x => x.Wallet).HasForeignKey<Wallet>(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureWalletAsset(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<WalletAsset>(entity =>
        {
            entity.ToTable("WalletAssets");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Unit).IsRequired().HasMaxLength(20);
            entity.Property(x => x.Weight).HasPrecision(18, 3);
            entity.Property(x => x.Purity).HasPrecision(5, 2);
            entity.Property(x => x.AverageBuyPrice).HasPrecision(18, 2);
            entity.Property(x => x.CurrentMarketPrice).HasPrecision(18, 2);
            entity.HasIndex(x => x.WalletId);
            entity.HasOne(x => x.Wallet).WithMany(x => x.Assets).HasForeignKey(x => x.WalletId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureOrder(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Order>(entity =>
        {
            entity.ToTable("Orders");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Unit).IsRequired().HasMaxLength(20);
            entity.Property(x => x.UnitPrice).HasPrecision(18, 2);
            entity.Property(x => x.TotalAmount).HasPrecision(18, 2);
            entity.Property(x => x.Weight).HasPrecision(18, 3);
            entity.Property(x => x.OtpCode).HasMaxLength(20);
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => x.Status);
            entity.HasIndex(x => x.OrderType);
            entity.HasIndex(x => x.PriceLockedUntilUtc);
            entity.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigurePaymentTransaction(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<PaymentTransaction>(entity =>
        {
            entity.ToTable("PaymentTransactions");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Amount).HasPrecision(18, 2);
            entity.Property(x => x.PaymentMethod).IsRequired().HasMaxLength(50);
            entity.Property(x => x.ExternalTransactionId).HasMaxLength(100);
            entity.HasIndex(x => x.OrderId);
            entity.HasIndex(x => x.Status);
            entity.HasIndex(x => x.ExternalTransactionId).IsUnique().HasFilter("[ExternalTransactionId] IS NOT NULL");
            entity.HasOne(x => x.Order).WithMany().HasForeignKey(x => x.OrderId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureInvoice(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Invoice>(entity =>
        {
            entity.ToTable("Invoices");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.InvoiceNumber).IsRequired().HasMaxLength(100);
            entity.Property(x => x.InvoiceCategory).HasMaxLength(50);
            entity.Property(x => x.SourceChannel).HasMaxLength(50);
            entity.Property(x => x.InvoiceQrCode).HasMaxLength(300);
            entity.Property(x => x.Status).IsRequired().HasMaxLength(50);
            entity.Property(x => x.SubTotal).HasPrecision(18, 2);
            entity.Property(x => x.TaxAmount).HasPrecision(18, 2);
            entity.Property(x => x.TotalAmount).HasPrecision(18, 2);
            entity.HasIndex(x => x.InvoiceNumber).IsUnique();
            entity.HasIndex(x => x.InvestorUserId);
            entity.HasIndex(x => x.SellerUserId);
            entity.HasIndex(x => x.IssuedOnUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.InvestorUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.SellerUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasMany(x => x.Items).WithOne(x => x.Invoice).HasForeignKey(x => x.InvoiceId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureInvoiceItem(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<InvoiceItem>(entity =>
        {
            entity.ToTable("InvoiceItems");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.ItemName).IsRequired().HasMaxLength(200);
            entity.Property(x => x.ItemQrCode).HasMaxLength(300);
            entity.Property(x => x.UnitPrice).HasPrecision(18, 2);
            entity.Property(x => x.LineTotal).HasPrecision(18, 2);
            entity.HasIndex(x => new { x.InvoiceId, x.ProductId });
            entity.HasOne(x => x.Invoice).WithMany(x => x.Items).HasForeignKey(x => x.InvoiceId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne<Product>().WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureAppNotification(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AppNotification>(entity =>
        {
            entity.ToTable("AppNotifications");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Title).IsRequired().HasMaxLength(200);
            entity.Property(x => x.Body).IsRequired().HasMaxLength(2000);
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => new { x.UserId, x.IsRead });
            entity.HasIndex(x => x.CreatedAtUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureMobileAppConfiguration(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MobileAppConfiguration>(entity =>
        {
            entity.ToTable("MobileAppConfigurations");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.ConfigKey).IsRequired().HasMaxLength(150);
            entity.Property(x => x.JsonValue).IsRequired().HasColumnType("nvarchar(max)");
            entity.Property(x => x.Description).HasMaxLength(500);
            entity.HasIndex(x => x.ConfigKey).IsUnique();
        });
    }
}
