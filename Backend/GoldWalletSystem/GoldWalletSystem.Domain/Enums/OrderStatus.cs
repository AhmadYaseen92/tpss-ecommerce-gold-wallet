namespace GoldWalletSystem.Domain.Enums;

public enum OrderStatus
{
    Pending = 1,
    AwaitingOtp = 2,
    Confirmed = 3,
    Failed = 4,
    Cancelled = 5,
    Expired = 6
}