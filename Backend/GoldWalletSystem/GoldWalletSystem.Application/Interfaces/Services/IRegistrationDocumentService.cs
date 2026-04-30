using GoldWalletSystem.Application.DTOs.Auth;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IRegistrationDocumentService
{
    Task PersistSellerDocumentsAsync(RegisterRequestDto request, CancellationToken cancellationToken = default);
}
