/*
Baseline seed data for fresh installations.
This script intentionally seeds only:
1) Admin user
2) System configuration rows
3) System fee types

For rich demo/testing fixtures, use sample-data.sql with GW_SEED_SAMPLE_DATA=true.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @Now datetime2 = SYSUTCDATETIME();

    IF OBJECT_ID(N'[Users]', N'U') IS NULL
        THROW 50000, 'Table [Users] is missing. Run migrations first.', 1;

    IF OBJECT_ID(N'[SystemConfigration]', N'U') IS NULL
        THROW 50000, 'Table [SystemConfigration] is missing. Run migrations first.', 1;

    IF OBJECT_ID(N'[SystemFeeTypes]', N'U') IS NULL
        THROW 50000, 'Table [SystemFeeTypes] is missing. Run migrations first.', 1;

    -- Keep first generated user id as 100 on brand new databases.
    IF NOT EXISTS (SELECT 1 FROM [Users])
    BEGIN
        DBCC CHECKIDENT ('[Users]', RESEED, 99);
    END

    -- 1) Admin user
    MERGE [Users] AS T
    USING (
        VALUES
        (N'Gold Wallet Admin', N'admin@goldwallet.com', N'PPJjw8OG+mRgfuQq0PwjBg==.I6aFJ1YwnTWLF8rajLp/30yOAXuGukxV5lx0zFoVuBo=.100000', N'Admin', N'+15551010001')
    ) AS S([FullName],[Email],[PasswordHash],[Role],[PhoneNumber])
    ON T.[Email] = S.[Email]
    WHEN MATCHED THEN
        UPDATE SET
            T.[FullName] = S.[FullName],
            T.[PasswordHash] = S.[PasswordHash],
            T.[Role] = S.[Role],
            T.[PhoneNumber] = S.[PhoneNumber],
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([FullName],[Email],[PasswordHash],[Role],[PhoneNumber],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[FullName],S.[Email],S.[PasswordHash],S.[Role],S.[PhoneNumber],1,@Now,NULL);

    -- 2) System configuration rows
    MERGE [SystemConfigration] AS T
    USING (
        VALUES
        (N'WalletSell_Mode', N'Wallet Sell Mode', N'Wallet sell execution behavior for mobile and web', 1, NULL, NULL, NULL, N'locked_30_seconds', CAST(0 AS bit)),
        (N'WalletSell_LockSeconds', N'Wallet Sell Lock Seconds', N'Wallet sell lock duration in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
        (N'MobileRelease_IsIndividualSeller', N'Mobile Release Is Individual Seller', N'Mobile release: show single seller mode', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'MobileRelease_IndividualSellerName', N'Mobile Release Individual Seller Name', N'Mobile release seller name when single seller mode is enabled', 1, NULL, NULL, NULL, N'Imseeh', CAST(0 AS bit)),
        (N'MobileRelease_ShowWeightInGrams', N'Mobile Release Show Weight In Grams', N'Mobile release flag to show weight in grams', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'MobileRelease_MarketWatchEnabled', N'Mobile Release Market Watch Enabled', N'Mobile release flag to enable Market Watch tab in Product screen', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'MobileRelease_MyAccountSummaryEnabled', N'Mobile Release My Account Summary Enabled', N'Mobile release flag to show My Account Summary entry in top bar', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'MobileSecurity_LoginByBiometric', N'Mobile Security Login By Biometric', N'Allow biometric quick unlock on mobile', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'Product_VideoMaxDurationSeconds', N'Product Video Max Duration Seconds', N'Max allowed uploaded product video duration in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
        (N'MobileSecurity_LoginByPin', N'Mobile Security Login By PIN', N'Allow PIN quick unlock on mobile', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_EnableWhatsapp', N'OTP Enable WhatsApp', N'Enable WhatsApp OTP delivery channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_EnableEmail', N'OTP Enable Email', N'Enable Email OTP delivery channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_ExpirySeconds', N'OTP Expiry Seconds', N'OTP code expiry duration in seconds', 3, NULL, 300, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_ResendCooldownSeconds', N'OTP Resend Cooldown Seconds', N'OTP resend cooldown in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_MaxResendCount', N'OTP Max Resend Count', N'Maximum number of OTP resend attempts', 3, NULL, 3, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_MaxVerificationAttempts', N'OTP Max Verification Attempts', N'Maximum OTP verification attempts before lock', 3, NULL, 5, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_ChannelPriority', N'OTP Channel Priority', N'Preferred OTP channels in order', 1, NULL, NULL, NULL, N'whatsapp,email', CAST(0 AS bit)),
        (N'Otp_RequiredActions', N'OTP Required Actions', N'Actions that require OTP verification', 1, NULL, NULL, NULL, N'registration,reset_password,checkout,sell,transfer,gift,pickup,add_bank_account,edit_bank_account,remove_bank_account,add_payment_method,edit_payment_method,remove_payment_method,change_email,change_password,change_mobile_number', CAST(0 AS bit)),
        (N'Notifications_SellerKycApprove_EmailTemplate', N'Seller KYC Approve Email Template', N'Email template used when seller KYC is approved', 1, NULL, NULL, NULL, N'Hello {SellerName}, your KYC request was approved.', CAST(0 AS bit)),
        (N'Notifications_SellerKycApprove_WhatsappTemplate', N'Seller KYC Approve WhatsApp Template', N'WhatsApp template used when seller KYC is approved', 1, NULL, NULL, NULL, N'KYC approved for {SellerName}.', CAST(0 AS bit)),
        (N'Notifications_SellerKycReject_EmailTemplate', N'Seller KYC Reject Email Template', N'Email template used when seller KYC is rejected', 1, NULL, NULL, NULL, N'Hello {SellerName}, your KYC request was rejected. Note: {ReviewNote}', CAST(0 AS bit)),
        (N'Notifications_SellerKycReject_WhatsappTemplate', N'Seller KYC Reject WhatsApp Template', N'WhatsApp template used when seller KYC is rejected', 1, NULL, NULL, NULL, N'KYC rejected for {SellerName}. Note: {ReviewNote}', CAST(0 AS bit)),
        (N'Notifications_EmailSender_Name', N'Email Sender Name', N'Display name for outbound system email notifications', 1, NULL, NULL, NULL, N'Gold Wallet', CAST(0 AS bit)),
        (N'Notifications_EmailSender_Address', N'Email Sender Address', N'Sender email address for outbound notifications', 1, NULL, NULL, NULL, N'no-reply@goldwallet.local', CAST(0 AS bit)),
        (N'Notifications_WhatsappSender_Number', N'WhatsApp Sender Number', N'Configured sender number for outbound WhatsApp notifications', 1, NULL, NULL, NULL, N'+14155238886', CAST(0 AS bit)),
        (N'Notifications_WhatsappSender_BusinessName', N'WhatsApp Sender Business Name', N'Configured sender business name for outbound WhatsApp notifications', 1, NULL, NULL, NULL, N'Gold Wallet', CAST(0 AS bit)),
        (N'Terms_Seller_TermsAndConditions', N'Seller Terms and Conditions', N'Seller terms shown during seller registration', 1, NULL, NULL, NULL, N'Seller terms placeholder.', CAST(1 AS bit)),
        (N'Terms_Investor_TermsAndConditions', N'Investor Terms and Conditions', N'Investor terms shown during investor registration', 1, NULL, NULL, NULL, N'Investor terms placeholder.', CAST(1 AS bit))
    ) AS S([ConfigKey],[Name],[Description],[ValueType],[ValueBool],[ValueInt],[ValueDecimal],[ValueString],[SellerAccess])
    ON T.[ConfigKey] = S.[ConfigKey]
    WHEN MATCHED THEN
        UPDATE SET
            T.[Name] = S.[Name],
            T.[Description] = S.[Description],
            T.[ValueType] = S.[ValueType],
            T.[ValueBool] = S.[ValueBool],
            T.[ValueInt] = S.[ValueInt],
            T.[ValueDecimal] = S.[ValueDecimal],
            T.[ValueString] = S.[ValueString],
            T.[SellerAccess] = S.[SellerAccess],
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([ConfigKey],[Name],[Description],[ValueType],[ValueBool],[ValueInt],[ValueDecimal],[ValueString],[SellerAccess],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[ConfigKey],S.[Name],S.[Description],S.[ValueType],S.[ValueBool],S.[ValueInt],S.[ValueDecimal],S.[ValueString],S.[SellerAccess],@Now,NULL);

    -- 3) System fee types
    MERGE [SystemFeeTypes] AS T
    USING (
        VALUES
        (N'commission_per_transaction', N'Commission Per Transaction', N'Seller managed commission fee', CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 1),
        (N'premium_discount', N'Premium / Discount', N'Seller managed premium or discount fee', CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 2),
        (N'storage_custody_fee', N'Storage / Custody Fee', N'Seller managed custody fee', CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 3),
        (N'delivery_fee', N'Delivery Fee', N'Seller managed delivery fee', CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 4),
        (N'service_fee', N'Service Fee', N'Admin managed service fee', CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), 6)
    ) AS S([FeeCode],[Name],[Description],[IsEnabled],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift],[AppliesToInvoice],[AppliesToReports],[IsAdminManaged],[SortOrder])
    ON T.[FeeCode] = S.[FeeCode]
    WHEN MATCHED THEN UPDATE SET
        T.[Name] = S.[Name],
        T.[Description] = S.[Description],
        T.[IsEnabled] = S.[IsEnabled],
        T.[AppliesToBuy] = S.[AppliesToBuy],
        T.[AppliesToSell] = S.[AppliesToSell],
        T.[AppliesToPickup] = S.[AppliesToPickup],
        T.[AppliesToTransfer] = S.[AppliesToTransfer],
        T.[AppliesToGift] = S.[AppliesToGift],
        T.[AppliesToInvoice] = S.[AppliesToInvoice],
        T.[AppliesToReports] = S.[AppliesToReports],
        T.[IsAdminManaged] = S.[IsAdminManaged],
        T.[SortOrder] = S.[SortOrder],
        T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([FeeCode],[Name],[Description],[IsEnabled],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift],[AppliesToInvoice],[AppliesToReports],[IsAdminManaged],[SortOrder],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[FeeCode],S.[Name],S.[Description],S.[IsEnabled],S.[AppliesToBuy],S.[AppliesToSell],S.[AppliesToPickup],S.[AppliesToTransfer],S.[AppliesToGift],S.[AppliesToInvoice],S.[AppliesToReports],S.[IsAdminManaged],S.[SortOrder],@Now,NULL);

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN;

    DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity int = ERROR_SEVERITY();
    DECLARE @ErrorState int = ERROR_STATE();

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
