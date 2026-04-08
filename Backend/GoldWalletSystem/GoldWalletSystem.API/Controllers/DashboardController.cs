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
    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        EnsureAccess(request.UserId);
        var data = await dashboardService.GetByUserIdAsync(request.UserId, cancellationToken);
        return Ok(ApiResponse<DashboardDto>.Ok(data));
    }

    private void EnsureAccess(int userId)
    {
        var sub = User.FindFirstValue("sub");
        if (!User.IsInRole("Admin") && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
