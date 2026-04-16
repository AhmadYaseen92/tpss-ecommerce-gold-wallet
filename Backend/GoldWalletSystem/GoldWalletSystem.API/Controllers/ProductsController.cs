using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/products")]
public class ProductsController(IProductService productService, AppDbContext dbContext, IWebHostEnvironment environment) : ControllerBase
{
    private const string MarketPriceGoldKey = "market.price.gold";
    private const string MarketPriceSilverKey = "market.price.silver";
    private const string MarketPriceDiamondKey = "market.price.diamond";

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
            .OrderByDescending(x => x.CreatedAtUtc)
            .ThenByDescending(x => x.Id)
            .Select(x => new ProductManagementDto
            {
                Id = x.Id,
                Name = x.Name,
                Sku = x.Sku,
                Description = x.Description,
                ImageUrl = ToAbsoluteAssetUrl(x.ImageUrl),
                Category = x.Category,
                PricingMaterialType = x.PricingMaterialType,
                PricingMode = x.PricingMode,
                WeightValue = x.WeightValue,
                WeightUnit = x.WeightUnit,
                PurityKarat = x.PurityKarat,
                MarketUnitPrice = x.MarketUnitPrice,
                DeliveryFee = x.DeliveryFee,
                StorageFee = x.StorageFee,
                ServiceCharge = x.ServiceCharge,
                FinalSellPrice = x.FinalSellPrice,
                Price = x.Price,
                AvailableStock = x.AvailableStock,
                IsActive = x.IsActive,
                SellerId = x.SellerId,
                CreatedAtUtc = x.CreatedAtUtc,
                UpdatedAtUtc = x.UpdatedAtUtc
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<ProductManagementDto>>.Ok(items));
    }

    [HttpGet("management/{id:int}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Products.AsNoTracking().Where(x => x.Id == id).Select(x => new ProductManagementDto
        {
            Id = x.Id,
            Name = x.Name,
            Sku = x.Sku,
            Description = x.Description,
            ImageUrl = ToAbsoluteAssetUrl(x.ImageUrl),
            Category = x.Category,
            PricingMaterialType = x.PricingMaterialType,
            PricingMode = x.PricingMode,
            WeightValue = x.WeightValue,
            WeightUnit = x.WeightUnit,
            PurityKarat = x.PurityKarat,
            MarketUnitPrice = x.MarketUnitPrice,
            DeliveryFee = x.DeliveryFee,
            StorageFee = x.StorageFee,
            ServiceCharge = x.ServiceCharge,
            FinalSellPrice = x.FinalSellPrice,
            Price = x.Price,
            AvailableStock = x.AvailableStock,
            IsActive = x.IsActive,
            SellerId = x.SellerId,
            CreatedAtUtc = x.CreatedAtUtc,
            UpdatedAtUtc = x.UpdatedAtUtc
        }).FirstOrDefaultAsync(cancellationToken);

        return item is null
            ? NotFound(ApiResponse<object>.Fail("Product not found", 404))
            : Ok(ApiResponse<ProductManagementDto>.Ok(item));
    }

    [HttpPost("management")]
    public async Task<IActionResult> Create([FromForm] ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
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
            Category = request.Category,
            PricingMaterialType = request.PricingMaterialType,
            PricingMode = request.PricingMode,
            WeightValue = request.WeightValue,
            WeightUnit = request.WeightUnit,
            PurityKarat = request.PurityKarat,
            MarketUnitPrice = request.MarketUnitPrice,
            DeliveryFee = request.DeliveryFee,
            StorageFee = request.StorageFee,
            ServiceCharge = request.ServiceCharge,
            AvailableStock = request.AvailableStock,
            IsActive = request.IsActive,
            SellerId = sellerId
        };
        await ApplyPricingAsync(product, request.Price, cancellationToken);

        dbContext.Products.Add(product);
        await dbContext.SaveChangesAsync(cancellationToken);

