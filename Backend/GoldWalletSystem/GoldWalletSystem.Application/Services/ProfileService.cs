using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class ProfileService(IProfileRepository profileRepository) : IProfileService
{
    public Task<ProfileDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
        => profileRepository.GetByUserIdAsync(userId, cancellationToken);

    public Task<ProfileDto> UpdatePersonalInfoAsync(UpdateProfilePersonalInfoRequestDto request, CancellationToken cancellationToken = default)
        => profileRepository.UpdatePersonalInfoAsync(request, cancellationToken);

    public Task<ProfileDto> UpdateSettingsAsync(UpdateProfileSettingsRequestDto request, CancellationToken cancellationToken = default)
        => profileRepository.UpdateSettingsAsync(request, cancellationToken);

    public Task ChangePasswordAsync(UpdatePasswordRequestDto request, CancellationToken cancellationToken = default)
        => profileRepository.ChangePasswordAsync(request, cancellationToken);

    public Task<ProfileDto> UpsertPaymentMethodAsync(UpsertPaymentMethodRequestDto request, CancellationToken cancellationToken = default)
        => profileRepository.UpsertPaymentMethodAsync(request, cancellationToken);

    public Task<ProfileDto> UpsertLinkedBankAccountAsync(UpsertLinkedBankAccountRequestDto request, CancellationToken cancellationToken = default)
        => profileRepository.UpsertLinkedBankAccountAsync(request, cancellationToken);
}
