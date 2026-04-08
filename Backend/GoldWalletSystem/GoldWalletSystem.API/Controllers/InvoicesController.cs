using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Invoices;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/invoices")]
public class InvoicesController(IInvoiceService invoiceService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("search")]
    public async Task<IActionResult> Search([FromBody] UserPagedRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await invoiceService.GetByUserIdAsync(request.UserId, request.PageNumber, request.PageSize, cancellationToken);
        return Ok(ApiResponse<PagedResult<InvoiceDto>>.Ok(data));
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] CreateInvoiceRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.InvestorUserId) && !User.IsInRole(GoldWalletSystem.Domain.Constants.SystemRoles.Admin))
            return ForbidApiResponse();

        var data = await invoiceService.CreateAsync(request, cancellationToken);
        return Ok(ApiResponse<InvoiceDto>.Ok(data, "Invoice generated"));
    }
}
