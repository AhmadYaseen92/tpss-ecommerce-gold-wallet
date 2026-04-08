using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/cart")]
public class CartController(ICartService cartService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> Get(int userId, CancellationToken cancellationToken = default)
    {
        var data = await cartService.GetCartByUserIdAsync(userId, cancellationToken);
        return Ok(data);
    }

    [HttpPost("{userId:int}/items")]
    public async Task<IActionResult> AddItem(int userId, [FromQuery] int productId, [FromQuery] int quantity, CancellationToken cancellationToken = default)
    {
        var data = await cartService.AddItemAsync(userId, productId, quantity, cancellationToken);
        return Ok(data);
    }
}
