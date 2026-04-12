using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Products;

public sealed class ProductSearchRequestDto : PagedRequestDto
{
    public ProductCategory? Category { get; set; }
}
