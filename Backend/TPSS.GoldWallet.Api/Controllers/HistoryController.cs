using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.History.Queries.GetHistory;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Authorize(Policy = PermissionNames.HistoryRead)]
[Route("api/customers/{customerId:guid}/history")]
public sealed class HistoryController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<HistoryItemDto>>> Get([FromRoute] Guid customerId, CancellationToken cancellationToken)
        => Ok(await mediator.Send(new GetHistoryQuery(customerId), cancellationToken));
}
