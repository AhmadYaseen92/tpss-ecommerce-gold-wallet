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
public class SellerController(ISellerWorkspaceService sellerWorkspaceService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpGet("workspace")]
    public async Task<IActionResult> GetWorkspace(CancellationToken cancellationToken = default)
    {
        var sellerId = CurrentSellerId;
        if (!sellerId.HasValue || sellerId.Value <= 0)
            return InvalidSellerScopeResponse();

        var data = await sellerWorkspaceService.BuildAsync(sellerId.Value, cancellationToken);
        return Ok(ApiResponse<SellerWorkspaceDto>.Ok(data));
    }
}
