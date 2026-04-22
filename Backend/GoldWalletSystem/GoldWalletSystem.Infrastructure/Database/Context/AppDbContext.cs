using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Database.Context;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Seller> Sellers => Set<Seller>();
    public DbSet<SellerAddress> SellerAddresses => Set<SellerAddress>();
    public DbSet<SellerManager> SellerManagers => Set<SellerManager>();
    public DbSet<SellerBranch> SellerBranches => Set<SellerBranch>();
    public DbSet<SellerBankAccount> SellerBankAccounts => Set<SellerBankAccount>();
    public DbSet<SellerDocument> SellerDocuments => Set<SellerDocument>();
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
    public DbSet<AppNotification> AppNotifications => Set<AppNotification>();
    public DbSet<UserPushToken> UserPushTokens => Set<UserPushToken>();
    public DbSet<Wallet> Wallets => Set<Wallet>();
    public DbSet<WalletAsset> WalletAssets => Set<WalletAsset>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>();
    public DbSet<MobileAppConfiguration> MobileAppConfigurations => Set<MobileAppConfiguration>();
    public DbSet<SystemFeeType> SystemFeeTypes => Set<SystemFeeType>();
    public DbSet<SellerProductFee> SellerProductFees => Set<SellerProductFee>();
    public DbSet<AdminTransactionFee> AdminTransactionFees => Set<AdminTransactionFee>();
    public DbSet<TransactionFeeBreakdown> TransactionFeeBreakdowns => Set<TransactionFeeBreakdown>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        ConfigureSeller(modelBuilder);
        ConfigureSellerAddress(modelBuilder);
        ConfigureSellerManager(modelBuilder);
        ConfigureSellerBranch(modelBuilder);
        ConfigureSellerBankAccount(modelBuilder);
        ConfigureSellerDocument(modelBuilder);
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
        ConfigureAppNotification(modelBuilder);
        ConfigureUserPushToken(modelBuilder);
        ConfigureMobileAppConfiguration(modelBuilder);
        ConfigureSystemFeeType(modelBuilder);
        ConfigureSellerProductFee(modelBuilder);
        ConfigureAdminTransactionFee(modelBuilder);
        ConfigureTransactionFeeBreakdown(modelBuilder);
    }

    private static void ConfigureSeller(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Seller>(entity =>
        {
            entity.ToTable("Sellers");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.UserId).IsRequired();
            entity.Property(x => x.CompanyName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.CompanyCode).IsRequired().HasMaxLength(50);
            entity.Property(x => x.CommercialRegistrationNumber).IsRequired().HasMaxLength(100);
            entity.Property(x => x.VatNumber).IsRequired().HasMaxLength(100);
            entity.Property(x => x.BusinessActivity).IsRequired().HasMaxLength(150);
            entity.Property(x => x.CompanyPhone).IsRequired().HasMaxLength(50);
            entity.Property(x => x.CompanyEmail).IsRequired().HasMaxLength(200);
            entity.Property(x => x.Website).HasMaxLength(250);
            entity.Property(x => x.Description).HasMaxLength(2000);
            entity.Property(x => x.KycStatus).HasConversion<int>();
            entity.Property(x => x.ReviewNotes).HasMaxLength(1000);
            entity.Property(x => x.GoldPrice).HasPrecision(18, 2);
            entity.Property(x => x.SilverPrice).HasPrecision(18, 2);
            entity.Property(x => x.DiamondPrice).HasPrecision(18, 2);
            entity.HasIndex(x => x.CompanyCode).IsUnique();
            entity.HasIndex(x => x.UserId).IsUnique();
            entity.HasIndex(x => x.CompanyName);
            entity.HasIndex(x => x.KycStatus);
            entity.HasOne(x => x.User).WithOne(x => x.SellerProfile).HasForeignKey<Seller>(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureSellerAddress(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SellerAddress>(entity =>
        {
            entity.ToTable("SellerAddresses");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Country).IsRequired().HasMaxLength(80);
            entity.Property(x => x.City).IsRequired().HasMaxLength(80);
            entity.Property(x => x.Street).IsRequired().HasMaxLength(150);
            entity.Property(x => x.BuildingNumber).IsRequired().HasMaxLength(30);
            entity.Property(x => x.PostalCode).IsRequired().HasMaxLength(30);
            entity.HasIndex(x => x.SellerId).IsUnique();
            entity.HasOne(x => x.Seller).WithOne(x => x.Address).HasForeignKey<SellerAddress>(x => x.SellerId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureSellerManager(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SellerManager>(entity =>
        {
            entity.ToTable("SellerManagers");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.FullName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.PositionTitle).IsRequired().HasMaxLength(100);
            entity.Property(x => x.Nationality).IsRequired().HasMaxLength(80);
            entity.Property(x => x.MobileNumber).IsRequired().HasMaxLength(50);
            entity.Property(x => x.EmailAddress).IsRequired().HasMaxLength(200);
            entity.Property(x => x.IdType).IsRequired().HasMaxLength(50);
            entity.Property(x => x.IdNumber).IsRequired().HasMaxLength(100);
            entity.HasIndex(x => x.SellerId);
            entity.HasOne(x => x.Seller).WithMany(x => x.Managers).HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureSellerBranch(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SellerBranch>(entity =>
        {
            entity.ToTable("SellerBranches");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.BranchName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.Country).IsRequired().HasMaxLength(80);
            entity.Property(x => x.City).IsRequired().HasMaxLength(80);
            entity.Property(x => x.FullAddress).IsRequired().HasMaxLength(250);
            entity.Property(x => x.BuildingNumber).IsRequired().HasMaxLength(30);
            entity.Property(x => x.PostalCode).IsRequired().HasMaxLength(30);
            entity.Property(x => x.PhoneNumber).IsRequired().HasMaxLength(50);
            entity.Property(x => x.Email).IsRequired().HasMaxLength(200);
            entity.HasIndex(x => x.SellerId);
            entity.HasOne(x => x.Seller).WithMany(x => x.Branches).HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureSellerBankAccount(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SellerBankAccount>(entity =>
        {
            entity.ToTable("SellerBankAccounts");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.BankName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.AccountHolderName).IsRequired().HasMaxLength(150);
            entity.Property(x => x.AccountNumber).IsRequired().HasMaxLength(100);
            entity.Property(x => x.IBAN).IsRequired().HasMaxLength(100);
            entity.Property(x => x.SwiftCode).IsRequired().HasMaxLength(50);
            entity.Property(x => x.BankCountry).IsRequired().HasMaxLength(80);
            entity.Property(x => x.BankCity).IsRequired().HasMaxLength(80);
            entity.Property(x => x.BranchName).IsRequired().HasMaxLength(120);
            entity.Property(x => x.BranchAddress).IsRequired().HasMaxLength(250);
            entity.Property(x => x.Currency).IsRequired().HasMaxLength(10);
            entity.HasIndex(x => x.SellerId);
            entity.HasOne(x => x.Seller).WithMany(x => x.BankAccounts).HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureSellerDocument(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SellerDocument>(entity =>
        {
            entity.ToTable("SellerDocuments");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.DocumentType).IsRequired().HasMaxLength(100);
            entity.Property(x => x.FileName).IsRequired().HasMaxLength(255);
            entity.Property(x => x.FilePath).IsRequired().HasMaxLength(500);
            entity.Property(x => x.ContentType).IsRequired().HasMaxLength(150);
            entity.Property(x => x.RelatedEntityType).HasMaxLength(50);
            entity.HasIndex(x => x.SellerId);
            entity.HasIndex(x => new { x.SellerId, x.DocumentType });
            entity.HasOne(x => x.Seller).WithMany(x => x.Documents).HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Cascade);
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
            entity.Property(x => x.MaterialType).HasConversion<int>();
            entity.Property(x => x.FormType).HasConversion<int>();
            entity.Property(x => x.PricingMode).HasConversion<int>();
            entity.Property(x => x.PurityKarat).HasConversion<int>();
            entity.Property(x => x.PurityFactor).HasPrecision(10, 6);
            entity.Property(x => x.WeightValue).HasPrecision(18, 3);
            entity.Property(x => x.WeightUnit).HasConversion<int>();
            entity.Property(x => x.BaseMarketPrice).HasPrecision(18, 2);
            entity.Property(x => x.AutoPrice).HasPrecision(18, 2);
            entity.Property(x => x.FixedPrice).HasPrecision(18, 2);
            entity.Property(x => x.SellPrice).HasPrecision(18, 2);
            entity.Property(x => x.OfferPercent).HasPrecision(8, 3);
            entity.Property(x => x.OfferNewPrice).HasPrecision(18, 2);
            entity.Property(x => x.OfferType).HasConversion<int>();
            entity.Property(x => x.IsHasOffer).HasDefaultValue(false);
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
            entity.Property(x => x.SubTotalAmount).HasPrecision(18, 2);
            entity.Property(x => x.TotalFeesAmount).HasPrecision(18, 2);
            entity.Property(x => x.DiscountAmount).HasPrecision(18, 2);
            entity.Property(x => x.FinalAmount).HasPrecision(18, 2);
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
            entity.HasIndex(x => x.WalletItemId);
            entity.HasIndex(x => x.InvoiceId);
            entity.HasIndex(x => x.ProductId);
            entity.HasIndex(x => x.CreatedAtUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<Seller>().WithMany().HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(x => x.WalletItem).WithMany().HasForeignKey(x => x.WalletItemId).OnDelete(DeleteBehavior.SetNull);
            entity.HasOne(x => x.Invoice).WithMany().HasForeignKey(x => x.InvoiceId).OnDelete(DeleteBehavior.SetNull);
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
            entity.Property(x => x.ProductName).HasMaxLength(200);
            entity.Property(x => x.ProductSku).HasMaxLength(100);
            entity.Property(x => x.ProductImageUrl).HasMaxLength(1000);
            entity.Property(x => x.MaterialType).HasMaxLength(50);
            entity.Property(x => x.FormType).HasMaxLength(50);
            entity.Property(x => x.PurityKarat).HasMaxLength(30);
            entity.Property(x => x.PurityDisplayName).HasMaxLength(50);
            entity.Property(x => x.WeightValue).HasPrecision(18, 3);
            entity.Property(x => x.WeightUnit).HasMaxLength(20);
            entity.Property(x => x.Unit).IsRequired().HasMaxLength(20);
            entity.Property(x => x.Weight).HasPrecision(18, 3);
            entity.Property(x => x.Purity).HasPrecision(5, 2);
            entity.Property(x => x.Category).HasConversion<int>();
            entity.Property(x => x.SellerName).HasMaxLength(200);
            entity.Property(x => x.AverageBuyPrice).HasPrecision(18, 2);
            entity.Property(x => x.CurrentMarketPrice).HasPrecision(18, 2);
            entity.Property(x => x.AcquisitionSubTotalAmount).HasPrecision(18, 2);
            entity.Property(x => x.AcquisitionFeesAmount).HasPrecision(18, 2);
            entity.Property(x => x.AcquisitionDiscountAmount).HasPrecision(18, 2);
            entity.Property(x => x.AcquisitionFinalAmount).HasPrecision(18, 2);
            entity.HasIndex(x => x.WalletId);
            entity.HasIndex(x => x.Category);
            entity.HasIndex(x => x.SellerId);
            entity.HasIndex(x => x.ProductId);
            entity.HasIndex(x => x.LastTransactionHistoryId);
            entity.HasIndex(x => x.SourceInvoiceId);
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
            entity.Property(x => x.ExternalReference).HasMaxLength(120);
            entity.Property(x => x.InvoiceQrCode).HasMaxLength(300);
            entity.Property(x => x.PdfUrl).HasMaxLength(500);
            entity.Property(x => x.Currency).IsRequired().HasMaxLength(10);
            entity.Property(x => x.PaymentMethod).HasMaxLength(50);
            entity.Property(x => x.PaymentStatus).HasMaxLength(50);
            entity.Property(x => x.PaymentTransactionId).HasMaxLength(120);
            entity.Property(x => x.ProductName).HasMaxLength(200);
            entity.Property(x => x.UnitPrice).HasPrecision(18, 2);
            entity.Property(x => x.Weight).HasPrecision(18, 3);
            entity.Property(x => x.Purity).HasPrecision(5, 2);
            entity.Property(x => x.FromPartyType).HasMaxLength(30);
            entity.Property(x => x.ToPartyType).HasMaxLength(30);
            entity.Property(x => x.Status).IsRequired().HasMaxLength(50);
            entity.Property(x => x.SubTotal).HasPrecision(18, 2);
            entity.Property(x => x.FeesAmount).HasPrecision(18, 2);
            entity.Property(x => x.DiscountAmount).HasPrecision(18, 2);
            entity.Property(x => x.TaxAmount).HasPrecision(18, 2);
            entity.Property(x => x.TotalAmount).HasPrecision(18, 2);
            entity.HasIndex(x => x.InvoiceNumber).IsUnique();
            entity.HasIndex(x => x.InvestorUserId);
            entity.HasIndex(x => x.SellerUserId);
            entity.HasIndex(x => x.WalletItemId);
            entity.HasIndex(x => x.ProductId);
            entity.HasIndex(x => x.RelatedTransactionId);
            entity.HasIndex(x => x.PaymentStatus);
            entity.HasIndex(x => x.IssuedOnUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.InvestorUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.SellerUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(x => x.WalletItem).WithMany().HasForeignKey(x => x.WalletItemId).OnDelete(DeleteBehavior.SetNull);
            entity.HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.SetNull);
            entity.HasOne<TransactionHistory>().WithMany().HasForeignKey(x => x.RelatedTransactionId).OnDelete(DeleteBehavior.SetNull);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.FromPartyUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.ToPartyUserId).OnDelete(DeleteBehavior.Restrict);
        });
    }

    private static void ConfigureAppNotification(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AppNotification>(entity =>
        {
            entity.ToTable("AppNotifications");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Type).HasConversion<int>().HasDefaultValue(NotificationType.General);
            entity.Property(x => x.ReferenceType).HasConversion<int?>();
            entity.Property(x => x.ActionUrl).HasMaxLength(500);
            entity.Property(x => x.ImageUrl).HasMaxLength(1000);
            entity.Property(x => x.Role).HasMaxLength(50);
            entity.Property(x => x.Title).IsRequired().HasMaxLength(200);
            entity.Property(x => x.Body).IsRequired().HasMaxLength(2000);
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => new { x.UserId, x.IsRead });
            entity.HasIndex(x => x.CreatedAtUtc);
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureUserPushToken(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserPushToken>(entity =>
        {
            entity.ToTable("UserPushTokens");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.DeviceToken).IsRequired().HasMaxLength(512);
            entity.Property(x => x.Platform).HasConversion<int>();
            entity.Property(x => x.DeviceName).HasMaxLength(120);
            entity.Property(x => x.IsActive).HasDefaultValue(true);
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => new { x.UserId, x.DeviceToken, x.Platform }).IsUnique();
            entity.HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureMobileAppConfiguration(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MobileAppConfiguration>(entity =>
        {
            entity.ToTable("SystemConfigration");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.ConfigKey).IsRequired().HasMaxLength(150);
            entity.Property(x => x.Name).IsRequired().HasMaxLength(150);
            entity.Property(x => x.ValueType).HasConversion<int>();
            entity.Property(x => x.ValueString).HasColumnType("nvarchar(max)");
            entity.Property(x => x.ValueDecimal).HasPrecision(18, 2);
            entity.Property(x => x.SellerAccess).HasDefaultValue(false);
            entity.Property(x => x.Description).HasMaxLength(500);
            entity.HasIndex(x => x.ConfigKey).IsUnique();
        });
    }

    private static void ConfigureSystemFeeType(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SystemFeeType>(entity =>
        {
            entity.ToTable("SystemFeeTypes");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.FeeCode).IsRequired().HasMaxLength(80);
            entity.Property(x => x.Name).IsRequired().HasMaxLength(120);
            entity.Property(x => x.Description).HasMaxLength(500);
            entity.Property(x => x.IsAdminManaged).HasDefaultValue(false);
            entity.HasIndex(x => x.FeeCode).IsUnique();
        });
    }

    private static void ConfigureSellerProductFee(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SellerProductFee>(entity =>
        {
            entity.ToTable("SellerProductFees");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.FeeCode).IsRequired().HasMaxLength(80);
            entity.Property(x => x.CalculationMode).IsRequired().HasMaxLength(80);
            entity.Property(x => x.PremiumDiscountType).HasMaxLength(30);
            entity.Property(x => x.RatePercent).HasPrecision(18, 6);
            entity.Property(x => x.MinimumAmount).HasPrecision(18, 2);
            entity.Property(x => x.FlatAmount).HasPrecision(18, 2);
            entity.Property(x => x.ValuePerUnit).HasPrecision(18, 6);
            entity.Property(x => x.FeePercent).HasPrecision(18, 6);
            entity.Property(x => x.FixedAmount).HasPrecision(18, 2);
            entity.Property(x => x.FeePerUnit).HasPrecision(18, 6);
            entity.HasIndex(x => new { x.SellerId, x.ProductId, x.FeeCode }).IsUnique();
            entity.HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(x => x.Seller).WithMany().HasForeignKey(x => x.SellerId).OnDelete(DeleteBehavior.Cascade);
        });
    }

    private static void ConfigureAdminTransactionFee(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AdminTransactionFee>(entity =>
        {
            entity.ToTable("AdminTransactionFees");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.FeeCode).IsRequired().HasMaxLength(80);
            entity.Property(x => x.CalculationMode).IsRequired().HasMaxLength(40);
            entity.Property(x => x.RatePercent).HasPrecision(18, 6);
            entity.Property(x => x.FixedAmount).HasPrecision(18, 2);
            entity.HasIndex(x => x.FeeCode).IsUnique();
        });
    }

    private static void ConfigureTransactionFeeBreakdown(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TransactionFeeBreakdown>(entity =>
        {
            entity.ToTable("TransactionFeeBreakdowns");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.FeeCode).IsRequired().HasMaxLength(80);
            entity.Property(x => x.FeeName).IsRequired().HasMaxLength(120);
            entity.Property(x => x.CalculationMode).IsRequired().HasMaxLength(80);
            entity.Property(x => x.BaseAmount).HasPrecision(18, 6);
            entity.Property(x => x.Quantity).HasPrecision(18, 6);
            entity.Property(x => x.AppliedRate).HasPrecision(18, 6);
            entity.Property(x => x.AppliedValue).HasPrecision(18, 2);
            entity.Property(x => x.Currency).IsRequired().HasMaxLength(10);
            entity.Property(x => x.SourceType).IsRequired().HasMaxLength(80);
            entity.Property(x => x.ConfigSnapshotJson).HasColumnType("nvarchar(max)");
            entity.HasIndex(x => x.TransactionHistoryId);
            entity.HasIndex(x => x.WalletActionId);
            entity.HasIndex(x => new { x.FeeCode, x.CreatedAtUtc });
        });
    }

}
