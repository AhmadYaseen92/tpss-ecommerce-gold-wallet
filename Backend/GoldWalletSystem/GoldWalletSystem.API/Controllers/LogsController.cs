using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/logs")]
public class LogsController(IAuditLogService auditLogService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
    {
        var data = await auditLogService.GetLogsAsync(pageNumber, pageSize, cancellationToken);
        return Ok(data);
    }
}
