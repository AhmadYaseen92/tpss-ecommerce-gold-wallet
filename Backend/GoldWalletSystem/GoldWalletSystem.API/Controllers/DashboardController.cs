using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Dashboard;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/dashboard")]
public class DashboardController(IDashboardService dashboardService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> Get(int userId, CancellationToken cancellationToken = default)
    {
        EnsureAccess(userId);
        var data = await dashboardService.GetByUserIdAsync(userId, cancellationToken);
        return Ok(ApiResponse<DashboardDto>.Ok(data));
    }

    private void EnsureAccess(int userId)
    {
        var sub = User.FindFirstValue("sub");
        if (!User.IsInRole("Admin") && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
