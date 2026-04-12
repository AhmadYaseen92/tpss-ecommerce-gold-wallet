using GoldWalletSystem.Application.DTOs.Profile;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IProfileService
{
    Task<ProfileDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<ProfileDto> UpdatePersonalInfoAsync(UpdateProfilePersonalInfoRequestDto request, CancellationToken cancellationToken = default);
    Task<ProfileDto> UpdateSettingsAsync(UpdateProfileSettingsRequestDto request, CancellationToken cancellationToken = default);
    Task ChangePasswordAsync(UpdatePasswordRequestDto request, CancellationToken cancellationToken = default);
    Task<ProfileDto> UpsertPaymentMethodAsync(UpsertPaymentMethodRequestDto request, CancellationToken cancellationToken = default);
    Task<ProfileDto> UpsertLinkedBankAccountAsync(UpsertLinkedBankAccountRequestDto request, CancellationToken cancellationToken = default);
}
