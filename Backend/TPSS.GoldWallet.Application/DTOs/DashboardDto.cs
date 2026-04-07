namespace TPSS.GoldWallet.Application.DTOs;

public sealed record DashboardDto(
    Guid CustomerId,
    decimal WalletBalance,
    int CartItemsCount,
    int Last30DaysTransactions,
    int Last30DaysOrders,
    string KycStatus);
