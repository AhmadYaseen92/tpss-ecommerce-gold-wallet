using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/dashboard")]
public class DashboardController(IDashboardService dashboardService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> Get(int userId, CancellationToken cancellationToken = default)
    {
        var data = await dashboardService.GetByUserIdAsync(userId, cancellationToken);
        return Ok(data);
    }
}
