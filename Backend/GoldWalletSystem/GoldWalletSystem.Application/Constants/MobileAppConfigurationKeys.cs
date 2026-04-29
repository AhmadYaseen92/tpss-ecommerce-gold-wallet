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
    public const string MobileReleaseMarketWatchEnabled = "MobileRelease_MarketWatchEnabled";
    public const string MobileReleaseMyAccountSummaryEnabled = "MobileRelease_MyAccountSummaryEnabled";
    public const string ProductVideoMaxDurationSeconds = "Product_VideoMaxDurationSeconds";
    public const string LoginByBiometricEnabled = "MobileSecurity_LoginByBiometric";
    public const string LoginByPinEnabled = "MobileSecurity_LoginByPin";

    public const string SellerKycApproveEmailTemplate = "Notifications_SellerKycApprove_EmailTemplate";
    public const string SellerKycApproveWhatsappTemplate = "Notifications_SellerKycApprove_WhatsappTemplate";
    public const string SellerKycRejectEmailTemplate = "Notifications_SellerKycReject_EmailTemplate";
    public const string SellerKycRejectWhatsappTemplate = "Notifications_SellerKycReject_WhatsappTemplate";
    public const string EmailSenderName = "Notifications_EmailSender_Name";
    public const string EmailSenderAddress = "Notifications_EmailSender_Address";
    public const string WhatsappSenderNumber = "Notifications_WhatsappSender_Number";
    public const string WhatsappSenderBusinessName = "Notifications_WhatsappSender_BusinessName";
    public const string SellerTermsAndConditions = "Terms_Seller_TermsAndConditions";
    public const string InvestorTermsAndConditions = "Terms_Investor_TermsAndConditions";
}
