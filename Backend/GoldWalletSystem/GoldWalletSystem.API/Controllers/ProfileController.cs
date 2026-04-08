using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/profile")]
public class ProfileController(IProfileService profileService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> Get(int userId, CancellationToken cancellationToken = default)
    {
        var data = await profileService.GetByUserIdAsync(userId, cancellationToken);
        return data is null ? NotFound() : Ok(data);
    }
}
