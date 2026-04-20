using GoldWalletSystem.Application.DTOs.Admin;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Services;

public class AdminWorkspaceService(AppDbContext dbContext) : IAdminWorkspaceService
{
    public async Task<AdminWorkspaceDto> BuildAsync(CancellationToken cancellationToken = default)
    {
        return new AdminWorkspaceDto
        {
            SellersCount = await dbContext.Sellers.AsNoTracking().CountAsync(cancellationToken),
            InvestorsCount = await dbContext.Users.AsNoTracking().CountAsync(x => x.Role == SystemRoles.Investor, cancellationToken),
            ProductsCount = await dbContext.Products.AsNoTracking().CountAsync(cancellationToken),
            RequestsCount = await dbContext.TransactionHistories.AsNoTracking().CountAsync(cancellationToken),
            SystemSettingsCount = await dbContext.MobileAppConfigurations.AsNoTracking().CountAsync(cancellationToken)
        };
    }
}

public class SellerWorkspaceService(AppDbContext dbContext) : ISellerWorkspaceService
{
    public async Task<SellerWorkspaceDto> BuildAsync(int sellerId, CancellationToken cancellationToken = default)
    {
        return new SellerWorkspaceDto
        {
            SellerId = sellerId,
            ProductsCount = await dbContext.Products.AsNoTracking().CountAsync(x => x.SellerId == sellerId, cancellationToken),
            InvestorsCount = await dbContext.TransactionHistories.AsNoTracking().Where(x => x.SellerId == sellerId).Select(x => x.UserId).Distinct().CountAsync(cancellationToken),
            RequestsCount = await dbContext.TransactionHistories.AsNoTracking().CountAsync(x => x.SellerId == sellerId, cancellationToken),
            ActiveOffersCount = await dbContext.Products.AsNoTracking().CountAsync(x => x.SellerId == sellerId && x.IsHasOffer, cancellationToken)
        };
    }
}
