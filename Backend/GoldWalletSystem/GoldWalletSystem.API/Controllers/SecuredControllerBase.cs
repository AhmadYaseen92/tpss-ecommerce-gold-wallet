using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

public abstract class SecuredControllerBase(ICurrentUserService currentUser) : ControllerBase
{
    protected bool HasUserAccess(int requestedUserId)
        => currentUser.IsInRole(SystemRoles.Admin) || currentUser.UserId == requestedUserId;

    protected IActionResult ForbidApiResponse()
        => StatusCode(StatusCodes.Status403Forbidden, GoldWalletSystem.Application.DTOs.Common.ApiResponse<object>.Fail("Forbidden", StatusCodes.Status403Forbidden));

    protected int? CurrentUserId => currentUser.UserId;
    protected int? CurrentSellerId => currentUser.SellerId;

    protected IActionResult InvalidSellerScopeResponse()
        => BadRequest(GoldWalletSystem.Application.DTOs.Common.ApiResponse<object>.Fail("Invalid seller scope", StatusCodes.Status400BadRequest));
}
