using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.AccountSummary.Queries.GetAccountSummary;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Authorize(Policy = PermissionNames.DashboardRead)]
[Route("api/customers/{customerId:guid}/account-summary")]
public sealed class AccountSummaryController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<AccountSummaryDto>> Get([FromRoute] Guid customerId, CancellationToken cancellationToken)
        => Ok(await mediator.Send(new GetAccountSummaryQuery(customerId), cancellationToken));
}
