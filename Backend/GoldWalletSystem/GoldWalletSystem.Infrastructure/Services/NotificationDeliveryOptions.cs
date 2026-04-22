namespace GoldWalletSystem.Infrastructure.Services;

public class NotificationDeliveryOptions
{
    public const string SectionName = "Notifications";
    public bool EnableSignalRDelivery { get; set; } = true;
    public bool EnablePushDelivery { get; set; } = false;
    public string PushProvider { get; set; } = "None";
    public string? FirebaseProjectId { get; set; }
    public string? FirebaseCredentialsPath { get; set; }
}
