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
        var effectiveRequest = BuildScopedFilter(request.UserId, request.PageNumber, request.PageSize);
        if (!HasUserAccess(effectiveRequest.UserId)) return ForbidApiResponse();
        var data = NormalizeImageUrls(await transactionHistoryService.FilterAsync(effectiveRequest, cancellationToken));
        return Ok(ApiResponse<PagedResult<TransactionHistoryDto>>.Ok(data));
    }

    [HttpPost("filter")]
    public async Task<IActionResult> Filter([FromBody] TransactionHistoryFilterRequestDto request, CancellationToken cancellationToken = default)
    {
        var effectiveRequest = BuildScopedFilter(request.UserId, request.PageNumber, request.PageSize, request.TransactionType, request.Status, request.Category, request.DateFromUtc, request.DateToUtc);
        if (!HasUserAccess(effectiveRequest.UserId)) return ForbidApiResponse();
        var data = NormalizeImageUrls(await transactionHistoryService.FilterAsync(effectiveRequest, cancellationToken));
        return Ok(ApiResponse<PagedResult<TransactionHistoryDto>>.Ok(data));
    }

    [HttpPost("export-csv")]
    public async Task<IActionResult> ExportCsv([FromBody] TransactionHistoryFilterRequestDto request, CancellationToken cancellationToken = default)
    {
        var exportRequest = BuildScopedFilter(request.UserId, 1, 5000, request.TransactionType, request.Status, request.Category, request.DateFromUtc, request.DateToUtc);
        if (!HasUserAccess(exportRequest.UserId)) return ForbidApiResponse();

        var data = await transactionHistoryService.FilterAsync(exportRequest, cancellationToken);

        var csv = new StringBuilder();
        csv.AppendLine("Id,UserId,InvestorName,SellerId,TransactionType,Status,ProductName,Category,Quantity,UnitPrice,Weight,Unit,Purity,Amount,Currency,Notes,CreatedAtUtc");
        foreach (var item in data.Items)
        {
            csv.AppendLine($"{item.Id},{item.UserId},\"{item.InvestorName}\",{item.SellerId},\"{item.TransactionType}\",\"{item.Status}\",\"{item.Category}\",{item.Quantity},{item.UnitPrice},{item.Weight},\"{item.Unit}\",{item.Purity},{item.Amount},\"{item.Currency}\",\"{item.Notes}\",{item.CreatedAtUtc:O}");
        }

        var bytes = Encoding.UTF8.GetBytes(csv.ToString());
        return File(bytes, "text/csv", $"transactions_{request.UserId}_{DateTime.UtcNow:yyyyMMddHHmmss}.csv");
    }

    private TransactionHistoryFilterRequestDto BuildScopedFilter(
        int requestedUserId,
        int pageNumber,
        int pageSize,
        string? transactionType = null,
        string? status = null,
        string? category = null,
        DateTime? dateFromUtc = null,
        DateTime? dateToUtc = null)
    {
        var effectiveUserId = currentUser.IsInRole("Admin") ? requestedUserId : currentUser.UserId ?? requestedUserId;
        var effectiveSellerId = currentUser.IsInRole("Admin") ? null : currentUser.SellerId;

        return new TransactionHistoryFilterRequestDto
        {
            UserId = effectiveUserId,
            SellerId = effectiveSellerId,
            PageNumber = pageNumber,
            PageSize = pageSize,
            TransactionType = transactionType,
            Status = status,
            Category = category,
            DateFromUtc = dateFromUtc,
            DateToUtc = dateToUtc
        };
    }

    private PagedResult<TransactionHistoryDto> NormalizeImageUrls(PagedResult<TransactionHistoryDto> source)
    {
        var mapped = source.Items
            .Select(item => item with
            {
                ProductImageUrl = ToAbsoluteAssetUrl(item.ProductImageUrl)
            })
            .ToList();

        return new PagedResult<TransactionHistoryDto>(
            mapped,
            source.TotalCount,
            source.PageNumber,
            source.PageSize);
    }

    private string ToAbsoluteAssetUrl(string? imageUrl)
    {
        if (string.IsNullOrWhiteSpace(imageUrl)) return string.Empty;
        if (Uri.TryCreate(imageUrl, UriKind.Absolute, out _)) return imageUrl;

        var request = HttpContext.Request;
        var normalized = imageUrl.StartsWith('/') ? imageUrl : $"/{imageUrl}";
        return $"{request.Scheme}://{request.Host}{normalized}";
    }
}
