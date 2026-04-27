/*
Emergency patch for environments where EF migration history advanced
(e.g., empty AddSellerTable migration) but schema objects were not created.
Run once against the target GoldWalletSystem database.
*/

IF OBJECT_ID(N'[Sellers]') IS NULL
BEGIN
    CREATE TABLE [Sellers] (
        [Id] int NOT NULL IDENTITY,
        [Name] nvarchar(200) NOT NULL,
        [Code] nvarchar(50) NOT NULL,
        [ContactEmail] nvarchar(200) NOT NULL,
        [ContactPhone] nvarchar(50) NOT NULL,
        [Address] nvarchar(500) NOT NULL,
        [IsActive] bit NOT NULL,
        [CreatedAtUtc] datetime2 NOT NULL,
        [UpdatedAtUtc] datetime2 NULL,
        CONSTRAINT [PK_Sellers] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (SELECT 1 FROM [Sellers] WHERE [Id] = 1)
BEGIN
    SET IDENTITY_INSERT [Sellers] ON;
    INSERT INTO [Sellers] ([Id], [Name], [Code], [ContactEmail], [ContactPhone], [Address], [IsActive], [CreatedAtUtc], [UpdatedAtUtc])
    VALUES (1, N'Imseeh', N'IMSEEH', N'contact@imseeh.com', N'+962700000001', N'Amman, Jordan', 1, SYSUTCDATETIME(), NULL);
    SET IDENTITY_INSERT [Sellers] OFF;
END;

IF COL_LENGTH('UserProfiles', 'DocumentType') IS NULL
    ALTER TABLE [UserProfiles] ADD [DocumentType] nvarchar(50) NOT NULL CONSTRAINT [DF_UserProfiles_DocumentType] DEFAULT N'';

IF COL_LENGTH('UserProfiles', 'IdNumber') IS NULL
    ALTER TABLE [UserProfiles] ADD [IdNumber] nvarchar(100) NOT NULL CONSTRAINT [DF_UserProfiles_IdNumber] DEFAULT N'';

IF COL_LENGTH('UserProfiles', 'ProfilePhotoUrl') IS NULL
    ALTER TABLE [UserProfiles] ADD [ProfilePhotoUrl] nvarchar(500) NOT NULL CONSTRAINT [DF_UserProfiles_ProfilePhotoUrl] DEFAULT N'';

IF EXISTS (
    SELECT 1
    FROM sys.columns c
    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID(N'[UserProfiles]')
      AND c.name = N'ProfilePhotoUrl'
      AND t.name = N'nvarchar'
      AND c.max_length <> -1
)
BEGIN
    ALTER TABLE [UserProfiles] ALTER COLUMN [ProfilePhotoUrl] nvarchar(max) NOT NULL;
END;

IF COL_LENGTH('Users', 'SellerId') IS NULL
    ALTER TABLE [Users] ADD [SellerId] int NULL;

IF COL_LENGTH('Products', 'SellerId') IS NULL
    ALTER TABLE [Products] ADD [SellerId] int NOT NULL CONSTRAINT [DF_Products_SellerId] DEFAULT 1;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Users_SellerId' AND object_id = OBJECT_ID(N'[Users]'))
    CREATE INDEX [IX_Users_SellerId] ON [Users] ([SellerId]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Products_SellerId' AND object_id = OBJECT_ID(N'[Products]'))
    CREATE INDEX [IX_Products_SellerId] ON [Products] ([SellerId]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Sellers_Code' AND object_id = OBJECT_ID(N'[Sellers]'))
    CREATE UNIQUE INDEX [IX_Sellers_Code] ON [Sellers] ([Code]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Sellers_Name' AND object_id = OBJECT_ID(N'[Sellers]'))
    CREATE INDEX [IX_Sellers_Name] ON [Sellers] ([Name]);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Users_Sellers_SellerId')
BEGIN
    ALTER TABLE [Users] WITH CHECK
    ADD CONSTRAINT [FK_Users_Sellers_SellerId]
    FOREIGN KEY([SellerId]) REFERENCES [Sellers]([Id]) ON DELETE NO ACTION;
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Products_Sellers_SellerId')
BEGIN
    ALTER TABLE [Products] WITH CHECK
    ADD CONSTRAINT [FK_Products_Sellers_SellerId]
    FOREIGN KEY([SellerId]) REFERENCES [Sellers]([Id]) ON DELETE NO ACTION;
END;
