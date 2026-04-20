namespace GoldWalletSystem.Application.Models.Otp;

public class OtpSessionModel
{
    public string OtpRequestId { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string ActionReferenceId { get; set; } = string.Empty;
    public string OtpHash { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime NextResendAtUtc { get; set; }
    public int ResendCount { get; set; }
    public int VerifyAttempts { get; set; }
    public string LastDestinationChannel { get; set; } = "WhatsApp";
    public string LastMaskedDestination { get; set; } = string.Empty;
    public string Status { get; set; } = "Pending";
}

public class OtpVerificationGrantModel
{
    public string VerificationToken { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string ActionReferenceId { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
}

