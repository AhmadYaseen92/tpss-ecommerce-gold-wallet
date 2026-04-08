using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/transaction-history")]
public class TransactionHistoryController(ITransactionHistoryService transactionHistoryService) : ControllerBase
{
    [HttpGet("{userId:int}")]
    public async Task<IActionResult> GetByUserId(int userId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
    {
        var data = await transactionHistoryService.GetByUserIdAsync(userId, pageNumber, pageSize, cancellationToken);
        return Ok(data);
    }
}
