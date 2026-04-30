namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IProfileMediaService
{
    Task<string> ResolveProfilePhotoUrlAsync(int userId, string profilePhotoUrl, CancellationToken cancellationToken = default);
}
