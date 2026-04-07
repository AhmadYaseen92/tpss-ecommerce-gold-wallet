using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Dashboard.Queries.GetDashboard;

public sealed class GetDashboardQueryHandler(
    IWalletRepository walletRepository,
    ICartRepository cartRepository,
    IKycRepository kycRepository)
    : IRequestHandler<GetDashboardQuery, DashboardDto>
{
    public async Task<DashboardDto> Handle(GetDashboardQuery request, CancellationToken cancellationToken)
    {
        var wallet = await walletRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken);
        var cart = await cartRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken);
        var kyc = await kycRepository.GetLatestByCustomerIdAsync(request.CustomerId, cancellationToken);

        var transactionCount = wallet?.Transactions.Count(x => x.CreatedAtUtc >= DateTime.UtcNow.AddDays(-30)) ?? 0;

        return new DashboardDto(
            request.CustomerId,
            wallet?.Balance ?? 0m,
            cart?.Items.Sum(x => x.Quantity) ?? 0,
            transactionCount,
            0,
            (kyc?.Status.ToString() ?? "Pending"));
    }
}
