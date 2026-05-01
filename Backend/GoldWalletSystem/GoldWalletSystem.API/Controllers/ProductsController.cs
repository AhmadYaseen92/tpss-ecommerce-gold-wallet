using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.API.Models;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/products")]
public class ProductsController(IProductService productService, AppDbContext dbContext, IWebHostEnvironment environment, API.Services.IMarketplaceRealtimeNotifier realtimeNotifier) : ControllerBase
{
    private static readonly Dictionary<string, (string CurrencyCode, decimal ExchangeRate)> MarketCurrencyMap = new(StringComparer.OrdinalIgnoreCase)
    {
        ["UAE"] = ("AED", 3.67m),
        ["KSA"] = ("SAR", 3.75m),
        ["JORDAN"] = ("JOD", 0.71m),
        ["EGYPT"] = ("EGP", 48.50m),
        ["INDIA"] = ("INR", 83.20m),
    };
    [HttpPost("search")]
    public async Task<IActionResult> Search([FromBody] ProductSearchRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await productService.GetProductsAsync(request.PageNumber, request.PageSize, request.Category, cancellationToken);
        var normalizedItems = data.Items
            .Select(product => product with
            {
                ImageUrl = NormalizeRelativeImagePath(product.ImageUrl),
                VideoUrl = NormalizeRelativeVideoPath(product.VideoUrl)
            })
            .ToList();

        var normalizedData = data with { Items = normalizedItems };
        return Ok(ApiResponse<PagedResult<ProductDto>>.Ok(normalizedData));
    }

    [HttpGet("management")]
    public async Task<IActionResult> GetManagementList(CancellationToken cancellationToken = default)
    {
        if (!IsSellerOrAdmin()) return Forbid();
        var role = User.Claims.FirstOrDefault(c => c.Type == "role")?.Value ?? string.Empty;
        var sellerIdClaim = int.TryParse(User.Claims.FirstOrDefault(c => c.Type == "seller_id")?.Value, out var parsedSellerId)
            ? parsedSellerId
            : 0;

        var query = dbContext.Products.AsNoTracking().AsQueryable();
        if (!string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase) && sellerIdClaim > 0)
        {
            query = query.Where(x => x.SellerId == sellerIdClaim);
        }

        var items = await query
            .OrderByDescending(x => x.Id)
            .Select(x => new ProductManagementDto
            {
                Id = x.Id,
                Name = x.Name,
                Sku = x.Sku,
                Description = x.Description,
                ImageUrl = x.ImageUrl,
                VideoUrl = x.VideoUrl,
                Category = x.Category,
                MaterialType = x.MaterialType,
                FormType = x.FormType,
                DisplayCategoryLabel = $"{x.MaterialType} {x.FormType}",
                PricingMode = x.PricingMode,
                PurityKarat = x.PurityKarat,
                PurityFactor = x.PurityFactor,
                WeightValue = x.WeightValue,
                WeightUnit = x.WeightUnit,
                BaseMarketPrice = x.BaseMarketPrice,
                AutoPrice = x.AutoPrice,
                FixedPrice = x.FixedPrice,
                SellPrice = x.AskPrice,
                CurrencyCode = x.CurrencyCode,
                OfferPercent = x.OfferPercent,
                OfferNewPrice = x.OfferNewPrice,
                OfferType = x.OfferType,
                IsHasOffer = x.IsHasOffer,
                AvailableStock = x.AvailableStock,
                IsActive = x.IsActive,
                SellerId = x.SellerId
            })
            .ToListAsync(cancellationToken);

        var sellerCurrencyMap = await dbContext.Sellers.AsNoTracking()
            .Select(x => new { x.Id, x.MarketType })
            .ToDictionaryAsync(x => x.Id, x => ResolveCurrencyCodeByMarketType(x.MarketType), cancellationToken);

