using GoldWalletSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Database.Context;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<TransactionHistory> TransactionHistories => Set<TransactionHistory>();
    public DbSet<Invoice> Invoices => Set<Invoice>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>().HasIndex(x => x.Email).IsUnique();
        modelBuilder.Entity<Product>().HasIndex(x => x.Sku).IsUnique();
        modelBuilder.Entity<Cart>().HasOne(x => x.User).WithOne(x => x.Cart).HasForeignKey<Cart>(x => x.UserId);
        modelBuilder.Entity<CartItem>().HasOne(x => x.Cart).WithMany(x => x.Items).HasForeignKey(x => x.CartId);
        modelBuilder.Entity<CartItem>().HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId);

        modelBuilder.Entity<Product>().HasData(
            new Product { Id = 1, Name = "Gold Ring", Sku = "PRD-GOLD-RING", Description = "18k gold ring", Price = 250m, AvailableStock = 200 },
            new Product { Id = 2, Name = "Silver Necklace", Sku = "PRD-SLV-NECK", Description = "Silver necklace", Price = 120m, AvailableStock = 350 },
            new Product { Id = 3, Name = "Gold Coin", Sku = "PRD-GOLD-COIN", Description = "Investment gold coin", Price = 500m, AvailableStock = 50 }
        );

        modelBuilder.Entity<User>().HasData(
            new User { Id = 1, Email = "demo@wallet.com", FullName = "Demo User", PasswordHash = "seeded", IsActive = true }
        );

        modelBuilder.Entity<Cart>().HasData(new Cart { Id = 1, UserId = 1 });

        modelBuilder.Entity<AuditLog>().HasData(
            new AuditLog { Id = 1, UserId = 1, Action = "Seed", EntityName = "Database", Details = "Initial seed completed", CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
        );

        modelBuilder.Entity<TransactionHistory>().HasData(
            new TransactionHistory { Id = 1, UserId = 1, TransactionType = "WalletTopup", Amount = 1000, Currency = "USD", Reference = "TXN-0001", CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
        );

        modelBuilder.Entity<Invoice>().HasData(
            new Invoice { Id = 1, UserId = 1, InvoiceNumber = "INV-0001", SubTotal = 500, TaxAmount = 25, TotalAmount = 525, Status = "Paid", IssuedOnUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc), CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc) }
        );
    }
}
