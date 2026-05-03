/*
Cleanup operational data while keeping Users and Sellers information.

Keeps:
- Users
- Sellers
- SellerAddresses, SellerManagers, SellerBranches, SellerBankAccounts, SellerDocuments
- UserProfiles
- System fee metadata/configuration

Clears:
- Products and all product-linked operational rows
- Carts, wallet/assets, orders, invoices, transaction history, fee breakdown rows
- Payment methods/details, notifications, push tokens, audit logs
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    IF OBJECT_ID(N'[Users]') IS NULL OR OBJECT_ID(N'[Sellers]') IS NULL
        THROW 50000, 'Required tables [Users]/[Sellers] are missing.', 1;

    -- Child rows first
    IF OBJECT_ID(N'[TransactionFeeBreakdowns]') IS NOT NULL DELETE FROM [TransactionFeeBreakdowns];

    IF OBJECT_ID(N'[CartItems]') IS NOT NULL DELETE FROM [CartItems];
    IF OBJECT_ID(N'[Carts]') IS NOT NULL DELETE FROM [Carts];

    IF OBJECT_ID(N'[Invoices]') IS NOT NULL DELETE FROM [Invoices];
    IF OBJECT_ID(N'[TransactionHistories]') IS NOT NULL DELETE FROM [TransactionHistories];
    IF OBJECT_ID(N'[PaymentTransactions]') IS NOT NULL DELETE FROM [PaymentTransactions];
    IF OBJECT_ID(N'[Orders]') IS NOT NULL DELETE FROM [Orders];

    IF OBJECT_ID(N'[WalletAssets]') IS NOT NULL DELETE FROM [WalletAssets];
    IF OBJECT_ID(N'[Wallets]') IS NOT NULL DELETE FROM [Wallets];


    IF OBJECT_ID(N'[AppNotifications]') IS NOT NULL DELETE FROM [AppNotifications];
    IF OBJECT_ID(N'[RefreshTokens]') IS NOT NULL DELETE FROM [RefreshTokens];
    IF OBJECT_ID(N'[UserPushTokens]') IS NOT NULL DELETE FROM [UserPushTokens];
    IF OBJECT_ID(N'[AuditLogs]') IS NOT NULL DELETE FROM [AuditLogs];

    IF OBJECT_ID(N'[AdminTransactionFees]') IS NOT NULL DELETE FROM [AdminTransactionFees];
    IF OBJECT_ID(N'[SellerProductFees]') IS NOT NULL DELETE FROM [SellerProductFees];

    -- Parent rows
    IF OBJECT_ID(N'[Products]') IS NOT NULL DELETE FROM [Products];

    COMMIT TRAN;
    PRINT 'Cleanup completed. Users/Sellers information kept.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;
