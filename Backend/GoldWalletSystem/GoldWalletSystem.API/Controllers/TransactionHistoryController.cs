using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Transactions;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text;

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

    [HttpPost("filter")]
    public async Task<IActionResult> Filter([FromBody] TransactionHistoryFilterRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await transactionHistoryService.FilterAsync(request, cancellationToken);
        return Ok(ApiResponse<PagedResult<TransactionHistoryDto>>.Ok(data));
    }

    [HttpPost("export-csv")]
    public async Task<IActionResult> ExportCsv([FromBody] TransactionHistoryFilterRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var exportRequest = new TransactionHistoryFilterRequestDto
        {
            UserId = request.UserId,
            PageNumber = 1,
            PageSize = 5000,
            TransactionType = request.TransactionType,
            DateFromUtc = request.DateFromUtc,
            DateToUtc = request.DateToUtc,
        };

        var data = await transactionHistoryService.FilterAsync(exportRequest, cancellationToken);

        var csv = new StringBuilder();
        csv.AppendLine("Id,UserId,TransactionType,Amount,Currency,Reference,CreatedAtUtc");
        foreach (var item in data.Items)
        {
            csv.AppendLine($"{item.Id},{item.UserId},\"{item.TransactionType}\",{item.Amount},{item.Currency},\"{item.Reference}\",{item.CreatedAtUtc:O}");
        }

        var bytes = Encoding.UTF8.GetBytes(csv.ToString());
        return File(bytes, "text/csv", $"transactions_{request.UserId}_{DateTime.UtcNow:yyyyMMddHHmmss}.csv");
    }
}
