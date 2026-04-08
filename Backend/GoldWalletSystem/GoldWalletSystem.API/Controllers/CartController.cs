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
    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        EnsureAccess(request.UserId);
        var data = await cartService.GetCartByUserIdAsync(request.UserId, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data));
    }

    [HttpPost("items")]
    public async Task<IActionResult> AddItem([FromBody] AddCartItemByUserRequestDto request, CancellationToken cancellationToken = default)
    {
        EnsureAccess(request.UserId);
        var data = await cartService.AddItemAsync(request.UserId, request.ProductId, request.Quantity, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data, "Item added"));
    }

    private void EnsureAccess(int userId)
    {
        var isAdmin = User.IsInRole("Admin");
        var sub = User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!isAdmin && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
