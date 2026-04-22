using GoldWalletSystem.Application.DTOs.Fees;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ISystemFeeService
{
    Task<IReadOnlyList<SystemFeeTypeDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SystemFeeTypeDto>> GetEnabledSellerFeeTabsAsync(CancellationToken cancellationToken = default);
    Task<SystemFeeTypeDto> UpsertAsync(UpsertSystemFeeTypeRequest request, CancellationToken cancellationToken = default);
    Task<bool> IsFeeEnabledForActionAsync(string feeCode, string actionType, CancellationToken cancellationToken = default);
}

public interface ISellerProductFeeService
{
    Task<IReadOnlyList<SellerProductFeeDto>> GetSellerProductFeesAsync(int sellerId, string feeCode, CancellationToken cancellationToken = default);
    Task<SellerProductFeeDto> UpsertAsync(int sellerId, SellerProductFeeUpsertRequest request, CancellationToken cancellationToken = default);
    Task<int> BulkApplyAsync(int sellerId, SellerProductFeeBulkRequest request, CancellationToken cancellationToken = default);
}

public interface IAdminTransactionFeeService
{
    Task<AdminServiceFeeSettingsDto> GetServiceFeeAsync(CancellationToken cancellationToken = default);
    Task<AdminServiceFeeSettingsDto> UpsertServiceFeeAsync(AdminServiceFeeSettingsDto request, CancellationToken cancellationToken = default);
}

public interface IFeeCalculationService
{
    Task<FeeCalculationResultDto> CalculateAsync(FeeCalculationRequest request, CancellationToken cancellationToken = default);
}
