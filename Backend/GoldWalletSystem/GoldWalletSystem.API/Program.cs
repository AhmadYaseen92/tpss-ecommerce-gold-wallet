using GoldWalletSystem.API.Extensions;
using GoldWalletSystem.API.Middleware;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Infrastructure.DependencyInjection;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using GoldWalletSystem.Domain.Enums;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddOpenApi();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=localhost;Database=GoldWalletSystemDb;Trusted_Connection=True;TrustServerCertificate=True;";

builder.Services.AddInfrastructure(connectionString);
builder.Services.AddApiLayer();

var jwtKey = builder.Configuration["Jwt:Key"] ?? "Please-Override-In-Production-32-Char-Min";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "GoldWallet";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "GoldWalletClient";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            NameClaimType = "sub",
            RoleClaimType = "role"
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseMiddleware<GlobalExceptionMiddleware>();
app.UseStaticFiles();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();
    await dbContext.Database.MigrateAsync();

    var seedSellers = new[]
    {
        new { Name = "Imseeh", Code = "IMSEEH", Email = "contact@imseeh.com", Phone = "+962700000001", Address = "Amman, Jordan" },
        new { Name = "Sakkejha", Code = "SAKKEJHA", Email = "contact@sakkejha.com", Phone = "+962700000002", Address = "Zarqa, Jordan" },
        new { Name = "Danaa", Code = "DANAA", Email = "contact@danaa.com", Phone = "+962700000003", Address = "Irbid, Jordan" }
    };

    foreach (var seller in seedSellers)
    {
        if (await dbContext.Sellers.AnyAsync(x => x.Code == seller.Code))
        {
            continue;
        }

        dbContext.Sellers.Add(new Seller
        {
            Name = seller.Name,
            Code = seller.Code,
            ContactEmail = seller.Email,
            ContactPhone = seller.Phone,
            Address = seller.Address,
            IsActive = true,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
    }
    await dbContext.SaveChangesAsync();

    var allSellerIds = await dbContext.Sellers.OrderBy(x => x.Id).Select(x => x.Id).ToListAsync();
    var defaultSellerId = allSellerIds.First();

    if (!await dbContext.Users.AnyAsync())
    {
        var seededUser = new User
        {
            FullName = "Test Investor",
            Email = "investor@goldwallet.com",
            PasswordHash = passwordHasher.Hash("Password@123"),
            Role = SystemRoles.Investor,
            PhoneNumber = "+962700000000",
            IsActive = true,
            SellerId = defaultSellerId,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        dbContext.Users.Add(seededUser);
        await dbContext.SaveChangesAsync();

        dbContext.Wallets.Add(new Wallet
        {
            UserId = seededUser.Id,
            CashBalance = 10000,
            CurrencyCode = "USD",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        dbContext.Carts.Add(new Cart
        {
            UserId = seededUser.Id,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        await dbContext.SaveChangesAsync();
    }

    if (await dbContext.Products.CountAsync() < 50)
    {
        var productNames = new[]
        {
            "Gold Bar 1 oz", "Gold Bar 10 g", "Gold Bar 100 g", "Gold Coin 1 oz", "Gold Cast Bar 50 g",
            "Silver Bar 1 kg", "Silver Bar 100 g", "Silver Coin 1 oz", "Silver Round 1 oz", "Silver Stacker 5 oz",
            "Platinum Bar 1 oz", "Platinum Coin 1 oz", "Palladium Bar 1 oz", "Palladium Coin 1 oz", "Mixed Bullion Pack",
            "Gold Necklace 18K", "Gold Ring 18K", "Gold Bracelet 18K", "Diamond Ring", "Emerald Pendant"
        };

        var products = new List<Product>();

        static (decimal Value, ProductWeightUnit Unit) ParseWeight(string source)
        {
            var normalized = source.ToLowerInvariant();
            if (normalized.Contains("1 kg")) return (1, ProductWeightUnit.Kilogram);
            if (normalized.Contains("100 g")) return (100, ProductWeightUnit.Gram);
            if (normalized.Contains("50 g")) return (50, ProductWeightUnit.Gram);
            if (normalized.Contains("10 g")) return (10, ProductWeightUnit.Gram);
            if (normalized.Contains("5 g")) return (5, ProductWeightUnit.Gram);
            if (normalized.Contains("1 oz")) return (1, ProductWeightUnit.Ounce);
            return (1, ProductWeightUnit.Gram);
        }

        static ProductCategory ResolveCategory(string source)
        {
            var normalized = source.ToLowerInvariant();
            if (normalized.Contains("coin")) return ProductCategory.Coin;
            if (normalized.Contains("necklace") || normalized.Contains("ring") || normalized.Contains("bracelet") || normalized.Contains("pendant"))
                return ProductCategory.Jewelry;
            if (normalized.Contains("bar")) return ProductCategory.Bar;
            if (normalized.Contains("gold")) return ProductCategory.Gold;
            if (normalized.Contains("silver")) return ProductCategory.Silver;
            return ProductCategory.Other;
        }

        for (var i = 0; i < 60; i++)
        {
            var sellerId = allSellerIds[i % allSellerIds.Count];
            var template = productNames[i % productNames.Length];
            var sku = $"SKU-{sellerId:D2}-{i + 1:D3}";
            var price = 100 + (i * 13.75m);
            var (weightValue, weightUnit) = ParseWeight(template);
            var category = ResolveCategory(template);

            products.Add(new Product
            {
                Name = $"{template} #{i + 1}",
                Sku = sku,
                Description = $"Seeded product for seller {sellerId}.",
                Category = category,
                WeightValue = weightValue,
                WeightUnit = weightUnit,
                Price = price,
                AvailableStock = 20 + (i % 40),
                IsActive = true,
                SellerId = sellerId,
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            });
        }

        var existingSkus = await dbContext.Products.AsNoTracking().Select(x => x.Sku).ToHashSetAsync();
        dbContext.Products.AddRange(products.Where(product => !existingSkus.Contains(product.Sku)));
        await dbContext.SaveChangesAsync();
    }

    var productsMissingWeight = await dbContext.Products
        .Where(x => x.WeightValue <= 0)
        .ToListAsync();

    foreach (var product in productsMissingWeight)
    {
        var name = product.Name;
        var normalized = name.ToLowerInvariant();
        product.WeightValue = normalized.Contains("1 kg") ? 1
            : normalized.Contains("100 g") ? 100
            : normalized.Contains("50 g") ? 50
            : normalized.Contains("20 g") ? 20
            : normalized.Contains("10 g") ? 10
            : normalized.Contains("5 g") ? 5
            : normalized.Contains("1 oz") ? 1
            : 1;
        product.WeightUnit = normalized.Contains("kg")
            ? ProductWeightUnit.Kilogram
            : normalized.Contains("oz")
                ? ProductWeightUnit.Ounce
                : ProductWeightUnit.Gram;
    }

    if (productsMissingWeight.Count > 0)
    {
        await dbContext.SaveChangesAsync();
    }
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
