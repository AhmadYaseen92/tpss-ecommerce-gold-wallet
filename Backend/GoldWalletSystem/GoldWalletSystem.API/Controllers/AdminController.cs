using GoldWalletSystem.Application.DTOs.Admin;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize(Roles = SystemRoles.Admin)]
[Route("api/admin")]
public class AdminController(IAdminWorkspaceService adminWorkspaceService) : ControllerBase
{
    [HttpGet("workspace")]
    public async Task<IActionResult> GetWorkspace(CancellationToken cancellationToken = default)
    {
        var data = await adminWorkspaceService.BuildAsync(cancellationToken);
        return Ok(ApiResponse<AdminWorkspaceDto>.Ok(data));
    }
}
