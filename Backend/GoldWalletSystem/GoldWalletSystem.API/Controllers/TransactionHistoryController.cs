using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Transactions;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/transaction-history")]
public class TransactionHistoryController(ITransactionHistoryService transactionHistoryService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("search")]
    public async Task<IActionResult> Search([FromBody] UserPagedRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await transactionHistoryService.GetByUserIdAsync(request.UserId, request.PageNumber, request.PageSize, cancellationToken);
        return Ok(ApiResponse<PagedResult<TransactionHistoryDto>>.Ok(data));
    }
}