        return Ok(ApiResponse<string>.Ok("Created"));
    }

    [HttpPut("management/{id:int}")]
    public async Task<IActionResult> Update(int id, [FromForm] ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (product is null)
        {
            return NotFound(ApiResponse<object>.Fail("Product not found", 404));
        }

        if (!string.Equals(product.Sku, request.Sku, StringComparison.OrdinalIgnoreCase)
            && await dbContext.Products.AnyAsync(x => x.Sku == request.Sku && x.Id != id, cancellationToken))
        {
            return BadRequest(ApiResponse<object>.Fail("SKU already exists", 400));
        }

        product.Name = request.Name;
        product.Sku = request.Sku;
        product.Description = request.Description;
        product.ImageUrl = await SaveImageAsync(request.Image, request.ExistingImageUrl ?? product.ImageUrl, cancellationToken);
        product.Category = request.Category;
        product.PricingMaterialType = request.PricingMaterialType;
        product.PricingMode = request.PricingMode;
        product.WeightValue = request.WeightValue;
        product.WeightUnit = request.WeightUnit;
        product.PurityKarat = request.PurityKarat;
        product.MarketUnitPrice = request.MarketUnitPrice;
        product.DeliveryFee = request.DeliveryFee;
        product.StorageFee = request.StorageFee;
        product.ServiceCharge = request.ServiceCharge;
        product.AvailableStock = request.AvailableStock;
        product.IsActive = request.IsActive;
        product.SellerId = ResolveSellerId(request.SellerId, product.SellerId);
        product.UpdatedAtUtc = DateTime.UtcNow;
        await ApplyPricingAsync(product, request.Price, cancellationToken);

        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("Updated"));
    }

    [HttpDelete("management/{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (product is null)
        {
            return NotFound(ApiResponse<object>.Fail("Product not found", 404));
        }

        var relatedCartItems = await dbContext.CartItems.Where(x => x.ProductId == id).ToListAsync(cancellationToken);
        if (relatedCartItems.Count > 0)
        {
            dbContext.CartItems.RemoveRange(relatedCartItems);
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

    [HttpGet("pricing-material-types")]
    public IActionResult GetPricingMaterialTypes()
    {
        var data = Enum.GetValues<PricingMaterialType>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    [HttpGet("pricing-modes")]
    public IActionResult GetPricingModes()
    {
        var data = Enum.GetValues<ProductPricingMode>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList();
        return Ok(ApiResponse<List<EnumItemDto>>.Ok(data));
    }

    private int ResolveSellerId(int? requestedSellerId, int fallbackSellerId = 0)
    {
        var role = User.Claims.FirstOrDefault(c => c.Type == "role")?.Value ?? string.Empty;
        if (string.Equals(role, SystemRoles.Admin, StringComparison.OrdinalIgnoreCase))
        {
            return requestedSellerId ?? fallbackSellerId;
        }

        return int.TryParse(User.Claims.FirstOrDefault(c => c.Type == "seller_id")?.Value, out var sellerId)
            ? sellerId
            : fallbackSellerId;
    }

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
        public PricingMaterialType PricingMaterialType { get; set; }
        public ProductPricingMode PricingMode { get; set; }
        public decimal WeightValue { get; set; }
        public ProductWeightUnit WeightUnit { get; set; }
        public decimal? PurityKarat { get; set; }
        public decimal MarketUnitPrice { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal StorageFee { get; set; }
        public decimal ServiceCharge { get; set; }
        public decimal FinalSellPrice { get; set; }
        public decimal Price { get; set; }
        public int AvailableStock { get; set; }
        public bool IsActive { get; set; }
        public int SellerId { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime? UpdatedAtUtc { get; set; }
    }

    public sealed class ProductUpsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Sku { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public IFormFile? Image { get; set; }
        public string? ExistingImageUrl { get; set; }
        public ProductCategory Category { get; set; } = ProductCategory.Jewelry;
        public PricingMaterialType PricingMaterialType { get; set; } = PricingMaterialType.Gold;
        public ProductPricingMode PricingMode { get; set; } = ProductPricingMode.Auto;
        public decimal WeightValue { get; set; }
        public ProductWeightUnit WeightUnit { get; set; } = ProductWeightUnit.Gram;
        public decimal? PurityKarat { get; set; }
        public decimal MarketUnitPrice { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal StorageFee { get; set; }
        public decimal ServiceCharge { get; set; }
        public decimal Price { get; set; }
        public int AvailableStock { get; set; }
        public bool IsActive { get; set; } = true;
        public int? SellerId { get; set; }
    }

    private async Task ApplyPricingAsync(Product product, decimal manualPrice, CancellationToken cancellationToken)
    {
        if (product.PricingMode == ProductPricingMode.Manual)
        {
            product.Price = manualPrice;
            product.FinalSellPrice = manualPrice;
            return;
        }

        var marketUnitPrice = product.MarketUnitPrice > 0
            ? product.MarketUnitPrice
            : await GetMarketPriceForMaterialAsync(product.PricingMaterialType, cancellationToken);

        product.MarketUnitPrice = marketUnitPrice;
        var weightInGram = ConvertWeightToGram(product.WeightValue, product.WeightUnit);
        var purityFactor = GetPurityFactor(product.PricingMaterialType, product.PurityKarat);
        var baseAmount = marketUnitPrice * weightInGram * purityFactor;
        var feesTotal = product.DeliveryFee + product.StorageFee + product.ServiceCharge;
        var finalPrice = decimal.Round(baseAmount + feesTotal, 2, MidpointRounding.AwayFromZero);
        product.FinalSellPrice = finalPrice;
        product.Price = finalPrice;
    }

    private async Task<decimal> GetMarketPriceForMaterialAsync(PricingMaterialType materialType, CancellationToken cancellationToken)
    {
        var key = materialType switch
        {
            PricingMaterialType.Gold => MarketPriceGoldKey,
            PricingMaterialType.Silver => MarketPriceSilverKey,
            PricingMaterialType.Diamond => MarketPriceDiamondKey,
            _ => string.Empty
        };

        if (string.IsNullOrWhiteSpace(key))
        {
            return 0;
        }

        var value = await dbContext.MobileAppConfigurations
            .AsNoTracking()
            .Where(x => x.Key == key)
            .Select(x => x.Value)
            .FirstOrDefaultAsync(cancellationToken);

        return decimal.TryParse(value, out var parsed) ? parsed : 0;
    }

    private static decimal ConvertWeightToGram(decimal weightValue, ProductWeightUnit weightUnit)
    {
        return weightUnit switch
        {
            ProductWeightUnit.Kilogram => weightValue * 1000m,
            ProductWeightUnit.Ounce => weightValue * 31.1035m,
            _ => weightValue
        };
    }

    private static decimal GetPurityFactor(PricingMaterialType materialType, decimal? purityKarat)
    {
        if (materialType == PricingMaterialType.Diamond || !purityKarat.HasValue || purityKarat <= 0)
        {
            return 1m;
        }

        return decimal.Clamp(purityKarat.Value / 24m, 0m, 1.5m);
    }
}
