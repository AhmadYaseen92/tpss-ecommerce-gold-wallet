namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ICurrentUserService
{
    int? UserId { get; }
    int? SellerId { get; }
    bool IsInRole(string role);
}
