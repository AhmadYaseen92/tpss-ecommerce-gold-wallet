using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Database.Context;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Seller> Sellers => Set<Seller>();
    public DbSet<User> Users => Set<User>();
    public DbSet<UserProfile> UserProfiles => Set<UserProfile>();
    public DbSet<PaymentMethod> PaymentMethods => Set<PaymentMethod>();
    public DbSet<CardPaymentMethodDetails> CardPaymentMethodDetails => Set<CardPaymentMethodDetails>();
    public DbSet<ApplePayPaymentMethodDetails> ApplePayPaymentMethodDetails => Set<ApplePayPaymentMethodDetails>();
    public DbSet<WalletPaymentMethodDetails> WalletPaymentMethodDetails => Set<WalletPaymentMethodDetails>();
    public DbSet<CliqPaymentMethodDetails> CliqPaymentMethodDetails => Set<CliqPaymentMethodDetails>();
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

        ConfigureSeller(modelBuilder);
        ConfigureUser(modelBuilder);
        ConfigureUserProfile(modelBuilder);
        ConfigurePaymentMethod(modelBuilder);
        ConfigureCardPaymentMethodDetails(modelBuilder);
        ConfigureApplePayPaymentMethodDetails(modelBuilder);
        ConfigureWalletPaymentMethodDetails(modelBuilder);
        ConfigureCliqPaymentMethodDetails(modelBuilder);
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

    private static void ConfigureSeller(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Seller>(entity =>
        {
            entity.ToTable("Sellers");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Name).IsRequired().HasMaxLength(200);
            entity.Property(x => x.Code).IsRequired().HasMaxLength(50);
            entity.Property(x => x.Email).IsRequired().HasMaxLength(200);
            entity.Property(x => x.PasswordHash).IsRequired().HasMaxLength(500);
            entity.Property(x => x.ContactEmail).HasMaxLength(200);
            entity.Property(x => x.ContactPhone).HasMaxLength(50);
            entity.Property(x => x.Country).IsRequired().HasMaxLength(80);
            entity.Property(x => x.City).IsRequired().HasMaxLength(80);
            entity.Property(x => x.Street).IsRequired().HasMaxLength(150);
            entity.Property(x => x.BuildingNumber).IsRequired().HasMaxLength(30);
            entity.Property(x => x.PostalCode).IsRequired().HasMaxLength(30);
            entity.Property(x => x.CompanyName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.TradeLicenseNumber).IsRequired().HasMaxLength(100);
            entity.Property(x => x.VatNumber).IsRequired().HasMaxLength(100);
            entity.Property(x => x.NationalIdNumber).IsRequired().HasMaxLength(100);
            entity.Property(x => x.BankName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.IBAN).IsRequired().HasMaxLength(100);
            entity.Property(x => x.AccountHolderName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.NationalIdFrontPath).IsRequired().HasMaxLength(500);
            entity.Property(x => x.NationalIdBackPath).IsRequired().HasMaxLength(500);
            entity.Property(x => x.TradeLicensePath).IsRequired().HasMaxLength(500);
            entity.Property(x => x.KycStatus).HasConversion<int>();
            entity.Property(x => x.ReviewNotes).HasMaxLength(1000);
            entity.HasIndex(x => x.Code).IsUnique();
            entity.HasIndex(x => x.Email).IsUnique();
            entity.HasIndex(x => x.Name);
            entity.HasIndex(x => x.KycStatus);
        });
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
            entity.HasIndex(x => x.SellerId);
            entity.HasOne(x => x.Seller).WithMany(x => x.Users).HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureUserProfile(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserProfile>(entity =>
        {
            entity.ToTable("UserProfiles");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Nationality).HasMaxLength(100);
            entity.Property(x => x.DocumentType).HasMaxLength(50);
            entity.Property(x => x.IdNumber).HasMaxLength(100);
            entity.Property(x => x.ProfilePhotoUrl).HasMaxLength(500);
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

    private static void ConfigureCardPaymentMethodDetails(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<CardPaymentMethodDetails>(entity =>
        {
            entity.ToTable("CardPaymentMethodDetails");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.CardNumber).IsRequired().HasMaxLength(30);
            entity.Property(x => x.CardHolderName).IsRequired().HasMaxLength(120);
            entity.Property(x => x.Expiry).IsRequired().HasMaxLength(10);
            entity.HasIndex(x => x.PaymentMethodId).IsUnique();
            entity.HasOne(x => x.PaymentMethod).WithOne(x => x.CardDetails).HasForeignKey<CardPaymentMethodDetails>(x => x.PaymentMethodId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureApplePayPaymentMethodDetails(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ApplePayPaymentMethodDetails>(entity =>
        {
            entity.ToTable("ApplePayPaymentMethodDetails");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.ApplePayToken).IsRequired().HasMaxLength(128);
            entity.Property(x => x.AccountHolderName).IsRequired().HasMaxLength(120);
            entity.HasIndex(x => x.PaymentMethodId).IsUnique();
            entity.HasOne(x => x.PaymentMethod).WithOne(x => x.ApplePayDetails).HasForeignKey<ApplePayPaymentMethodDetails>(x => x.PaymentMethodId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureWalletPaymentMethodDetails(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<WalletPaymentMethodDetails>(entity =>
        {
            entity.ToTable("WalletPaymentMethodDetails");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Provider).IsRequired().HasMaxLength(60);
            entity.Property(x => x.WalletNumber).IsRequired().HasMaxLength(30);
            entity.Property(x => x.AccountHolderName).IsRequired().HasMaxLength(120);
            entity.HasIndex(x => x.PaymentMethodId).IsUnique();
            entity.HasOne(x => x.PaymentMethod).WithOne(x => x.WalletDetails).HasForeignKey<WalletPaymentMethodDetails>(x => x.PaymentMethodId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureCliqPaymentMethodDetails(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<CliqPaymentMethodDetails>(entity =>
        {
            entity.ToTable("CliqPaymentMethodDetails");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.CliqAlias).IsRequired().HasMaxLength(60);
            entity.Property(x => x.BankName).IsRequired().HasMaxLength(120);
            entity.Property(x => x.AccountHolderName).IsRequired().HasMaxLength(120);
            entity.HasIndex(x => x.PaymentMethodId).IsUnique();
            entity.HasOne(x => x.PaymentMethod).WithOne(x => x.CliqDetails).HasForeignKey<CliqPaymentMethodDetails>(x => x.PaymentMethodId).OnDelete(DeleteBehavior.Cascade);
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
            entity.Property(x => x.AccountHolderName).HasMaxLength(120);
            entity.Property(x => x.AccountNumber).HasMaxLength(40);
            entity.Property(x => x.SwiftCode).HasMaxLength(20);
            entity.Property(x => x.BranchName).HasMaxLength(120);
            entity.Property(x => x.BranchAddress).HasMaxLength(250);
            entity.Property(x => x.Country).HasMaxLength(80);
            entity.Property(x => x.City).HasMaxLength(80);
            entity.Property(x => x.Currency).HasMaxLength(10);
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
            entity.Property(x => x.ImageUrl).HasMaxLength(1000);
            entity.Property(x => x.Category).HasConversion<int>();
            entity.Property(x => x.WeightValue).HasPrecision(18, 3);
            entity.Property(x => x.WeightUnit).HasConversion<int>();
            entity.Property(x => x.PricingMaterialType).HasConversion<int>();
            entity.Property(x => x.PricingMode).HasConversion<int>();
            entity.Property(x => x.PurityKarat).HasPrecision(10, 2);
            entity.Property(x => x.MarketUnitPrice).HasPrecision(18, 4);
            entity.Property(x => x.DeliveryFee).HasPrecision(18, 2);
            entity.Property(x => x.StorageFee).HasPrecision(18, 2);
            entity.Property(x => x.ServiceCharge).HasPrecision(18, 2);
            entity.Property(x => x.FinalSellPrice).HasPrecision(18, 2);
            entity.Property(x => x.Price).HasPrecision(18, 2);
            entity.HasIndex(x => x.Sku).IsUnique();
            entity.HasIndex(x => x.Name);
            entity.HasIndex(x => x.SellerId);
            entity.HasOne(x => x.Seller).WithMany(x => x.Products).HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Restrict);
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
            entity.Property(x => x.Category).HasConversion<int>();
            entity.HasIndex(x => new { x.CartId, x.ProductId });
            entity.HasIndex(x => x.SellerId);
            entity.HasIndex(x => x.Category);
            entity.HasOne(x => x.Cart).WithMany(x => x.Items).HasForeignKey(x => x.CartId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<Seller>().WithMany().HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Restrict);
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
            entity.Property(x => x.Status).IsRequired().HasMaxLength(30);
            entity.Property(x => x.Category).IsRequired().HasMaxLength(50);
            entity.Property(x => x.Quantity).IsRequired();
            entity.Property(x => x.UnitPrice).HasPrecision(18, 2);
            entity.Property(x => x.Weight).HasPrecision(18, 3);
            entity.Property(x => x.Unit).IsRequired().HasMaxLength(20);
            entity.Property(x => x.Purity).HasPrecision(5, 2);
            entity.Property(x => x.Notes).HasMaxLength(1000);
            entity.Property(x => x.Amount).HasPrecision(18, 2);
            entity.Property(x => x.Currency).IsRequired().HasMaxLength(10);
            entity.HasIndex(x => x.Status);
            entity.HasIndex(x => x.Category);
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => x.SellerId);
            entity.HasIndex(x => x.CreatedAtUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<Seller>().WithMany().HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Restrict);
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
            entity.Property(x => x.Category).HasConversion<int>();
            entity.Property(x => x.SellerName).HasMaxLength(200);
            entity.Property(x => x.AverageBuyPrice).HasPrecision(18, 2);
            entity.Property(x => x.CurrentMarketPrice).HasPrecision(18, 2);
            entity.HasIndex(x => x.WalletId);
            entity.HasIndex(x => x.Category);
            entity.HasIndex(x => x.SellerId);
            entity.HasOne(x => x.Wallet).WithMany(x => x.Assets).HasForeignKey(x => x.WalletId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne<Seller>().WithMany().HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Restrict);
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
