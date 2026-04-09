namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ICurrentUserService
{
    int? UserId { get; }
    bool IsInRole(string role);
}
