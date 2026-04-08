using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/notifications")]
public class NotificationsController(INotificationService notificationService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("search")]
    public async Task<IActionResult> Search([FromBody] UserPagedRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await notificationService.GetByUserIdAsync(request.UserId, request.PageNumber, request.PageSize, cancellationToken);
        return Ok(ApiResponse<PagedResult<NotificationDto>>.Ok(data));
    }

    [HttpPut("read")]
    public async Task<IActionResult> MarkAsRead([FromBody] MarkNotificationReadRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        await notificationService.MarkAsReadAsync(request.UserId, request.NotificationId, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { request.NotificationId }, "Notification marked as read"));
    }
}
