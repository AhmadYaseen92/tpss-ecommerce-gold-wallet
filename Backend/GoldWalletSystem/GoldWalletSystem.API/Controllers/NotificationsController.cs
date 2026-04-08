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
    [HttpPost("search")]
    public async Task<IActionResult> Search([FromBody] UserPagedRequestDto request, CancellationToken cancellationToken = default)
    {
        EnsureAccess(request.UserId);
        var data = await notificationService.GetByUserIdAsync(request.UserId, request.PageNumber, request.PageSize, cancellationToken);
        return Ok(ApiResponse<PagedResult<NotificationDto>>.Ok(data));
    }

    [HttpPut("read")]
    public async Task<IActionResult> MarkAsRead([FromBody] MarkNotificationReadRequestDto request, CancellationToken cancellationToken = default)
    {
        EnsureAccess(request.UserId);
        await notificationService.MarkAsReadAsync(request.UserId, request.NotificationId, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { request.NotificationId }, "Notification marked as read"));
    }

    private void EnsureAccess(int userId)
    {
        var sub = User.FindFirstValue("sub");
        if (!User.IsInRole("Admin") && sub != userId.ToString())
            throw new UnauthorizedAccessException("You are not allowed to access this resource.");
    }
}
