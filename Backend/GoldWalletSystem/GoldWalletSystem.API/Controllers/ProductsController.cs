using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/products")]
public class ProductsController(IProductService productService) : ControllerBase
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
}
