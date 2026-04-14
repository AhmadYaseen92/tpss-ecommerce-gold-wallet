/*
  Upgrade TransactionHistories schema:
  - Add Status, Category, Quantity, UnitPrice, Weight, Unit, Purity, Notes
  - Drop Reference
*/
IF COL_LENGTH('TransactionHistories', 'Status') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [Status] NVARCHAR(30) NOT NULL CONSTRAINT DF_TransactionHistories_Status DEFAULT 'pending';

IF COL_LENGTH('TransactionHistories', 'Category') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [Category] NVARCHAR(50) NOT NULL CONSTRAINT DF_TransactionHistories_Category DEFAULT 'Gold';

IF COL_LENGTH('TransactionHistories', 'Quantity') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [Quantity] INT NOT NULL CONSTRAINT DF_TransactionHistories_Quantity DEFAULT 1;

IF COL_LENGTH('TransactionHistories', 'UnitPrice') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [UnitPrice] DECIMAL(18,2) NOT NULL CONSTRAINT DF_TransactionHistories_UnitPrice DEFAULT 0;

IF COL_LENGTH('TransactionHistories', 'Weight') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [Weight] DECIMAL(18,3) NOT NULL CONSTRAINT DF_TransactionHistories_Weight DEFAULT 0;

IF COL_LENGTH('TransactionHistories', 'Unit') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [Unit] NVARCHAR(20) NOT NULL CONSTRAINT DF_TransactionHistories_Unit DEFAULT 'gram';

IF COL_LENGTH('TransactionHistories', 'Purity') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [Purity] DECIMAL(5,2) NOT NULL CONSTRAINT DF_TransactionHistories_Purity DEFAULT 0;

IF COL_LENGTH('TransactionHistories', 'Notes') IS NULL
    ALTER TABLE [dbo].[TransactionHistories] ADD [Notes] NVARCHAR(1000) NOT NULL CONSTRAINT DF_TransactionHistories_Notes DEFAULT '';

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TransactionHistories_Reference' AND object_id = OBJECT_ID('[dbo].[TransactionHistories]'))
    DROP INDEX [IX_TransactionHistories_Reference] ON [dbo].[TransactionHistories];

IF COL_LENGTH('TransactionHistories', 'Reference') IS NOT NULL
    ALTER TABLE [dbo].[TransactionHistories] DROP COLUMN [Reference];
