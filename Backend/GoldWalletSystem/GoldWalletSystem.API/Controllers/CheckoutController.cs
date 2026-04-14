using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/checkout")]
public class CheckoutController(AppDbContext dbContext, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("confirm")]
    public async Task<IActionResult> Confirm([FromBody] CheckoutConfirmRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var isDirectCheckout = request.ProductId.HasValue && request.Quantity.HasValue && request.Quantity.Value > 0;
        var fromCart = !isDirectCheckout;

        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        if (wallet is null)
        {
            wallet = new Wallet
            {
                UserId = request.UserId,
                CurrencyCode = "USD",
                CashBalance = 0,
                CreatedAtUtc = DateTime.UtcNow,
            };
            dbContext.Wallets.Add(wallet);
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        var lines = new List<(Product Product, int Quantity)>();
        Cart? cart = null;

        if (fromCart)
        {
            cart = await dbContext.Carts
                .Include(x => x.Items)
                .ThenInclude(x => x.Product)
                .ThenInclude(x => x.Seller)
                .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken)
                ?? throw new InvalidOperationException("Cart not found.");

            if (cart.Items.Count == 0)
                throw new InvalidOperationException("Cart is empty.");

            var selectedItems = cart.Items.AsEnumerable();
            if (request.ProductIds is { Count: > 0 })
            {
                var productIdSet = request.ProductIds.ToHashSet();
                selectedItems = selectedItems.Where(item => productIdSet.Contains(item.ProductId));
            }

            var selectedList = selectedItems.ToList();
            if (selectedList.Count == 0)
                throw new InvalidOperationException("No matching cart items were selected for checkout.");

            lines.AddRange(selectedList.Select(item => (item.Product, item.Quantity)));
        }
        else
        {
            if (!request.ProductId.HasValue || !request.Quantity.HasValue || request.Quantity.Value <= 0)
                throw new InvalidOperationException("ProductId and positive Quantity are required.");

            var product = await dbContext.Products
                .Include(x => x.Seller)
                .FirstOrDefaultAsync(x => x.Id == request.ProductId.Value && x.IsActive, cancellationToken)
                ?? throw new InvalidOperationException("Product not found.");

            lines.Add((product, request.Quantity.Value));
        }

        decimal totalAmount = 0;
        foreach (var (product, quantity) in lines)
        {
            if (product.AvailableStock < quantity)
                throw new InvalidOperationException($"Insufficient stock for {product.Name}. Available {product.AvailableStock}, requested {quantity}.");

            totalAmount += product.Price * quantity;

            var grams = ToGrams(product.WeightValue, product.WeightUnit) * quantity;
            var purity = ParsePurity(product.Description);

            dbContext.TransactionHistories.Add(new TransactionHistory
            {
                UserId = request.UserId,
                SellerId = product.SellerId,
                TransactionType = "BUY",
                Status = "pending",
                Category = product.Category.ToString(),
                Quantity = quantity,
                UnitPrice = product.Price,
                Weight = grams,
                Unit = "gram",
                Purity = purity,
                Notes = $"Checkout request from {(fromCart ? "cart" : "direct buy")}. SKU={product.Sku}",
                Amount = product.Price * quantity,
                Currency = wallet.CurrencyCode,
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        if (fromCart && cart is not null)
        {
            if (request.ProductIds is { Count: > 0 })
            {
                var productIdSet = request.ProductIds.ToHashSet();
                var matchedItems = cart.Items.Where(x => productIdSet.Contains(x.ProductId)).ToList();
                dbContext.CartItems.RemoveRange(matchedItems);
            }
            else
            {
                dbContext.CartItems.RemoveRange(cart.Items);
            }
        }

        dbContext.AuditLogs.Add(new AuditLog
        {
            UserId = request.UserId,
            Action = "CheckoutConfirmed",
            EntityName = "Checkout",
            Details = $"Items: {lines.Count}, Total: {totalAmount:F2}",
            CreatedAtUtc = DateTime.UtcNow,
        });

        await dbContext.SaveChangesAsync(cancellationToken);

        return Ok(ApiResponse<object>.Ok(new
        {
            userId = request.UserId,
            fromCart,
            itemsCount = lines.Count,
            totalAmount,
            currency = wallet.CurrencyCode,
        }, "Checkout completed"));
    }

    private static decimal ToGrams(decimal weightValue, ProductWeightUnit weightUnit) => weightUnit switch
    {
        ProductWeightUnit.Kilogram => weightValue * 1000m,
        ProductWeightUnit.Ounce => weightValue * 31.1035m,
        _ => weightValue
    };

    private static AssetType ToAssetType(ProductCategory category) => category switch
    {
        ProductCategory.Coins => AssetType.GoldCoin,
        ProductCategory.Jewelry or ProductCategory.Diamond => AssetType.Jewelry,
        ProductCategory.Silver => AssetType.Silver,
        ProductCategory.SpotMr => AssetType.GoldBar,
        ProductCategory.Gold => AssetType.GoldBar,
        _ => AssetType.GoldBar
    };

    private static decimal ParsePurity(string description)
    {
        if (description.Contains("24k", StringComparison.OrdinalIgnoreCase)) return 24m;
        if (description.Contains("22k", StringComparison.OrdinalIgnoreCase)) return 22m;
        if (description.Contains("18k", StringComparison.OrdinalIgnoreCase)) return 18m;
        return 0m;
    }

    public sealed class CheckoutConfirmRequest
    {
        public int UserId { get; set; }
        public bool FromCart { get; set; } = true;
        public List<int>? ProductIds { get; set; }
        public int? ProductId { get; set; }
        public int? Quantity { get; set; }
    }
}
