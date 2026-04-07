using MediatR;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.Carts.Commands.AddCartItem;
using TPSS.GoldWallet.Application.Features.Carts.Queries.GetCart;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Route("api/customers/{customerId:guid}/cart")]
public sealed class CartsController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(CartDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<CartDto>> GetCart([FromRoute] Guid customerId, CancellationToken cancellationToken)
    {
        var cart = await mediator.Send(new GetCartQuery(customerId), cancellationToken);
        return Ok(cart);
    }

    [HttpPost("items")]
    [ProducesResponseType(typeof(CartDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<CartDto>> AddItem(
        [FromRoute] Guid customerId,
        [FromBody] AddCartItemRequest request,
        CancellationToken cancellationToken)
    {
        var cart = await mediator.Send(new AddCartItemCommand(customerId, request.ProductId, request.Quantity), cancellationToken);
        return Ok(cart);
    }

    public sealed record AddCartItemRequest(Guid ProductId, int Quantity);
}
