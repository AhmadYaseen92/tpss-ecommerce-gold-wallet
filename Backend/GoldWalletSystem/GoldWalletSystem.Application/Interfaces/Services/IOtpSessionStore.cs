using GoldWalletSystem.Application.Models.Otp;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IOtpSessionStore
{
    Task UpsertSessionAsync(OtpSessionModel session, CancellationToken cancellationToken = default);
    Task<OtpSessionModel?> GetSessionAsync(string otpRequestId, CancellationToken cancellationToken = default);
    Task RemoveSessionAsync(string otpRequestId, CancellationToken cancellationToken = default);

    Task UpsertGrantAsync(OtpVerificationGrantModel grant, CancellationToken cancellationToken = default);
    Task<OtpVerificationGrantModel?> GetGrantAsync(string verificationToken, CancellationToken cancellationToken = default);
    Task RemoveGrantAsync(string verificationToken, CancellationToken cancellationToken = default);
}

