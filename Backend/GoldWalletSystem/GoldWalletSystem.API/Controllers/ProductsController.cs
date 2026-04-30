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
using System.Text.Json;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/products")]
public class ProductsController(IProductService productService, API.Services.IProductWriteService productWriteService, AppDbContext dbContext, IWebHostEnvironment environment, API.Services.IMarketplaceRealtimeNotifier realtimeNotifier, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
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
        var items = await productService.GetManagementListAsync(cancellationToken);
        return Ok(ApiResponse<List<ProductManagementDto>>.Ok(items));
    }

    [HttpGet("management/{id:int}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken = default)
    {
        var item = await productService.GetManagementByIdAsync(id, cancellationToken);
        return item is null
            ? NotFound(ApiResponse<object>.Fail("Product not found", 404))
            : Ok(ApiResponse<ProductManagementDto>.Ok(item));
    }

    [HttpPost("management")]
    public async Task<IActionResult> Create([FromForm] ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var result = await productWriteService.CreateAsync(request, cancellationToken);
        return Ok(ApiResponse<string>.Ok(result));
    }

    [HttpPut("management/{id:int}")]
    public async Task<IActionResult> Update(int id, [FromForm] ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var result = await productWriteService.UpdateAsync(id, request, cancellationToken);
        return Ok(ApiResponse<string>.Ok(result));
    }

    [HttpDelete("management/{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        var result = await productWriteService.DeleteAsync(id, cancellationToken);
        return Ok(ApiResponse<string>.Ok(result));
    }

    [HttpGet("categories")]
    public async Task<IActionResult> GetCategories()
    {
        var data = await productService.GetCategoriesAsync();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("weight-units")]
    public async Task<IActionResult> GetWeightUnits()
    {
        var data = await productService.GetWeightUnitsAsync();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }


    [HttpGet("material-types")]
    public async Task<IActionResult> GetMaterialTypes()
    {
        var data = await productService.GetMaterialTypesAsync();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("form-types")]
    public async Task<IActionResult> GetFormTypes()
    {
        var data = await productService.GetFormTypesAsync();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("pricing-modes")]
    public async Task<IActionResult> GetPricingModes()
    {
        var data = await productService.GetPricingModesAsync();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("purity-karats")]
    public async Task<IActionResult> GetPurityKarats()
    {
        var data = await productService.GetPurityKaratsAsync();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("offer-types")]
    public async Task<IActionResult> GetOfferTypes()
    {
        var data = await productService.GetOfferTypesAsync();
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

        seller.GoldPrice = request.GoldPerOunce;
        seller.SilverPrice = request.SilverPerOunce;
        seller.DiamondPrice = request.DiamondPerCarat;
        seller.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        await RecalculateAutoPricedProductsAsync(sellerId, cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"market-price:{sellerId}", cancellationToken);
        return Ok(ApiResponse<MarketPriceConfigDto>.Ok(request));
    }

    private async Task<decimal> ResolveMarketPriceByMaterialAsync(ProductMaterialType materialType, int sellerId, CancellationToken cancellationToken)
    {
        var config = await GetMarketPriceConfigAsync(sellerId, cancellationToken);
        return materialType switch
        {
            ProductMaterialType.Gold => config.GoldPerOunce,
            ProductMaterialType.Silver => config.SilverPerOunce,
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
            GoldPerOunce = seller.GoldPrice ?? 0m,
            SilverPerOunce = seller.SilverPrice ?? 0m,
            DiamondPerCarat = seller.DiamondPrice ?? 0m
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
            RecalculateComputedPrices(product);
            product.UpdatedAtUtc = DateTime.UtcNow;
        }

        if (products.Count > 0)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }


    private static void RecalculateComputedPrices(Product product)
    {
        var autoPrice = ProductPricingCalculator.CalculateAutoPrice(
            product.MaterialType,
            product.BaseMarketPrice,
            product.WeightValue,
            product.PurityFactor);

        product.AutoPrice = autoPrice;
        var sourcePrice = product.PricingMode == ProductPricingMode.Manual ? product.FixedPrice : product.AutoPrice;
        product.SellPrice = ProductPricingCalculator.ApplyOffer(sourcePrice, product.OfferType, product.OfferPercent, product.OfferNewPrice);
    }

    private int? ResolveSellerScope()
    {
        if (currentUser.IsInRole(SystemRoles.Admin))
        {
            return null;
        }

        return CurrentSellerId;
    }

    private bool IsSellerOrAdmin()
        => currentUser.IsInRole(SystemRoles.Admin) || currentUser.IsInRole(SystemRoles.Seller);

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

    private int ResolveSellerId(int? requestedSellerId, int fallbackSellerId = 0)
    {
        if (currentUser.IsInRole(SystemRoles.Admin))
        {
            var resolved = requestedSellerId ?? fallbackSellerId;
            if (resolved <= 0) throw new InvalidOperationException("SellerId is required for admin operations.");
            return resolved;
        }

        if (CurrentSellerId.HasValue && CurrentSellerId.Value > 0)
            return CurrentSellerId.Value;

        throw new UnauthorizedAccessException("Seller scope is required.");
    }

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
