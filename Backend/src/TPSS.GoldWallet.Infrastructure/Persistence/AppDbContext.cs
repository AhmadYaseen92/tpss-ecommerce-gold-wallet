using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Infrastructure.Persistence;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
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
            entity.HasMany(x => x.Items)
                .WithOne()
                .OnDelete(DeleteBehavior.Cascade);
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

        base.OnModelCreating(modelBuilder);
    }
}
