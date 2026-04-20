namespace GoldWalletSystem.Infrastructure.Services;

public class OtpDeliveryOptions
{
    public WhatsAppDeliveryOptions WhatsApp { get; set; } = new();
    public EmailDeliveryOptions Email { get; set; } = new();
}

public class WhatsAppDeliveryOptions
{
    public bool Enabled { get; set; } = false;
    public string SenderNumber { get; set; } = string.Empty;
    public string AccessToken { get; set; } = string.Empty;
    public string PhoneNumberId { get; set; } = string.Empty;
    public string ApiVersion { get; set; } = "v22.0";
}

public class EmailDeliveryOptions
{
    public bool Enabled { get; set; } = false;
    public string FromAddress { get; set; } = string.Empty;
    public string FromName { get; set; } = "GoldWallet OTP";
    public string SmtpHost { get; set; } = string.Empty;
    public int SmtpPort { get; set; } = 587;
    public bool UseSsl { get; set; } = true;
    public int SendTimeoutMs { get; set; } = 30000;
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
