using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IOtpDeliveryService
{
    Task SendOtpAsync(User user, string otpCode, IReadOnlyCollection<OtpDeliveryChannel> channels, CancellationToken cancellationToken = default);
}
