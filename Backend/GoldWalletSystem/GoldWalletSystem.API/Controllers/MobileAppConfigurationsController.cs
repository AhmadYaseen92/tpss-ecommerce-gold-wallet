using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Configuration;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/mobile-app-configurations")]
public class MobileAppConfigurationsController(IMobileAppConfigurationService service) : ControllerBase
{
    [HttpPost("list")]
    public async Task<IActionResult> List(CancellationToken cancellationToken = default)
    {
        var data = await service.GetAllAsync(cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<MobileAppConfigurationDto>>.Ok(data));
    }

    [HttpPost("upsert")]
    [Authorize(Roles = SystemRoles.Admin)]
    public async Task<IActionResult> Upsert([FromBody] UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await service.UpsertAsync(request, cancellationToken);
        return Ok(ApiResponse<MobileAppConfigurationDto>.Ok(data));
    }
}
