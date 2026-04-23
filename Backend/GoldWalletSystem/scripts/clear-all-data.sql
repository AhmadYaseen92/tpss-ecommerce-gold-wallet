/*
Seed option 3: Clear all data
-----------------------------
Removes transactional + master data (including users/sellers/products) and reseeds identity values.
Use only in local/dev environments.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    IF OBJECT_ID(N'[TransactionFeeBreakdowns]', N'U') IS NOT NULL DELETE FROM [TransactionFeeBreakdowns];
    IF OBJECT_ID(N'[CartItems]', N'U') IS NOT NULL DELETE FROM [CartItems];
    IF OBJECT_ID(N'[Carts]', N'U') IS NOT NULL DELETE FROM [Carts];
    IF OBJECT_ID(N'[WalletAssets]', N'U') IS NOT NULL DELETE FROM [WalletAssets];
    IF OBJECT_ID(N'[Wallets]', N'U') IS NOT NULL DELETE FROM [Wallets];
    IF OBJECT_ID(N'[Invoices]', N'U') IS NOT NULL DELETE FROM [Invoices];
    IF OBJECT_ID(N'[TransactionHistories]', N'U') IS NOT NULL DELETE FROM [TransactionHistories];
    IF OBJECT_ID(N'[PaymentTransactions]', N'U') IS NOT NULL DELETE FROM [PaymentTransactions];
    IF OBJECT_ID(N'[Orders]', N'U') IS NOT NULL DELETE FROM [Orders];

    IF OBJECT_ID(N'[CardPaymentMethodDetails]', N'U') IS NOT NULL DELETE FROM [CardPaymentMethodDetails];
    IF OBJECT_ID(N'[ApplePayPaymentMethodDetails]', N'U') IS NOT NULL DELETE FROM [ApplePayPaymentMethodDetails];
    IF OBJECT_ID(N'[WalletPaymentMethodDetails]', N'U') IS NOT NULL DELETE FROM [WalletPaymentMethodDetails];
    IF OBJECT_ID(N'[CliqPaymentMethodDetails]', N'U') IS NOT NULL DELETE FROM [CliqPaymentMethodDetails];
    IF OBJECT_ID(N'[PaymentMethods]', N'U') IS NOT NULL DELETE FROM [PaymentMethods];
    IF OBJECT_ID(N'[LinkedBankAccounts]', N'U') IS NOT NULL DELETE FROM [LinkedBankAccounts];

    IF OBJECT_ID(N'[AppNotifications]', N'U') IS NOT NULL DELETE FROM [AppNotifications];
    IF OBJECT_ID(N'[RefreshTokens]', N'U') IS NOT NULL DELETE FROM [RefreshTokens];
    IF OBJECT_ID(N'[UserPushTokens]', N'U') IS NOT NULL DELETE FROM [UserPushTokens];
    IF OBJECT_ID(N'[AuditLogs]', N'U') IS NOT NULL DELETE FROM [AuditLogs];

    IF OBJECT_ID(N'[SellerDocuments]', N'U') IS NOT NULL DELETE FROM [SellerDocuments];
    IF OBJECT_ID(N'[SellerBankAccounts]', N'U') IS NOT NULL DELETE FROM [SellerBankAccounts];
    IF OBJECT_ID(N'[SellerManagers]', N'U') IS NOT NULL DELETE FROM [SellerManagers];
    IF OBJECT_ID(N'[SellerBranches]', N'U') IS NOT NULL DELETE FROM [SellerBranches];
    IF OBJECT_ID(N'[SellerAddresses]', N'U') IS NOT NULL DELETE FROM [SellerAddresses];
    IF OBJECT_ID(N'[Products]', N'U') IS NOT NULL DELETE FROM [Products];
    IF OBJECT_ID(N'[UserProfiles]', N'U') IS NOT NULL DELETE FROM [UserProfiles];
    IF OBJECT_ID(N'[Sellers]', N'U') IS NOT NULL DELETE FROM [Sellers];
    IF OBJECT_ID(N'[Users]', N'U') IS NOT NULL DELETE FROM [Users];

    COMMIT TRAN;
    PRINT 'All application data was cleared.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;
