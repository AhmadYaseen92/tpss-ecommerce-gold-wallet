/*
Safe schema upgrade for profile payment/bank extended fields.
Run this on an existing DB where tables already exist.
This script is idempotent and avoids CREATE TABLE conflicts.
*/

SET NOCOUNT ON;

IF OBJECT_ID(N'[PaymentMethods]', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('PaymentMethods', 'HolderName') IS NULL
        ALTER TABLE [PaymentMethods] ADD [HolderName] NVARCHAR(120) NOT NULL CONSTRAINT [DF_PaymentMethods_HolderName] DEFAULT(N'');

    IF COL_LENGTH('PaymentMethods', 'Expiry') IS NULL
        ALTER TABLE [PaymentMethods] ADD [Expiry] NVARCHAR(10) NOT NULL CONSTRAINT [DF_PaymentMethods_Expiry] DEFAULT(N'');

    IF COL_LENGTH('PaymentMethods', 'DetailsJson') IS NULL
        ALTER TABLE [PaymentMethods] ADD [DetailsJson] NVARCHAR(1000) NOT NULL CONSTRAINT [DF_PaymentMethods_DetailsJson] DEFAULT(N'');
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
