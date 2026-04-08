using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/notifications")]
public class NotificationsController(INotificationService notificationService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> GetByUserId(int userId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
    {
        EnsureAccess(userId);
        var data = await notificationService.GetByUserIdAsync(userId, pageNumber, pageSize, cancellationToken);
        return Ok(ApiResponse<PagedResult<NotificationDto>>.Ok(data));
    }

    [HttpPut("{userId:int}/{notificationId:int}/read")]
    public async Task<IActionResult> MarkAsRead(int userId, int notificationId, CancellationToken cancellationToken = default)
    {
        EnsureAccess(userId);
        await notificationService.MarkAsReadAsync(userId, notificationId, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { NotificationId = notificationId }, "Notification marked as read"));
    }

    private void EnsureAccess(int userId)
    {
        var sub = User.FindFirstValue("sub");
        if (!User.IsInRole("Admin") && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
