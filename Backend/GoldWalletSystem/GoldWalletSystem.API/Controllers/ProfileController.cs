using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public class ProfileController(IProfileService profileService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> Get(int userId, CancellationToken cancellationToken = default)
    {
        EnsureAccess(userId);
        var data = await profileService.GetByUserIdAsync(userId, cancellationToken);
        if (data is null)
            return NotFound(ApiResponse<ProfileDto>.Fail("Profile not found", StatusCodes.Status404NotFound));

        return Ok(ApiResponse<ProfileDto>.Ok(data));
    }

    private void EnsureAccess(int userId)
    {
        var sub = User.FindFirstValue("sub");
        if (!User.IsInRole("Admin") && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
