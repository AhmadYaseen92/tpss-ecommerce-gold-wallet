using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.Profile.Queries.GetMyProfile;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Authorize(Policy = PermissionNames.ProfileRead)]
[Route("api/customers/{customerId:guid}/profile")]
public sealed class ProfileController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ProfileDto>> Get([FromRoute] Guid customerId, CancellationToken cancellationToken)
        => Ok(await mediator.Send(new GetMyProfileQuery(customerId), cancellationToken));
}
