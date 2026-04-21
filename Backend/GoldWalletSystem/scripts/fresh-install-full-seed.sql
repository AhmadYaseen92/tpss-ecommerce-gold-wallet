/*
Fresh installation full seed (idempotent)
----------------------------------------
Use this script after running EF migrations on an empty/new database.
It seeds all core data used by mobile flows:
- Sellers
- Users
- UserProfiles
- Wallets
- Carts
- Products (with Category, WeightValue, WeightUnit)
- WalletAssets (portfolio)
- SystemConfigration (typed system config)
- AuditLogs seed marker
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @Now datetime2 = SYSUTCDATETIME();

    IF OBJECT_ID(N'[Sellers]') IS NULL
        THROW 50000, 'Tables were not found. Run migrations first.', 1;

    DECLARE @SellerUsers TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        PasswordHash nvarchar(500),
        Role nvarchar(50),
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @SellerUsers (FullName, Email, PasswordHash, Role, PhoneNumber)
    VALUES
        (N'Imseeh Seller', N'contact@imseeh.com', N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller', N'+962700000001'),
        (N'Gold Palace Seller', N'contact@goldpalace.com', N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller', N'+15550000002'),
        (N'Bullion House Seller', N'contact@bullionhouse.com', N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller', N'+15550000003');

    MERGE [Users] AS T
    USING @SellerUsers AS S
    ON T.[Email] = S.[Email]
    WHEN MATCHED THEN
        UPDATE SET T.[FullName] = S.[FullName], T.[PasswordHash] = S.[PasswordHash], T.[Role] = S.[Role], T.[PhoneNumber] = S.[PhoneNumber], T.[IsActive] = 1, T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([FullName],[Email],[PasswordHash],[Role],[PhoneNumber],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[FullName],S.[Email],S.[PasswordHash],S.[Role],S.[PhoneNumber],1,@Now,NULL);

    ------------------------------------------------------------
    -- Sellers
    ------------------------------------------------------------
    MERGE [Sellers] AS T
    USING (
        VALUES
            (N'IMSEEH', N'Imseeh', N'contact@imseeh.com', N'+962700000001', N'CR-IMSEEH-001', N'VAT-IMSEEH-001', N'Precious Metals Trading', N'Jordan', N'Amman', N'Wasfi Al Tal St', N'12A', N'11181'),
            (N'GOLDPAL', N'Gold Palace', N'contact@goldpalace.com', N'+15550000002', N'CR-GOLDPAL-002', N'VAT-GOLDPAL-002', N'Bullion Retail', N'United States', N'Dallas', N'Elm Street', N'401', N'75201'),
            (N'BULLION', N'Bullion House', N'contact@bullionhouse.com', N'+15550000003', N'CR-BULLION-003', N'VAT-BULLION-003', N'Coins & Precious Metals', N'United States', N'Miami', N'Biscayne Blvd', N'908', N'33132')
    ) AS S([CompanyCode],[CompanyName],[CompanyEmail],[CompanyPhone],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[Country],[City],[Street],[BuildingNumber],[PostalCode])
    ON T.[CompanyCode] = S.[CompanyCode]
    WHEN MATCHED THEN
        UPDATE SET
            T.[CompanyName] = S.[CompanyName],
            T.[CompanyEmail] = S.[CompanyEmail],
            T.[CompanyPhone] = S.[CompanyPhone],
            T.[CommercialRegistrationNumber] = S.[CommercialRegistrationNumber],
            T.[VatNumber] = S.[VatNumber],
            T.[BusinessActivity] = S.[BusinessActivity],
            T.[UserId] = COALESCE((SELECT TOP 1 U.[Id] FROM [Users] U WHERE U.[Email] = S.[CompanyEmail]), T.[UserId]),
            T.[KycStatus] = 2,
            T.[IsActive] = 1,
            T.[ReviewedAtUtc] = @Now,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([UserId],[CompanyName],[CompanyCode],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[CompanyPhone],[CompanyEmail],[IsActive],[KycStatus],[ReviewedAtUtc],[ReviewNotes],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES ((SELECT TOP 1 U.[Id] FROM [Users] U WHERE U.[Email] = S.[CompanyEmail]),S.[CompanyName],S.[CompanyCode],S.[CommercialRegistrationNumber],S.[VatNumber],S.[BusinessActivity],S.[CompanyPhone],S.[CompanyEmail],1,2,@Now,N'Seeded as approved seller',@Now,NULL);

    MERGE [SellerAddresses] AS T
    USING (
        SELECT S1.Id AS SellerId, S2.Country,S2.City,S2.Street,S2.BuildingNumber,S2.PostalCode
        FROM [Sellers] S1
        JOIN (
            VALUES
                (N'IMSEEH', N'Jordan', N'Amman', N'Wasfi Al Tal St', N'12A', N'11181'),
                (N'GOLDPAL', N'United States', N'Dallas', N'Elm Street', N'401', N'75201'),
                (N'BULLION', N'United States', N'Miami', N'Biscayne Blvd', N'908', N'33132')
        ) S2(CompanyCode,Country,City,Street,BuildingNumber,PostalCode) ON S1.CompanyCode = S2.CompanyCode
    ) AS X
    ON T.SellerId = X.SellerId
    WHEN MATCHED THEN UPDATE SET T.Country=X.Country,T.City=X.City,T.Street=X.Street,T.BuildingNumber=X.BuildingNumber,T.PostalCode=X.PostalCode,T.UpdatedAtUtc=@Now
    WHEN NOT MATCHED THEN
        INSERT (SellerId,Country,City,Street,BuildingNumber,PostalCode,CreatedAtUtc,UpdatedAtUtc)
        VALUES (X.SellerId,X.Country,X.City,X.Street,X.BuildingNumber,X.PostalCode,@Now,NULL);

    DECLARE @SellerImseeh int  = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'IMSEEH');
    DECLARE @SellerGoldPal int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'GOLDPAL');
    DECLARE @SellerBullion int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'BULLION');

    ------------------------------------------------------------
    -- Users
    -- Password hash below is for: Password@123
    ------------------------------------------------------------
    DECLARE @Users TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        PasswordHash nvarchar(500),
        Role nvarchar(50),
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @Users (FullName, Email, PasswordHash, Role, PhoneNumber)
    VALUES
        (N'Imseeh Investor',        N'imseeh.investor@example.com',      N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', N'+962790000001'),
        (N'Gold Palace Investor',   N'goldpal.investor@example.com',     N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', N'+15551020002'),
        (N'Bullion House Investor', N'bullion.investor@example.com',     N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', N'+15551030002'),
        (N'Gold Wallet Investor',   N'investor@goldwallet.com',          N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', N'+962790000999');

    MERGE [Users] AS T
    USING @Users AS S
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

    ------------------------------------------------------------
    -- UserProfiles / Wallets / Carts
    ------------------------------------------------------------
    INSERT INTO [UserProfiles] ([UserId],[DateOfBirth],[Nationality],[PreferredLanguage],[PreferredTheme],[DocumentType],[IdNumber],[ProfilePhotoUrl],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT U.[Id], NULL, N'Unknown', N'en', N'light', N'', N'', N'/images/profiles/default-user.png', @Now, NULL
    FROM [Users] U
    WHERE U.[Email] IN (SELECT [Email] FROM @Users)
      AND NOT EXISTS (SELECT 1 FROM [UserProfiles] P WHERE P.[UserId] = U.[Id]);

    INSERT INTO [Wallets] ([UserId],[CashBalance],[CurrencyCode],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT U.[Id], 10000.00, N'USD', @Now, NULL
    FROM [Users] U
    WHERE U.[Email] IN (SELECT [Email] FROM @Users)
      AND NOT EXISTS (SELECT 1 FROM [Wallets] W WHERE W.[UserId] = U.[Id]);

    INSERT INTO [Carts] ([UserId],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT U.[Id], @Now, NULL
    FROM [Users] U
    WHERE U.[Email] IN (SELECT [Email] FROM @Users)
      AND NOT EXISTS (SELECT 1 FROM [Carts] C WHERE C.[UserId] = U.[Id]);

    ------------------------------------------------------------
    -- Products (Category + Weight fields included)
    ------------------------------------------------------------
    ;WITH SeedProducts AS (
        SELECT @SellerImseeh AS SellerId, N'IMSEEH-PRD-001' AS Sku, N'Imseeh 5g Gold Bar' AS Name, N'24K minted bar - 5 grams' AS [Description], CAST(430.00 AS decimal(18,2)) AS Price, 100 AS AvailableStock, 3 AS Category, CAST(5.000 AS decimal(18,3)) AS WeightValue, 1 AS WeightUnit, N'/images/products/gold-bar.png' AS ImageUrl UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-002', N'Imseeh 1oz Gold Coin', N'Fine gold investment coin', CAST(2675.00 AS decimal(18,2)), 80, 5, CAST(1.000 AS decimal(18,3)), 3, N'/images/products/gold-coin.png' UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-003', N'Imseeh Silver 1oz Coin', N'Investment silver coin', CAST(36.00 AS decimal(18,2)), 500, 6, CAST(1.000 AS decimal(18,3)), 3, N'/images/products/silver.png' UNION ALL

        SELECT @SellerGoldPal, N'GOLDPAL-PRD-001', N'GoldPal 10g Gold Bar', N'24K minted bar - 10 grams', CAST(862.00 AS decimal(18,2)), 100, 3, CAST(10.000 AS decimal(18,3)), 1, N'/images/products/gold-bar.png' UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-002', N'GoldPal 22K Necklace', N'Premium necklace', CAST(1492.00 AS decimal(18,2)), 40, 8, CAST(18.000 AS decimal(18,3)), 1, N'/images/products/jewelry.png' UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-003', N'GoldPal Gift Card 500', N'Store value card', CAST(500.00 AS decimal(18,2)), 999, 10, CAST(1.000 AS decimal(18,3)), 1, N'/images/products/gift-card.png' UNION ALL

        SELECT @SellerBullion, N'BULLION-PRD-001', N'Bullion 20g Gold Bar', N'24K minted bar - 20 grams', CAST(1715.00 AS decimal(18,2)), 100, 3, CAST(20.000 AS decimal(18,3)), 1, N'/images/products/gold-bar.png' UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-002', N'Bullion 1/2oz Gold Coin', N'Half ounce coin', CAST(1355.00 AS decimal(18,2)), 90, 5, CAST(0.500 AS decimal(18,3)), 3, N'/images/products/gold-coin.png' UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-003', N'Bullion Silver 10oz Bar', N'Fine silver bar', CAST(344.00 AS decimal(18,2)), 200, 2, CAST(10.000 AS decimal(18,3)), 3, N'/images/products/silver.png'
    )
    MERGE [Products] AS T
    USING SeedProducts AS S
    ON T.[Sku] = S.[Sku]
    WHEN MATCHED THEN
        UPDATE SET
            T.[SellerId] = S.[SellerId],
            T.[Name] = S.[Name],
            T.[Description] = S.[Description],
            T.[Price] = S.[Price],
            T.[AvailableStock] = S.[AvailableStock],
            T.[Category] = S.[Category],
            T.[WeightValue] = S.[WeightValue],
            T.[WeightUnit] = S.[WeightUnit],
            T.[ImageUrl] = S.[ImageUrl],
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[Name],[Sku],[Description],[Price],[AvailableStock],[Category],[WeightValue],[WeightUnit],[ImageUrl],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[Name],S.[Sku],S.[Description],S.[Price],S.[AvailableStock],S.[Category],S.[WeightValue],S.[WeightUnit],S.[ImageUrl],1,@Now,NULL);

    ------------------------------------------------------------
    -- WalletAssets portfolio rows
    ------------------------------------------------------------
    INSERT INTO [WalletAssets] ([WalletId],[AssetType],[Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[SellerName],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT W.[Id], 1, 100.000, N'gram', 24.00, 1, 6200.00, 6400.00, N'Imseeh', @Now, NULL
    FROM [Wallets] W
    WHERE NOT EXISTS (SELECT 1 FROM [WalletAssets] A WHERE A.[WalletId] = W.[Id] AND A.[AssetType] = 1);

    INSERT INTO [WalletAssets] ([WalletId],[AssetType],[Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[SellerName],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT W.[Id], 5, 250.000, N'gram', 99.90, 1, 220.00, 235.00, N'Bullion House', @Now, NULL
    FROM [Wallets] W
    WHERE NOT EXISTS (SELECT 1 FROM [WalletAssets] A WHERE A.[WalletId] = W.[Id] AND A.[AssetType] = 5);

    INSERT INTO [WalletAssets] ([WalletId],[AssetType],[Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[SellerName],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT W.[Id], 6, 30.000, N'gram', 18.00, 2, 1500.00, 1650.00, N'Gold Palace', @Now, NULL
    FROM [Wallets] W
    WHERE NOT EXISTS (SELECT 1 FROM [WalletAssets] A WHERE A.[WalletId] = W.[Id] AND A.[AssetType] = 6);

    ------------------------------------------------------------
    -- Mobile app config
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Seed marker in audit
    ------------------------------------------------------------
    INSERT INTO [AuditLogs] ([UserId],[Action],[EntityName],[EntityId],[Details],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES (NULL, N'SEED_RUN', N'System', NULL, N'fresh-install-full-seed.sql executed successfully.', @Now, NULL);

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;

-- quick verify
SELECT COUNT(*) AS SellersCount FROM [Sellers];
SELECT COUNT(*) AS UsersCount FROM [Users];
SELECT COUNT(*) AS ProductsCount FROM [Products];
SELECT COUNT(*) AS WalletsCount FROM [Wallets];
SELECT COUNT(*) AS WalletAssetsCount FROM [WalletAssets];
