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
        => await GetByUser(new UserRequestDto { UserId = userId }, cancellationToken);

    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        EnsureAccess(request.UserId);
        var data = await cartService.GetCartByUserIdAsync(request.UserId, cancellationToken);
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
        var sub = User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!isAdmin && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
