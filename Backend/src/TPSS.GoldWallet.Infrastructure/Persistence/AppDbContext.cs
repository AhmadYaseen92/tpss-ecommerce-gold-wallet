using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Identity;

namespace TPSS.GoldWallet.Infrastructure.Persistence;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options)
    : IdentityDbContext<AppIdentityUser, Microsoft.AspNetCore.Identity.IdentityRole<Guid>, Guid>(options)
{
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<UserProfile> UserProfiles => Set<UserProfile>();
    public DbSet<WalletAccount> WalletAccounts => Set<WalletAccount>();
    public DbSet<WalletTransaction> WalletTransactions => Set<WalletTransaction>();
    public DbSet<KycVerification> KycVerifications => Set<KycVerification>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Sku).HasMaxLength(32).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(256).IsRequired();
            entity.OwnsOne(x => x.Price, price =>
            {
                price.Property(p => p.Amount).HasColumnName("Price").HasPrecision(18, 2);
                price.Property(p => p.Currency).HasColumnName("Currency").HasMaxLength(8);
            });
        });

        modelBuilder.Entity<Cart>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.CustomerId).IsUnique();
            entity.HasMany(x => x.Items).WithOne().OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<CartItem>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.ProductName).HasMaxLength(256).IsRequired();
            entity.OwnsOne(x => x.UnitPrice, price =>
            {
                price.Property(p => p.Amount).HasColumnName("UnitPrice").HasPrecision(18, 2);
                price.Property(p => p.Currency).HasColumnName("UnitCurrency").HasMaxLength(8);
            });
        });

        modelBuilder.Entity<UserProfile>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Email).HasMaxLength(256).IsRequired();
            entity.HasIndex(x => x.Email).IsUnique();
        });

        modelBuilder.Entity<WalletAccount>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.CustomerId).IsUnique();
            entity.Property(x => x.Balance).HasPrecision(18, 2);
            entity.HasMany(x => x.Transactions).WithOne().HasForeignKey(x => x.WalletAccountId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<WalletTransaction>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Amount).HasPrecision(18, 2);
            entity.Property(x => x.Reference).HasMaxLength(256);
        });

        modelBuilder.Entity<KycVerification>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.CustomerId);
            entity.Property(x => x.DocumentType).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Provider).HasMaxLength(64).IsRequired();
        });

        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Action).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Resource).HasMaxLength(128).IsRequired();
            entity.Property(x => x.IpAddress).HasMaxLength(64);
            entity.HasIndex(x => x.CreatedAtUtc);
        });
    }
}
