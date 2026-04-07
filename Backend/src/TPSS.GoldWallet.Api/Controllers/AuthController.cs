using MediatR;
using Microsoft.AspNetCore.Mvc;
using TPSS.GoldWallet.Api.Contracts.Auth;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Features.Auth.Commands.Login;

namespace TPSS.GoldWallet.Api.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController(IMediator mediator) : ControllerBase
{
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthTokenDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AuthTokenDto>> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        var token = await mediator.Send(new LoginCommand(request.Email, request.Password), cancellationToken);
        return Ok(token);
    }
}
