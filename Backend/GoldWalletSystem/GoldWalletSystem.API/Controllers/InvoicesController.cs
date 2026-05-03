using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Invoices;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/invoices")]
public class InvoicesController(IInvoiceService invoiceService, ICurrentUserService currentUser, IFeeCalculationService feeCalculationService) : SecuredControllerBase(currentUser)
{
    private static readonly HashSet<string> AllowedCategories = ["Buy", "Sell", "Transfer", "Gift", "Pickup"];
    private static readonly HashSet<string> AllowedPaymentStatuses = ["Pending", "Paid", "Failed", "Cancelled"];

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

        if (!AllowedCategories.Contains(Normalize(request.InvoiceCategory)))
            return BadRequest(ApiResponse<object>.Fail("InvoiceCategory must be one of Buy, Sell, Transfer, Gift, Pickup", 400));

        if (!AllowedPaymentStatuses.Contains(Normalize(request.PaymentStatus)))
            return BadRequest(ApiResponse<object>.Fail("PaymentStatus must be one of Pending, Paid, Failed, Cancelled", 400));

        if (request.Quantity <= 0)
            return BadRequest(ApiResponse<object>.Fail("Invoice quantity must be greater than zero", 400));

        // --- Canonical fee/tax/subtotal calculation ---
        // Use the same logic as wallet action preview/mobile
        var feeRequest = new GoldWalletSystem.Application.DTOs.Fees.FeeCalculationRequest(
            ActionType: request.InvoiceCategory,
            ProductId: request.ProductId,
            SellerId: request.SellerUserId,
            NotionalAmount: request.SubTotal > 0 ? request.SubTotal : request.UnitPrice * request.Quantity,
            Quantity: request.Quantity,
            ClosePrice: request.UnitPrice,
            DaysHeldAfterGrace: 0
        );
        var feeResult = await feeCalculationService.CalculateAsync(feeRequest, cancellationToken);

        request.SubTotal = feeResult.SubTotalAmount;
        request.FeesAmount = feeResult.TotalFeesAmount;
        request.DiscountAmount = feeResult.DiscountAmount;
        // request.TotalAmount = feeResult.FinalAmount; // Removed: property does not exist
        request.Currency = feeResult.Currency;
        // Optionally, map breakdowns to specific fields if needed

        var data = await invoiceService.CreateAsync(request, cancellationToken);
        return Ok(ApiResponse<InvoiceDto>.Ok(data, "Invoice generated"));
    }

    private static string Normalize(string? value) => string.IsNullOrWhiteSpace(value) ? string.Empty : value.Trim();
}
