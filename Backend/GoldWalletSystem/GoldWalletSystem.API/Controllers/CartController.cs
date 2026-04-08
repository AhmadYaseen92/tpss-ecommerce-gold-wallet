using GoldWalletSystem.Application.DTOs.Cart;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/cart")]
public class CartController(ICartService cartService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> Get(int userId, CancellationToken cancellationToken = default)
    {
        EnsureAccess(userId);
        var data = await cartService.GetCartByUserIdAsync(userId, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data));
    }

    [HttpPost("{userId:int}/items")]
    public async Task<IActionResult> AddItem(int userId, [FromBody] AddCartItemRequestDto request, CancellationToken cancellationToken = default)
    {
        EnsureAccess(userId);
        var data = await cartService.AddItemAsync(userId, request.ProductId, request.Quantity, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data, "Item added"));
    }

    private void EnsureAccess(int userId)
    {
        var isAdmin = User.IsInRole("Admin");
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue(ClaimTypes.Name) ?? User.FindFirstValue(ClaimTypes.Sid) ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        var sub = User.FindFirstValue("sub") ?? userIdClaim;
        if (!isAdmin && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
