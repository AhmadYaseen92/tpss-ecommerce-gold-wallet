namespace GoldWalletSystem.Application.Constants;

public static class MobileAppConfigurationKeys
{
    public const string OtpEnableWhatsapp = "Otp_EnableWhatsapp";
    public const string OtpEnableEmail = "Otp_EnableEmail";
    public const string OtpExpirySeconds = "Otp_ExpirySeconds";
    public const string OtpResendCooldownSeconds = "Otp_ResendCooldownSeconds";
    public const string OtpMaxResendCount = "Otp_MaxResendCount";
    public const string OtpMaxVerificationAttempts = "Otp_MaxVerificationAttempts";
    public const string OtpRequiredActions = "Otp_RequiredActions";
    public const string OtpChannelPriority = "Otp_ChannelPriority";

    public const string WalletSellMode = "WalletSell_Mode";
    public const string WalletSellLockSeconds = "WalletSell_LockSeconds";

    public const string FeesDelivery = "Fees_Delivery";
    public const string FeesStorage = "Fees_Storage";
    public const string FeesServiceChargePercent = "Fees_ServiceChargePercent";

    public const string MobileReleaseIsIndividualSeller = "MobileRelease_IsIndividualSeller";
    public const string MobileReleaseIndividualSellerName = "MobileRelease_IndividualSellerName";
    public const string MobileReleaseShowWeightInGrams = "MobileRelease_ShowWeightInGrams";
}