        foreach (var item in items)
        {
            item.ImageUrl = NormalizeRelativeImagePath(item.ImageUrl);
            item.VideoUrl = NormalizeRelativeVideoPath(item.VideoUrl);
            if (string.IsNullOrWhiteSpace(item.CurrencyCode) || string.Equals(item.CurrencyCode, "USD", StringComparison.OrdinalIgnoreCase))
            {
                if (sellerCurrencyMap.TryGetValue(item.SellerId, out var sellerCurrency))
                {
                    item.CurrencyCode = sellerCurrency;
                }
            }
        }
        return Ok(ApiResponse<List<ProductManagementDto>>.Ok(items));
    }

    [HttpGet("management/{id:int}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken = default)
    {
        if (!IsSellerOrAdmin()) return Forbid();
        var role = User.Claims.FirstOrDefault(c => c.Type == "role")?.Value ?? string.Empty;
        var sellerScope = ResolveSellerScope();

        var query = dbContext.Products.AsNoTracking().Where(x => x.Id == id);
        if (!string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase))
        {
            if (!sellerScope.HasValue) return Forbid();
            query = query.Where(x => x.SellerId == sellerScope.Value);
        }

        var item = await query.Select(x => new ProductManagementDto
        {
            Id = x.Id,
            Name = x.Name,
            Sku = x.Sku,
            Description = x.Description,
            ImageUrl = x.ImageUrl,
            VideoUrl = x.VideoUrl,
            Category = x.Category,
            MaterialType = x.MaterialType,
            FormType = x.FormType,
            DisplayCategoryLabel = $"{x.MaterialType} {x.FormType}",
            PricingMode = x.PricingMode,
            PurityKarat = x.PurityKarat,
            PurityFactor = x.PurityFactor,
            WeightValue = x.WeightValue,
            WeightUnit = x.WeightUnit,
            BaseMarketPrice = x.BaseMarketPrice,
            AutoPrice = x.AutoPrice,
            FixedPrice = x.FixedPrice,
            SellPrice = x.AskPrice,
            CurrencyCode = x.CurrencyCode,
            OfferPercent = x.OfferPercent,
            OfferNewPrice = x.OfferNewPrice,
            OfferType = x.OfferType,
            IsHasOffer = x.IsHasOffer,
            AvailableStock = x.AvailableStock,
            IsActive = x.IsActive,
            SellerId = x.SellerId
        }).FirstOrDefaultAsync(cancellationToken);

        if (item is not null)
        {
            item.ImageUrl = NormalizeRelativeImagePath(item.ImageUrl);
            item.VideoUrl = NormalizeRelativeVideoPath(item.VideoUrl);
            if (string.IsNullOrWhiteSpace(item.CurrencyCode) || string.Equals(item.CurrencyCode, "USD", StringComparison.OrdinalIgnoreCase))
            {
                item.CurrencyCode = await dbContext.Sellers.AsNoTracking()
                    .Where(x => x.Id == item.SellerId)
                    .Select(x => ResolveCurrencyCodeByMarketType(x.MarketType))
                    .FirstOrDefaultAsync(cancellationToken);
            }
        }

        return item is null
            ? NotFound(ApiResponse<object>.Fail("Product not found", 404))
            : Ok(ApiResponse<ProductManagementDto>.Ok(item));
    }

    [HttpPost("management")]
    public async Task<IActionResult> Create([FromForm] ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
        if (!IsSellerOrAdmin()) return Forbid();
        if (await dbContext.Products.AnyAsync(x => x.Sku == request.Sku, cancellationToken))
        {
            return BadRequest(ApiResponse<object>.Fail("SKU already exists", 400));
        }

        var sellerId = ResolveSellerId(request.SellerId);

        var product = new Product
        {
            Name = request.Name,
            Sku = request.Sku,
            Description = request.Description,
            ImageUrl = await SaveImageAsync(request.Image, request.ExistingImageUrl, cancellationToken),
            VideoUrl = await SaveVideoAsync(request.Video, request.ExistingVideoUrl, request.VideoDurationSeconds, cancellationToken),
            Category = ToLegacyCategory(request.MaterialType),
            MaterialType = request.MaterialType,
            FormType = request.FormType,
            PricingMode = request.PricingMode,
            PurityKarat = request.PurityKarat,
            PurityFactor = request.PurityFactor,
            WeightValue = request.WeightValue,
            WeightUnit = ProductWeightUnit.Gram,
            BaseMarketPrice = await ResolveMarketPriceByMaterialAsync(request.MaterialType, sellerId, cancellationToken),
            FixedPrice = request.FixedPrice,
            OfferPercent = request.OfferPercent,
            OfferNewPrice = request.OfferNewPrice,
            OfferType = request.OfferType,
            IsHasOffer = request.OfferType != ProductOfferType.None,
            AvailableStock = request.AvailableStock,
            IsActive = request.IsActive,
            SellerId = sellerId
        };

        dbContext.Products.Add(product);
        await RecalculateComputedPricesAsync(product, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"product:create:{product.Id}", cancellationToken);

        return Ok(ApiResponse<string>.Ok("Created"));
    }

    [HttpPut("management/{id:int}")]
    public async Task<IActionResult> Update(int id, [FromForm] ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
        if (!IsSellerOrAdmin()) return Forbid();
        var product = await dbContext.Products.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (product is null)
        {
            return NotFound(ApiResponse<object>.Fail("Product not found", 404));
        }

        var role = User.Claims.FirstOrDefault(c => c.Type == "role")?.Value ?? string.Empty;
        if (!string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase))
        {
            var sellerScope = ResolveSellerScope();
            if (!sellerScope.HasValue || product.SellerId != sellerScope.Value)
            {
                return Forbid();
            }
        }

        if (!string.Equals(product.Sku, request.Sku, StringComparison.OrdinalIgnoreCase)
            && await dbContext.Products.AnyAsync(x => x.Sku == request.Sku && x.Id != id, cancellationToken))
        {
            return BadRequest(ApiResponse<object>.Fail("SKU already exists", 400));
        }

        var nextSellerId = ResolveSellerId(request.SellerId, product.SellerId);

        product.Name = request.Name;
        product.Sku = request.Sku;
        product.Description = request.Description;
        product.ImageUrl = await SaveImageAsync(request.Image, request.ExistingImageUrl ?? product.ImageUrl, cancellationToken);
        product.VideoUrl = await SaveVideoAsync(request.Video, request.ExistingVideoUrl ?? product.VideoUrl, request.VideoDurationSeconds, cancellationToken);
        product.Category = ToLegacyCategory(request.MaterialType);
        product.MaterialType = request.MaterialType;
        product.FormType = request.FormType;
        product.PricingMode = request.PricingMode;
        product.PurityKarat = request.PurityKarat;
        product.PurityFactor = request.PurityFactor;
        product.WeightValue = request.WeightValue;
        product.WeightUnit = ProductWeightUnit.Gram;
        product.BaseMarketPrice = await ResolveMarketPriceByMaterialAsync(request.MaterialType, nextSellerId, cancellationToken);
        product.FixedPrice = request.FixedPrice;
        product.OfferPercent = request.OfferPercent;
        product.OfferNewPrice = request.OfferNewPrice;
        product.OfferType = request.OfferType;
        product.IsHasOffer = request.OfferType != ProductOfferType.None;
        product.AvailableStock = request.AvailableStock;
        product.IsActive = request.IsActive;
        product.SellerId = nextSellerId;

        await RecalculateComputedPricesAsync(product, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"product:update:{product.Id}", cancellationToken);
        return Ok(ApiResponse<string>.Ok("Updated"));
    }

    [HttpDelete("management/{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        if (!IsSellerOrAdmin()) return Forbid();
        var product = await dbContext.Products.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (product is null)
        {
            return NotFound(ApiResponse<object>.Fail("Product not found", 404));
        }

        var role = User.Claims.FirstOrDefault(c => c.Type == "role")?.Value ?? string.Empty;
        if (!string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase))
        {
            var sellerScope = ResolveSellerScope();
            if (!sellerScope.HasValue || product.SellerId != sellerScope.Value)
            {
                return Forbid();
            }
        }

        dbContext.Products.Remove(product);
        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"product:delete:{id}", cancellationToken);
        return Ok(ApiResponse<string>.Ok("Deleted"));
    }

    [HttpGet("categories")]
    public IActionResult GetCategories()
    {
        var data = Enum.GetValues<ProductCategory>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("weight-units")]
    public IActionResult GetWeightUnits()
    {
        var data = Enum.GetValues<ProductWeightUnit>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }


    [HttpGet("material-types")]
    public IActionResult GetMaterialTypes()
    {
        var data = Enum.GetValues<ProductMaterialType>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("form-types")]
    public IActionResult GetFormTypes()
    {
        var data = Enum.GetValues<ProductFormType>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("pricing-modes")]
    public IActionResult GetPricingModes()
    {
        var data = Enum.GetValues<ProductPricingMode>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("purity-karats")]
    public IActionResult GetPurityKarats()
    {
        var data = Enum.GetValues<ProductPurityKarat>().Select(x => new EnumItemDto((int)x, x.ToString().Replace("K", "K ").Trim())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("offer-types")]
    public IActionResult GetOfferTypes()
    {
        var data = Enum.GetValues<ProductOfferType>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    private async Task<decimal> ResolveFinalPriceAsync(ProductUpsertRequest request, int sellerId, CancellationToken cancellationToken)
    {
        var marketPrice = await ResolveMarketPriceByMaterialAsync(request.MaterialType, sellerId, cancellationToken);
        var autoPrice = ProductPricingCalculator.CalculateAutoPrice(
                request.MaterialType,
                marketPrice,
                request.WeightValue,
                request.PurityFactor);

        var sourcePrice = request.PricingMode == ProductPricingMode.Manual ? request.FixedPrice : autoPrice;
        return ProductPricingCalculator.ApplyOffer(sourcePrice, request.OfferType, request.OfferPercent, request.OfferNewPrice);
    }

    [HttpGet("market-prices")]
    public async Task<IActionResult> GetMarketPrices(CancellationToken cancellationToken = default)
    {
        if (!IsSellerOrAdmin()) return Forbid();
        var sellerId = ResolveSellerScope();
        var config = await GetMarketPriceConfigAsync(sellerId, cancellationToken);
        return Ok(ApiResponse<MarketPriceConfigDto>.Ok(config));
    }

    [HttpPost("market-prices")]
    public async Task<IActionResult> UpsertMarketPrices([FromBody] MarketPriceConfigDto request, CancellationToken cancellationToken = default)
    {
        if (!IsSellerOrAdmin()) return Forbid();
        var sellerId = ResolveSellerScope();
        if (!sellerId.HasValue)
            return BadRequest(ApiResponse<object>.Fail("Seller scope is required for market prices.", 400));

        var seller = await dbContext.Sellers.FirstOrDefaultAsync(x => x.Id == sellerId.Value, cancellationToken);
        if (seller is null)
            return NotFound(ApiResponse<object>.Fail("Seller not found.", 404));

        seller.GoldAskPrice = request.GoldAskPerOunce;
        seller.SilverAskPrice = request.SilverAskPerOunce;
        seller.DiamondAskPrice = request.DiamondPerCarat;
        seller.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        seller.GoldBidPrice = request.GoldBidPerOunce;
        seller.SilverBidPrice = request.SilverBidPerOunce;
        await RecalculateAutoPricedProductsAsync(sellerId, cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"market-price:{sellerId}", cancellationToken);
        return Ok(ApiResponse<MarketPriceConfigDto>.Ok(request));
    }

    private async Task<decimal> ResolveMarketPriceByMaterialAsync(ProductMaterialType materialType, int sellerId, CancellationToken cancellationToken)
    {
        var config = await GetMarketPriceConfigAsync(sellerId, cancellationToken);
        return materialType switch
        {
            ProductMaterialType.Gold => config.GoldAskPerOunce,
            ProductMaterialType.Silver => config.SilverAskPerOunce,
            ProductMaterialType.Diamond => config.DiamondPerCarat,
            _ => 0m
        };
    }

    private async Task<MarketPriceConfigDto> GetMarketPriceConfigAsync(int? sellerId, CancellationToken cancellationToken)
    {
        if (!sellerId.HasValue)
            return new MarketPriceConfigDto();

        var seller = await dbContext.Sellers.AsNoTracking().FirstOrDefaultAsync(x => x.Id == sellerId.Value, cancellationToken);
        if (seller is null)
            return new MarketPriceConfigDto();

        return new MarketPriceConfigDto
        {
            GoldAskPerOunce = seller.GoldAskPrice ?? 0m,
            SilverAskPerOunce = seller.SilverAskPrice ?? 0m,
            GoldBidPerOunce = seller.GoldBidPrice ?? (seller.GoldAskPrice ?? 0m),
            SilverBidPerOunce = seller.SilverBidPrice ?? (seller.SilverAskPrice ?? 0m),
            DiamondPerCarat = seller.DiamondAskPrice ?? 0m
        };
    }

    private async Task RecalculateAutoPricedProductsAsync(int? scopeSellerId, CancellationToken cancellationToken)
    {
        var productsQuery = dbContext.Products.Where(x => x.PricingMode == ProductPricingMode.Auto);
        if (scopeSellerId.HasValue)
        {
            productsQuery = productsQuery.Where(x => x.SellerId == scopeSellerId.Value);
        }

        var products = await productsQuery.ToListAsync(cancellationToken);
        foreach (var product in products)
        {
            var marketPrice = await ResolveMarketPriceByMaterialAsync(product.MaterialType, product.SellerId, cancellationToken);
            var autoPrice = ProductPricingCalculator.CalculateAutoPrice(
                product.MaterialType,
                marketPrice,
                product.WeightValue,
                product.PurityFactor);

            product.BaseMarketPrice = marketPrice;
            product.AutoPrice = autoPrice;
            await RecalculateComputedPricesAsync(product, cancellationToken);
            product.UpdatedAtUtc = DateTime.UtcNow;
        }

        if (products.Count > 0)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }


    private async Task RecalculateComputedPricesAsync(Product product, CancellationToken cancellationToken)
    {
        var sellerPricing = await dbContext.Sellers.AsNoTracking()
            .Where(x => x.Id == product.SellerId)
            .Select(x => new
            {
                x.MarketType,
                x.GoldBidPrice,
                x.SilverBidPrice,
                x.DiamondBidPrice
            })
            .FirstOrDefaultAsync(cancellationToken);
        var marketType = sellerPricing?.MarketType;
        var marketKey = string.IsNullOrWhiteSpace(marketType) ? "UAE" : marketType.Trim().ToUpperInvariant();
        var marketInfo = MarketCurrencyMap.TryGetValue(marketKey, out var resolved) ? resolved : MarketCurrencyMap["UAE"];
        var configuredRate = await dbContext.MobileAppConfigurations.AsNoTracking()
            .Where(x => x.ConfigKey == $"Market.{NormalizeMarketKey(marketKey)}.UsdToLocalRate")
            .Select(x => x.ValueDecimal)
            .FirstOrDefaultAsync(cancellationToken);
        var usdToLocalRate = configuredRate ?? marketInfo.ExchangeRate;

        var autoPrice = (product.BaseMarketPrice / 31.1035m) * product.WeightValue * product.PurityFactor * usdToLocalRate;

        product.CurrencyCode = marketInfo.CurrencyCode;
        product.AutoPrice = decimal.Round(autoPrice, 2);
        var sourcePrice = product.PricingMode == ProductPricingMode.Manual ? product.FixedPrice : product.AutoPrice;
        product.AskPrice = ProductPricingCalculator.ApplyOffer(sourcePrice, product.OfferType, product.OfferPercent, product.OfferNewPrice);
        var bidPerOunce = product.MaterialType switch
        {
            ProductMaterialType.Gold => sellerPricing?.GoldBidPrice ?? 0m,
            ProductMaterialType.Silver => sellerPricing?.SilverBidPrice ?? 0m,
            ProductMaterialType.Diamond => sellerPricing?.DiamondBidPrice ?? 0m,
            _ => 0m
        };
        product.BidPrice = bidPerOunce > 0
            ? decimal.Round((bidPerOunce / 31.1035m) * product.WeightValue * product.PurityFactor * usdToLocalRate, 2)
            : product.AskPrice;
        
    }

    private static string NormalizeMarketKey(string marketKey) => marketKey switch
    {
        "JORDAN" => "Jordan",
        "EGYPT" => "Egypt",
        "INDIA" => "India",
        "KSA" => "KSA",
        _ => "UAE"
    };

    private int? ResolveSellerScope()
    {
        var role = GetRoleClaim();
        if (string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        return int.TryParse(GetSellerIdClaim(), out var sellerId)
            ? sellerId
            : null;
    }

    private bool IsSellerOrAdmin()
    {
        var role = GetRoleClaim();
        return string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase)
               || string.Equals(role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase);
    }

    private static ProductCategory ToLegacyCategory(ProductMaterialType materialType)
    {
        return materialType switch
        {
            ProductMaterialType.Gold => ProductCategory.Gold,
            ProductMaterialType.Silver => ProductCategory.Silver,
            ProductMaterialType.Diamond => ProductCategory.Diamond,
            _ => ProductCategory.Gold
        };
    }

    private static string ResolveCurrencyCodeByMarketType(string? marketType)
    {
        return marketType?.Trim().ToUpperInvariant() switch
        {
            "UAE" => "AED",
            "KSA" => "SAR",
            "JORDAN" => "JOD",
            "EGYPT" => "EGP",
            "INDIA" => "INR",
            _ => "USD"
        };
    }

    private int ResolveSellerId(int? requestedSellerId, int fallbackSellerId = 0)
    {
        var role = GetRoleClaim();
        if (string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase))
        {
            var resolved = requestedSellerId ?? fallbackSellerId;
            if (resolved <= 0) throw new InvalidOperationException("SellerId is required for admin operations.");
            return resolved;
        }

        if (int.TryParse(GetSellerIdClaim(), out var sellerId) && sellerId > 0)
            return sellerId;

        throw new UnauthorizedAccessException("Seller scope is required.");
    }

    private string GetRoleClaim()
        => User.Claims.FirstOrDefault(c => c.Type == "role")?.Value?.Trim()
           ?? User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value?.Trim()
           ?? string.Empty;

    private string? GetSellerIdClaim()
        => User.Claims.FirstOrDefault(c => c.Type == "seller_id")?.Value?.Trim();

    private async Task<string> SaveImageAsync(IFormFile? image, string? existingImageUrl, CancellationToken cancellationToken)
    {
        if (image is null || image.Length == 0)
        {
            return NormalizeRelativeImagePath(existingImageUrl);
        }

        var root = environment.WebRootPath;
        if (string.IsNullOrWhiteSpace(root))
        {
            root = Path.Combine(environment.ContentRootPath, "wwwroot");
        }

        var targetDirectory = Path.Combine(root, "images", "products");
        Directory.CreateDirectory(targetDirectory);

        var extension = Path.GetExtension(image.FileName);
        var fileName = $"product-{Guid.NewGuid():N}{extension}";
        var fullPath = Path.Combine(targetDirectory, fileName);

        await using var stream = System.IO.File.Create(fullPath);
        await image.CopyToAsync(stream, cancellationToken);

        return NormalizeRelativeImagePath($"/images/products/{fileName}");
    }

    private async Task<string> SaveVideoAsync(IFormFile? video, string? existingVideoUrl, int? durationSeconds, CancellationToken cancellationToken)
    {
        if (video is null || video.Length == 0)
        {
            return NormalizeRelativeVideoPath(existingVideoUrl);
        }

        var maxDuration = await ReadProductVideoMaxDurationSecondsAsync(cancellationToken);
        if (durationSeconds is null || durationSeconds <= 0)
        {
            throw new InvalidOperationException("Video duration is required when uploading a product video.");
        }

        if (durationSeconds.Value > maxDuration)
        {
            throw new InvalidOperationException($"Product video exceeds max duration of {maxDuration} seconds.");
        }

        var root = environment.WebRootPath;
        if (string.IsNullOrWhiteSpace(root))
        {
            root = Path.Combine(environment.ContentRootPath, "wwwroot");
        }

        var targetDirectory = Path.Combine(root, "videos", "products");
        Directory.CreateDirectory(targetDirectory);

        var extension = Path.GetExtension(video.FileName);
        var fileName = $"product-video-{Guid.NewGuid():N}{extension}";
        var fullPath = Path.Combine(targetDirectory, fileName);

        await using var stream = System.IO.File.Create(fullPath);
        await video.CopyToAsync(stream, cancellationToken);

        return NormalizeRelativeVideoPath($"/videos/products/{fileName}");
    }

    private async Task<int> ReadProductVideoMaxDurationSecondsAsync(CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.AsNoTracking()
            .FirstOrDefaultAsync(x => x.ConfigKey == MobileAppConfigurationKeys.ProductVideoMaxDurationSeconds, cancellationToken);

        var value = config?.ValueInt ?? 30;
        return value <= 0 ? 30 : value;
    }

    private string NormalizeRelativeImagePath(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return string.Empty;
        }

        var trimmed = path.Trim();
        if (Uri.TryCreate(trimmed, UriKind.Absolute, out var absoluteUri))
        {
            var isCurrentHost = string.Equals(absoluteUri.Host, Request.Host.Host, StringComparison.OrdinalIgnoreCase);
            var isLocalHost = string.Equals(absoluteUri.Host, "localhost", StringComparison.OrdinalIgnoreCase)
                              || string.Equals(absoluteUri.Host, "127.0.0.1", StringComparison.OrdinalIgnoreCase)
                              || string.Equals(absoluteUri.Host, "::1", StringComparison.OrdinalIgnoreCase);

            if (isCurrentHost || isLocalHost)
            {
                return $"{absoluteUri.AbsolutePath}{absoluteUri.Query}";
            }

            return trimmed;
        }

        return trimmed.StartsWith('/') ? trimmed : $"/{trimmed}";
    }

    private string NormalizeRelativeVideoPath(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return string.Empty;
        }

        var trimmed = path.Trim();
        if (Uri.TryCreate(trimmed, UriKind.Absolute, out var absoluteUri))
        {
            var isCurrentHost = string.Equals(absoluteUri.Host, Request.Host.Host, StringComparison.OrdinalIgnoreCase);
            var isLocalHost = string.Equals(absoluteUri.Host, "localhost", StringComparison.OrdinalIgnoreCase)
                              || string.Equals(absoluteUri.Host, "127.0.0.1", StringComparison.OrdinalIgnoreCase)
                              || string.Equals(absoluteUri.Host, "::1", StringComparison.OrdinalIgnoreCase);

            if (isCurrentHost || isLocalHost)
            {
                return $"{absoluteUri.AbsolutePath}{absoluteUri.Query}";
            }

            return trimmed;
        }

        return trimmed.StartsWith('/') ? trimmed : $"/{trimmed}";
    }
}
