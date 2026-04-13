/*
Safe schema upgrade for profile payment/bank extended fields.
Run this on an existing DB where tables already exist.
This script is idempotent and avoids CREATE TABLE conflicts.
*/

SET NOCOUNT ON;

IF OBJECT_ID(N'[PaymentMethods]', N'U') IS NOT NULL
BEGIN
    IF OBJECT_ID(N'[CardPaymentMethodDetails]', N'U') IS NULL
    BEGIN
        CREATE TABLE [CardPaymentMethodDetails] (
            [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            [PaymentMethodId] INT NOT NULL UNIQUE,
            [CardNumber] NVARCHAR(30) NOT NULL,
            [CardHolderName] NVARCHAR(120) NOT NULL,
            [Expiry] NVARCHAR(10) NOT NULL,
            [CreatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            [UpdatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            CONSTRAINT [FK_CardPaymentMethodDetails_PaymentMethods_PaymentMethodId] FOREIGN KEY ([PaymentMethodId]) REFERENCES [PaymentMethods]([Id]) ON DELETE CASCADE
        );
    END

    IF OBJECT_ID(N'[ApplePayPaymentMethodDetails]', N'U') IS NULL
    BEGIN
        CREATE TABLE [ApplePayPaymentMethodDetails] (
            [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            [PaymentMethodId] INT NOT NULL UNIQUE,
            [ApplePayToken] NVARCHAR(128) NOT NULL,
            [AccountHolderName] NVARCHAR(120) NOT NULL,
            [CreatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            [UpdatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            CONSTRAINT [FK_ApplePayPaymentMethodDetails_PaymentMethods_PaymentMethodId] FOREIGN KEY ([PaymentMethodId]) REFERENCES [PaymentMethods]([Id]) ON DELETE CASCADE
        );
    END

    IF OBJECT_ID(N'[WalletPaymentMethodDetails]', N'U') IS NULL
    BEGIN
        CREATE TABLE [WalletPaymentMethodDetails] (
            [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            [PaymentMethodId] INT NOT NULL UNIQUE,
            [Provider] NVARCHAR(60) NOT NULL,
            [WalletNumber] NVARCHAR(30) NOT NULL,
            [AccountHolderName] NVARCHAR(120) NOT NULL,
            [CreatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            [UpdatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            CONSTRAINT [FK_WalletPaymentMethodDetails_PaymentMethods_PaymentMethodId] FOREIGN KEY ([PaymentMethodId]) REFERENCES [PaymentMethods]([Id]) ON DELETE CASCADE
        );
    END

    IF OBJECT_ID(N'[CliqPaymentMethodDetails]', N'U') IS NULL
    BEGIN
        CREATE TABLE [CliqPaymentMethodDetails] (
            [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            [PaymentMethodId] INT NOT NULL UNIQUE,
            [CliqAlias] NVARCHAR(60) NOT NULL,
            [BankName] NVARCHAR(120) NOT NULL,
            [AccountHolderName] NVARCHAR(120) NOT NULL,
            [CreatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            [UpdatedAtUtc] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
            CONSTRAINT [FK_CliqPaymentMethodDetails_PaymentMethods_PaymentMethodId] FOREIGN KEY ([PaymentMethodId]) REFERENCES [PaymentMethods]([Id]) ON DELETE CASCADE
        );
    END
END

IF OBJECT_ID(N'[LinkedBankAccounts]', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('LinkedBankAccounts', 'IsDefault') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [IsDefault] BIT NOT NULL CONSTRAINT [DF_LinkedBankAccounts_IsDefault] DEFAULT(0);

    IF COL_LENGTH('LinkedBankAccounts', 'AccountHolderName') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [AccountHolderName] NVARCHAR(120) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_AccountHolderName] DEFAULT(N'');

    IF COL_LENGTH('LinkedBankAccounts', 'AccountNumber') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [AccountNumber] NVARCHAR(40) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_AccountNumber] DEFAULT(N'');

    IF COL_LENGTH('LinkedBankAccounts', 'SwiftCode') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [SwiftCode] NVARCHAR(20) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_SwiftCode] DEFAULT(N'');

    IF COL_LENGTH('LinkedBankAccounts', 'BranchName') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [BranchName] NVARCHAR(120) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_BranchName] DEFAULT(N'');

    IF COL_LENGTH('LinkedBankAccounts', 'BranchAddress') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [BranchAddress] NVARCHAR(250) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_BranchAddress] DEFAULT(N'');

    IF COL_LENGTH('LinkedBankAccounts', 'Country') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [Country] NVARCHAR(80) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_Country] DEFAULT(N'');

    IF COL_LENGTH('LinkedBankAccounts', 'City') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [City] NVARCHAR(80) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_City] DEFAULT(N'');

    IF COL_LENGTH('LinkedBankAccounts', 'Currency') IS NULL
        ALTER TABLE [LinkedBankAccounts] ADD [Currency] NVARCHAR(10) NOT NULL CONSTRAINT [DF_LinkedBankAccounts_Currency] DEFAULT(N'');
END

PRINT 'Profile payment/bank fields upgrade completed.';
