using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Fees;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/fees")]
public class FeeManagementController(
    ISystemFeeService systemFeeService,
    ISellerProductFeeService sellerProductFeeService,
    IAdminTransactionFeeService adminTransactionFeeService,
    IFeeCalculationService feeCalculationService) : ControllerBase
{
    [HttpGet("system")]
    [Authorize(Roles = SystemRoles.Admin)]
    public async Task<IActionResult> GetSystemFeeTypes(CancellationToken cancellationToken)
        => Ok(ApiResponse<IReadOnlyList<SystemFeeTypeDto>>.Ok(await systemFeeService.GetAllAsync(cancellationToken)));

    [HttpPut("system")]
    [Authorize(Roles = SystemRoles.Admin)]
    public async Task<IActionResult> UpsertSystemFeeType([FromBody] UpsertSystemFeeTypeRequest request, CancellationToken cancellationToken)
        => Ok(ApiResponse<SystemFeeTypeDto>.Ok(await systemFeeService.UpsertAsync(request, cancellationToken)));

    [HttpGet("service-fee")]
    [Authorize(Roles = SystemRoles.Admin)]
    public async Task<IActionResult> GetServiceFee(CancellationToken cancellationToken)
        => Ok(ApiResponse<AdminServiceFeeSettingsDto>.Ok(await adminTransactionFeeService.GetServiceFeeAsync(cancellationToken)));

    [HttpPut("service-fee")]
    [Authorize(Roles = SystemRoles.Admin)]
    public async Task<IActionResult> UpsertServiceFee([FromBody] AdminServiceFeeSettingsDto request, CancellationToken cancellationToken)
        => Ok(ApiResponse<AdminServiceFeeSettingsDto>.Ok(await adminTransactionFeeService.UpsertServiceFeeAsync(request, cancellationToken)));

    [HttpGet("seller/tabs")]
    [Authorize(Roles = SystemRoles.Seller)]
    public async Task<IActionResult> GetSellerTabs(CancellationToken cancellationToken)
        => Ok(ApiResponse<IReadOnlyList<SystemFeeTypeDto>>.Ok(await systemFeeService.GetEnabledSellerFeeTabsAsync(cancellationToken)));

    [HttpGet("seller/products/{feeCode}")]
    [Authorize(Roles = SystemRoles.Seller)]
    public async Task<IActionResult> GetSellerProductFees(string feeCode, CancellationToken cancellationToken)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        if (!int.TryParse(sellerIdClaim, out var sellerId) || sellerId <= 0)
            return BadRequest(ApiResponse<object>.Fail("Invalid seller scope", 400));

        if (feeCode == FeeCodes.ServiceFee)
            return Forbid();

        var result = await sellerProductFeeService.GetSellerProductFeesAsync(sellerId, feeCode, cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<SellerProductFeeDto>>.Ok(result));
    }

    [HttpPut("seller/products")]
    [Authorize(Roles = SystemRoles.Seller)]
    public async Task<IActionResult> UpsertSellerProductFee([FromBody] SellerProductFeeUpsertRequest request, CancellationToken cancellationToken)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        if (!int.TryParse(sellerIdClaim, out var sellerId) || sellerId <= 0)
            return BadRequest(ApiResponse<object>.Fail("Invalid seller scope", 400));

        if (request.FeeCode == FeeCodes.ServiceFee)
            return Forbid();

        var result = await sellerProductFeeService.UpsertAsync(sellerId, request, cancellationToken);
        return Ok(ApiResponse<SellerProductFeeDto>.Ok(result));
    }

    [HttpPut("seller/products/bulk")]
    [Authorize(Roles = SystemRoles.Seller)]
    public async Task<IActionResult> BulkUpsertSellerProductFee([FromBody] SellerProductFeeBulkRequest request, CancellationToken cancellationToken)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        if (!int.TryParse(sellerIdClaim, out var sellerId) || sellerId <= 0)
            return BadRequest(ApiResponse<object>.Fail("Invalid seller scope", 400));

        if (request.FeeCode == FeeCodes.ServiceFee)
            return Forbid();

        var count = await sellerProductFeeService.BulkApplyAsync(sellerId, request, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { updated = count }));
    }

    [HttpPost("calculate")]
    public async Task<IActionResult> Calculate([FromBody] FeeCalculationRequest request, CancellationToken cancellationToken)
        => Ok(ApiResponse<FeeCalculationResultDto>.Ok(await feeCalculationService.CalculateAsync(request, cancellationToken)));
}
