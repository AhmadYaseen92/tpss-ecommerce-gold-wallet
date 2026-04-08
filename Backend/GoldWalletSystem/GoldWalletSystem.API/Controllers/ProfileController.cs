using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public class ProfileController(IProfileService profileService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var data = await profileService.GetByUserIdAsync(request.UserId, cancellationToken);
        if (data is null)
            return NotFound(ApiResponse<ProfileDto>.Fail("Profile not found", StatusCodes.Status404NotFound));

        return Ok(ApiResponse<ProfileDto>.Ok(data));
    }
}
