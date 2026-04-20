namespace GoldWalletSystem.Application.DTOs.Otp;

public class RequestOtpRequestDto
{
    public int UserId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string ActionReferenceId { get; set; } = string.Empty;
    public bool ForceEmailFallback { get; set; }
}

public class ResendOtpRequestDto
{
    public int UserId { get; set; }
    public string OtpRequestId { get; set; } = string.Empty;
    public bool ForceEmailFallback { get; set; }
}

public class VerifyOtpRequestDto
{
    public int UserId { get; set; }
    public string OtpRequestId { get; set; } = string.Empty;
    public string OtpCode { get; set; } = string.Empty;
}

public class OtpDispatchResponseDto
{
    public required string OtpRequestId { get; init; }
    public required string ActionType { get; init; }
    public required string ActionReferenceId { get; init; }
    public required string DestinationChannel { get; init; }
    public required string MaskedDestination { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public required DateTime NextResendAtUtc { get; init; }
    public required int RemainingResends { get; init; }
}

public class VerifyOtpResponseDto
{
    public required string VerificationToken { get; init; }
    public required string ActionType { get; init; }
    public required string ActionReferenceId { get; init; }
    public required DateTime VerifiedAtUtc { get; init; }
}

public class OtpVerificationGateDto
{
    public string OtpVerificationToken { get; set; } = string.Empty;
    public string OtpActionReferenceId { get; set; } = string.Empty;
}

