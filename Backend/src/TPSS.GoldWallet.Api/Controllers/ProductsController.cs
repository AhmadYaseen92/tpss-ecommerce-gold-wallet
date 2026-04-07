using MediatR;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.Products.Queries.GetCatalog;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Route("api/products")]
public sealed class ProductsController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<ProductDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<ProductDto>>> Get(CancellationToken cancellationToken)
    {
        var products = await mediator.Send(new GetCatalogQuery(), cancellationToken);
        return Ok(products);
    }
}
