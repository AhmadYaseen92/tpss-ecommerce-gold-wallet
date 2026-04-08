using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/notifications")]
public class NotificationsController(INotificationService notificationService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> GetByUserId(int userId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
    {
        var data = await notificationService.GetByUserIdAsync(userId, pageNumber, pageSize, cancellationToken);
        return Ok(data);
    }

    [HttpPut("{userId:int}/{notificationId:int}/read")]
    public async Task<IActionResult> MarkAsRead(int userId, int notificationId, CancellationToken cancellationToken = default)
    {
        await notificationService.MarkAsReadAsync(userId, notificationId, cancellationToken);
        return NoContent();
    }
}
