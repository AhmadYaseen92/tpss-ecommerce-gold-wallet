using GoldWalletSystem.Application.DTOs.Cart;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/cart")]
public class CartController(ICartService cartService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await cartService.GetCartByUserIdAsync(request.UserId, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data));
    }

    [HttpPost("items")]
    public async Task<IActionResult> AddItem([FromBody] AddCartItemByUserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await cartService.AddItemAsync(request.UserId, request.ProductId, request.Quantity, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data, "Item added"));
    }

    [HttpPut("items")]
    public async Task<IActionResult> UpdateItem([FromBody] UpdateCartItemByUserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await cartService.UpdateItemQuantityAsync(request.UserId, request.ProductId, request.Quantity, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data, "Item quantity updated"));
    }

    [HttpDelete("items/{userId:int}/{productId:int}")]
    public async Task<IActionResult> RemoveItem(int userId, int productId, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(userId)) return ForbidApiResponse();
        var data = await cartService.RemoveItemAsync(userId, productId, cancellationToken);
        return Ok(ApiResponse<CartDto>.Ok(data, "Item removed"));
    }
}
