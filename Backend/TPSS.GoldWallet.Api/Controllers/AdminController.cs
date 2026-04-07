using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.Admin.Queries.GetAuditLogs;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Authorize(Policy = PermissionNames.AuditRead)]
[Route("api/admin")]
public sealed class AdminController(IMediator mediator) : ControllerBase
{
    [HttpGet("logs")]
    public async Task<ActionResult<IReadOnlyList<AuditLogDto>>> GetLogs([FromQuery] int take = 100, CancellationToken cancellationToken = default)
        => Ok(await mediator.Send(new GetAuditLogsQuery(take), cancellationToken));
}
