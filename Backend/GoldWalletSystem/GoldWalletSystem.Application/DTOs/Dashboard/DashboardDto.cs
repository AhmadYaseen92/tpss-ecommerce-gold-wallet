namespace GoldWalletSystem.Application.DTOs.Dashboard;

public sealed record DashboardDto(int UserId, string FullName, decimal WalletBalance, int CartItemsCount, int UnreadNotifications, decimal MonthlySpent);
