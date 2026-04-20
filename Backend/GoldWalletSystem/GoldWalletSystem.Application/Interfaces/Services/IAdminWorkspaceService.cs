using GoldWalletSystem.Application.DTOs.Admin;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IAdminWorkspaceService
{
    Task<AdminWorkspaceDto> BuildAsync(CancellationToken cancellationToken = default);
}

public interface ISellerWorkspaceService
{
    Task<SellerWorkspaceDto> BuildAsync(int sellerId, CancellationToken cancellationToken = default);
}
