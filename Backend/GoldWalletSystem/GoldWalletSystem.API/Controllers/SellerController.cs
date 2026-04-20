using GoldWalletSystem.Application.DTOs.Admin;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize(Roles = SystemRoles.Seller)]
[Route("api/seller")]
public class SellerController(ISellerWorkspaceService sellerWorkspaceService) : ControllerBase
{
    [HttpGet("workspace")]
    public async Task<IActionResult> GetWorkspace(CancellationToken cancellationToken = default)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        if (!int.TryParse(sellerIdClaim, out var sellerId) || sellerId <= 0)
            return BadRequest(ApiResponse<object>.Fail("Invalid seller scope", 400));

        var data = await sellerWorkspaceService.BuildAsync(sellerId, cancellationToken);
        return Ok(ApiResponse<SellerWorkspaceDto>.Ok(data));
    }
}
