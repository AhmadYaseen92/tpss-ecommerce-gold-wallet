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
    public async Task<IActionResult> SearchLegacy([FromBody] UserPagedRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await notificationService.GetByUserIdAsync(request.UserId, request.PageNumber, request.PageSize, cancellationToken);
        return Ok(ApiResponse<PagedResult<NotificationDto>>.Ok(data));
    }

    [HttpPost("my/search")]
    public async Task<IActionResult> Search([FromBody] PagedRequestDto request, CancellationToken cancellationToken = default)
    {
        if (currentUser.UserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));
        var data = await notificationService.GetByUserIdAsync(currentUser.UserId.Value, request.PageNumber, request.PageSize, cancellationToken);
        return Ok(ApiResponse<PagedResult<NotificationDto>>.Ok(data));
    }

    [HttpGet("my/unread-count")]
    public async Task<IActionResult> GetUnreadCount(CancellationToken cancellationToken = default)
    {
        if (currentUser.UserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));
        var unreadCount = await notificationService.GetUnreadCountAsync(currentUser.UserId.Value, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { unreadCount }));
    }

    [HttpPut("my/read")]
    public async Task<IActionResult> MarkAsRead([FromBody] MarkNotificationReadRequestDto request, CancellationToken cancellationToken = default)
    {
        if (currentUser.UserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));
        await notificationService.MarkAsReadAsync(currentUser.UserId.Value, request.NotificationId, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { request.NotificationId }, "Notification marked as read"));
    }

    [HttpPut("my/read-all")]
    public async Task<IActionResult> MarkAllAsRead(CancellationToken cancellationToken = default)
    {
        if (currentUser.UserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));
        await notificationService.MarkAllAsReadAsync(currentUser.UserId.Value, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { }, "All notifications marked as read"));
    }

    [HttpPost("my/push-tokens/register")]
    public async Task<IActionResult> RegisterPushToken([FromBody] RegisterPushTokenRequestDto request, CancellationToken cancellationToken = default)
    {
        if (currentUser.UserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));
        await notificationService.RegisterPushTokenAsync(currentUser.UserId.Value, request, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { }, "Push token registered"));
    }

    [HttpPost("my/push-tokens/unregister")]
    public async Task<IActionResult> UnregisterPushToken([FromBody] UnregisterPushTokenRequestDto request, CancellationToken cancellationToken = default)
    {
        if (currentUser.UserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));
        await notificationService.UnregisterPushTokenAsync(currentUser.UserId.Value, request, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { }, "Push token unregistered"));
    }
}
