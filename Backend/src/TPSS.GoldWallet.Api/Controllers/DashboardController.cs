using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.Dashboard.Queries.GetDashboard;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Authorize(Policy = PermissionNames.DashboardRead)]
[Route("api/customers/{customerId:guid}/dashboard")]
public sealed class DashboardController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<DashboardDto>> Get([FromRoute] Guid customerId, CancellationToken cancellationToken)
        => Ok(await mediator.Send(new GetDashboardQuery(customerId), cancellationToken));
}
