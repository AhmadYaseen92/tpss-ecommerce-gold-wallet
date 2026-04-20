namespace GoldWalletSystem.Application.Models.Auth;

public class LoginOtpChallengeModel
{
    public int UserId { get; set; }
    public string OtpHash { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
    public IReadOnlyCollection<string> DeliveryChannels { get; set; } = [];
}

