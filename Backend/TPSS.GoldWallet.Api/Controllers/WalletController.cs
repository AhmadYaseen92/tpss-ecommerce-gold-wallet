using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Api.Contracts.Wallets;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.Wallets.Commands.RecordTransaction;
using TPSS.GoldWallet.Application.Features.Wallets.Queries.GetWallet;
using TPSS.GoldWallet.Application.Security;
using TPSS.GoldWallet.Domain.Enums;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Route("api/customers/{customerId:guid}/wallet")]
public sealed class WalletController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    [Authorize(Policy = PermissionNames.WalletRead)]
    public async Task<ActionResult<WalletDto>> Get([FromRoute] Guid customerId, CancellationToken cancellationToken)
        => Ok(await mediator.Send(new GetWalletQuery(customerId), cancellationToken));

    [HttpPost("transactions")]
    [Authorize(Policy = PermissionNames.WalletWrite)]
    public async Task<ActionResult<WalletDto>> Record(
        [FromRoute] Guid customerId,
        [FromBody] RecordWalletTransactionRequest request,
        CancellationToken cancellationToken)
    {
        var command = new RecordTransactionCommand(customerId, request.Amount, Enum.Parse<WalletTransactionType>(request.Type, true), request.Reference);
        return Ok(await mediator.Send(command, cancellationToken));
    }
}
