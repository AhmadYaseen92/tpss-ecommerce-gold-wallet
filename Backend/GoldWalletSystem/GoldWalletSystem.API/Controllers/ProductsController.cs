using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Domain.Constants;
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
public class ProductsController(IProductService productService, AppDbContext dbContext, IWebHostEnvironment environment) : ControllerBase
{
    [HttpPost("search")]
    public async Task<IActionResult> Search([FromBody] ProductSearchRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await productService.GetProductsAsync(request.PageNumber, request.PageSize, request.Category, cancellationToken);
        var normalizedItems = data.Items
            .Select(product => product with { ImageUrl = ToAbsoluteAssetUrl(product.ImageUrl) })
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
                ImageUrl = ToAbsoluteAssetUrl(x.ImageUrl),
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
                ManualSellPrice = x.ManualSellPrice,
                DeliveryFee = x.DeliveryFee,
                StorageFee = x.StorageFee,
                ServiceCharge = x.ServiceCharge,
                OfferPercent = x.OfferPercent,
                OfferNewPrice = x.OfferNewPrice,
                OfferType = x.OfferType,
                IsHasOffer = x.IsHasOffer,
                Price = x.Price,
                AvailableStock = x.AvailableStock,
                IsActive = x.IsActive,
                SellerId = x.SellerId
            })
            .ToListAsync(cancellationToken);

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
            ImageUrl = ToAbsoluteAssetUrl(x.ImageUrl),
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
            ManualSellPrice = x.ManualSellPrice,
            DeliveryFee = x.DeliveryFee,
            StorageFee = x.StorageFee,
            ServiceCharge = x.ServiceCharge,
            OfferPercent = x.OfferPercent,
            OfferNewPrice = x.OfferNewPrice,
            OfferType = x.OfferType,
            IsHasOffer = x.IsHasOffer,
            Price = x.Price,
            AvailableStock = x.AvailableStock,
            IsActive = x.IsActive,
            SellerId = x.SellerId
        }).FirstOrDefaultAsync(cancellationToken);

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
            Category = ToLegacyCategory(request.MaterialType),
            MaterialType = request.MaterialType,
            FormType = request.FormType,
            PricingMode = request.PricingMode,
            PurityKarat = request.PurityKarat,
            PurityFactor = request.PurityFactor,
            WeightValue = request.WeightValue,
            WeightUnit = ProductWeightUnit.Gram,
            BaseMarketPrice = await ResolveMarketPriceByMaterialAsync(request.MaterialType, sellerId, cancellationToken),
            ManualSellPrice = request.ManualSellPrice,
            DeliveryFee = request.DeliveryFee,
            StorageFee = request.StorageFee,
            ServiceCharge = request.ServiceCharge,
            OfferPercent = request.OfferPercent,
            OfferNewPrice = request.OfferNewPrice,
            OfferType = request.OfferType,
            IsHasOffer = request.OfferType != ProductOfferType.None,
            Price = await ResolveFinalPriceAsync(request, sellerId, cancellationToken),
            AvailableStock = request.AvailableStock,
            IsActive = request.IsActive,
            SellerId = sellerId
        };

        dbContext.Products.Add(product);
        await dbContext.SaveChangesAsync(cancellationToken);

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
        product.Category = ToLegacyCategory(request.MaterialType);
        product.MaterialType = request.MaterialType;
        product.FormType = request.FormType;
        product.PricingMode = request.PricingMode;
        product.PurityKarat = request.PurityKarat;
        product.PurityFactor = request.PurityFactor;
        product.WeightValue = request.WeightValue;
        product.WeightUnit = ProductWeightUnit.Gram;
        product.BaseMarketPrice = await ResolveMarketPriceByMaterialAsync(request.MaterialType, nextSellerId, cancellationToken);
        product.ManualSellPrice = request.ManualSellPrice;
        product.DeliveryFee = request.DeliveryFee;
        product.StorageFee = request.StorageFee;
        product.ServiceCharge = request.ServiceCharge;
        product.OfferPercent = request.OfferPercent;
        product.OfferNewPrice = request.OfferNewPrice;
        product.OfferType = request.OfferType;
        product.IsHasOffer = request.OfferType != ProductOfferType.None;
        product.Price = await ResolveFinalPriceAsync(request, nextSellerId, cancellationToken);
        product.AvailableStock = request.AvailableStock;
        product.IsActive = request.IsActive;
        product.SellerId = nextSellerId;

        await dbContext.SaveChangesAsync(cancellationToken);
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
        var sellPrice = request.PricingMode == ProductPricingMode.Manual
            ? request.ManualSellPrice
            : ProductPricingCalculator.CalculateAutoPrice(
                request.MaterialType,
                marketPrice,
                request.WeightValue,
                request.PurityFactor,
                request.DeliveryFee,
                request.StorageFee,
                request.ServiceCharge);

        return ProductPricingCalculator.ApplyOffer(sellPrice, request.OfferType, request.OfferPercent, request.OfferNewPrice);
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
                product.PurityFactor,
                product.DeliveryFee,
                product.StorageFee,
                product.ServiceCharge);

            product.BaseMarketPrice = marketPrice;
            product.Price = ProductPricingCalculator.ApplyOffer(autoPrice, product.OfferType, product.OfferPercent, product.OfferNewPrice);
            product.UpdatedAtUtc = DateTime.UtcNow;
        }

        if (products.Count > 0)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }

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
            return existingImageUrl ?? string.Empty;
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

        return $"/images/products/{fileName}";
    }

    private string ToAbsoluteAssetUrl(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return path;
        }

        if (Uri.TryCreate(path, UriKind.Absolute, out _))
        {
            return path;
        }

        var normalizedPath = path.StartsWith('/') ? path : $"/{path}";
        return $"{Request.Scheme}://{Request.Host}{normalizedPath}";
    }

    public sealed record EnumItemDto(int Value, string Name);

    public sealed class ProductManagementDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Sku { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
        public ProductCategory Category { get; set; }
        public ProductMaterialType MaterialType { get; set; }
        public ProductFormType FormType { get; set; }
        public string DisplayCategoryLabel { get; set; } = string.Empty;
        public ProductPricingMode PricingMode { get; set; }
        public ProductPurityKarat PurityKarat { get; set; }
        public decimal PurityFactor { get; set; }
        public decimal WeightValue { get; set; }
        public ProductWeightUnit WeightUnit { get; set; }
        public decimal BaseMarketPrice { get; set; }
        public decimal ManualSellPrice { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal StorageFee { get; set; }
        public decimal ServiceCharge { get; set; }
        public decimal OfferPercent { get; set; }
        public decimal OfferNewPrice { get; set; }
        public ProductOfferType OfferType { get; set; }
        public decimal Price { get; set; }
        public int AvailableStock { get; set; }
        public bool IsActive { get; set; }
        public int SellerId { get; set; }
    }


    public sealed class MarketPriceConfigDto
    {
        public decimal GoldPerOunce { get; set; }
        public decimal SilverPerOunce { get; set; }
        public decimal DiamondPerCarat { get; set; }
    }

    public sealed class ProductUpsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Sku { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public IFormFile? Image { get; set; }
        public string? ExistingImageUrl { get; set; }
        public ProductMaterialType MaterialType { get; set; } = ProductMaterialType.Gold;
        public ProductFormType FormType { get; set; } = ProductFormType.Jewelry;
        public ProductPricingMode PricingMode { get; set; } = ProductPricingMode.Auto;
        public ProductPurityKarat PurityKarat { get; set; } = ProductPurityKarat.None;
        public decimal PurityFactor { get; set; }
        public decimal WeightValue { get; set; }
        public ProductWeightUnit WeightUnit { get; set; } = ProductWeightUnit.Gram;
        public decimal ManualSellPrice { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal StorageFee { get; set; }
        public decimal ServiceCharge { get; set; }
        public decimal OfferPercent { get; set; }
        public decimal OfferNewPrice { get; set; }
        public ProductOfferType OfferType { get; set; } = ProductOfferType.None;
        public int AvailableStock { get; set; }
        public bool IsActive { get; set; } = true;
        public int? SellerId { get; set; }
    }
}
