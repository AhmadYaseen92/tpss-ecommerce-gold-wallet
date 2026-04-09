using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Api.Contracts.Kyc;
using TPSS.GoldWallet.Application.Features.Kyc.Commands.SubmitKyc;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Authorize(Policy = PermissionNames.KycSubmit)]
[Route("api/customers/{customerId:guid}/kyc")]
public sealed class KycController(IMediator mediator) : ControllerBase
{
    [HttpPost("submit")]
    public async Task<ActionResult<Guid>> Submit([FromRoute] Guid customerId, [FromBody] SubmitKycRequest request, CancellationToken cancellationToken)
    {
        var id = await mediator.Send(new SubmitKycCommand(customerId, request.DocumentType, request.DocumentNumber, request.Provider), cancellationToken);
        return Ok(id);
    }
}
