/*
Full merged seed script for GoldWalletSystemDb

Includes:
1) Sellers upsert
2) Users upsert
3) New user: investor@goldwallet.com
4) UserProfiles, Wallets, Carts creation
5) Empty startup state for CartItems, WalletAssets, TransactionHistories
6) Products upsert with LOCAL server image paths
7) Home carousel config with LOCAL banner paths
8) Audit logs
9) Verification queries

Important:
- Product images should exist physically under:
  GoldWalletSystem.API/wwwroot/images/products/
- Banner images should exist physically under:
  GoldWalletSystem.API/wwwroot/images/banners/
- Profile default image should exist physically under:
  GoldWalletSystem.API/wwwroot/images/profiles/
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @Now datetime2 = SYSUTCDATETIME();

    ------------------------------------------------------------
    -- 1) Sellers (upsert)
    ------------------------------------------------------------
    IF OBJECT_ID(N'[Sellers]') IS NULL
        THROW 50000, 'Sellers table not found. Run migrations first.', 1;

    MERGE [Sellers] AS T
    USING (
        VALUES
            (N'Imseeh',        N'IMSEEH',  N'contact@imseeh.com',       N'+962700000001', N'Amman, Jordan'),
            (N'Gold Palace',   N'GOLDPAL', N'contact@goldpalace.com',   N'+15550000002',  N'Dallas, TX'),
            (N'Bullion House', N'BULLION', N'contact@bullionhouse.com', N'+15550000003',  N'Miami, FL')
    ) AS S([Name],[Code],[ContactEmail],[ContactPhone],[Address])
    ON T.[Code] = S.[Code]
    WHEN MATCHED THEN
        UPDATE SET
            T.[Name] = S.[Name],
            T.[ContactEmail] = S.[ContactEmail],
            T.[ContactPhone] = S.[ContactPhone],
            T.[Address] = S.[Address],
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([Name],[Code],[ContactEmail],[ContactPhone],[Address],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[Name],S.[Code],S.[ContactEmail],S.[ContactPhone],S.[Address],1,@Now,NULL);

    DECLARE @SellerImseeh int  = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [Code] = N'IMSEEH');
    DECLARE @SellerGoldPal int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [Code] = N'GOLDPAL');
    DECLARE @SellerBullion int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [Code] = N'BULLION');

    ------------------------------------------------------------
    -- 2) Users (upsert)
    ------------------------------------------------------------
    DECLARE @Users TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        PasswordHash nvarchar(500),
        Role nvarchar(50),
        SellerId int,
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @Users (FullName, Email, PasswordHash, Role, SellerId, PhoneNumber)
    VALUES
        (N'Imseeh Admin',         N'imseeh.admin@example.com',        N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', @SellerImseeh,  N'+15551010001'),
        (N'Imseeh Investor 1',    N'imseeh.investor1@example.com',    N'E4AJcY7MeKmJOoaxRXzfXg==.Yd4IWfYBZUqs83ho+2xLhTrveNqLL+Vojtvn3jjsMN8=.100000', N'Investor', @SellerImseeh,  N'+15551010002'),
        (N'Imseeh Investor 2',    N'imseeh.investor2@example.com',    N'ypOP7c/XCKhyT+WKcMam6w==.TT+y6q2s43OZ+sUjxKP73qeko4RlY2bzF0vNo9yPSgk=.100000', N'Investor', @SellerImseeh,  N'+15551010003'),

        (N'GoldPal Admin',        N'goldpal.admin@example.com',       N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', @SellerGoldPal, N'+15551020001'),
        (N'GoldPal Investor1',    N'goldpal.investor1@example.com',   N'E4AJcY7MeKmJOoaxRXzfXg==.Yd4IWfYBZUqs83ho+2xLhTrveNqLL+Vojtvn3jjsMN8=.100000', N'Investor', @SellerGoldPal, N'+15551020002'),
        (N'GoldPal Investor2',    N'goldpal.investor2@example.com',   N'ypOP7c/XCKhyT+WKcMam6w==.TT+y6q2s43OZ+sUjxKP73qeko4RlY2bzF0vNo9yPSgk=.100000', N'Investor', @SellerGoldPal, N'+15551020003'),

        (N'Bullion Admin',        N'bullion.admin@example.com',       N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', @SellerBullion, N'+15551030001'),
        (N'Bullion Investor1',    N'bullion.investor1@example.com',   N'E4AJcY7MeKmJOoaxRXzfXg==.Yd4IWfYBZUqs83ho+2xLhTrveNqLL+Vojtvn3jjsMN8=.100000', N'Investor', @SellerBullion, N'+15551030002'),
        (N'Bullion Investor2',    N'bullion.investor2@example.com',   N'ypOP7c/XCKhyT+WKcMam6w==.TT+y6q2s43OZ+sUjxKP73qeko4RlY2bzF0vNo9yPSgk=.100000', N'Investor', @SellerBullion, N'+15551030003'),

        -- Requested new user
        (N'Gold Wallet Investor', N'investor@goldwallet.com',         N'NN53R1Ggd5QH71EKW6wALA==.UbTyu0VUnNi27SE8JQbIjY5d8gs3jgo+SiUsNtLtt8I=.100000', N'Investor', @SellerImseeh,  N'+962790000999');

    MERGE [Users] AS T
    USING @Users AS S
    ON T.[Email] = S.[Email]
    WHEN MATCHED THEN
        UPDATE SET
            T.[FullName] = S.[FullName],
            T.[PasswordHash] = S.[PasswordHash],
            T.[Role] = S.[Role],
            T.[SellerId] = S.[SellerId],
            T.[PhoneNumber] = S.[PhoneNumber],
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([FullName],[Email],[PasswordHash],[Role],[SellerId],[PhoneNumber],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[FullName],S.[Email],S.[PasswordHash],S.[Role],S.[SellerId],S.[PhoneNumber],1,@Now,NULL);

    ------------------------------------------------------------
    -- 3) Ensure profile/wallet/cart for all seeded users
    ------------------------------------------------------------
    INSERT INTO [UserProfiles] ([UserId],[DateOfBirth],[Nationality],[PreferredLanguage],[PreferredTheme],[DocumentType],[IdNumber],[ProfilePhotoUrl],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT U.[Id], NULL, N'Unknown', N'en', N'light', N'', N'', N'/images/profiles/default-user.png', @Now, NULL
    FROM [Users] U
    WHERE U.[Email] IN (SELECT [Email] FROM @Users)
      AND NOT EXISTS (SELECT 1 FROM [UserProfiles] P WHERE P.[UserId] = U.[Id]);

    INSERT INTO [Wallets] ([UserId],[CashBalance],[CurrencyCode],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT U.[Id], 0, N'USD', @Now, NULL
    FROM [Users] U
    WHERE U.[Email] IN (SELECT [Email] FROM @Users)
      AND NOT EXISTS (SELECT 1 FROM [Wallets] W WHERE W.[UserId] = U.[Id]);

    INSERT INTO [Carts] ([UserId],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT U.[Id], @Now, NULL
    FROM [Users] U
    WHERE U.[Email] IN (SELECT [Email] FROM @Users)
      AND NOT EXISTS (SELECT 1 FROM [Carts] C WHERE C.[UserId] = U.[Id]);

    ------------------------------------------------------------
    -- 4) Keep startup state empty
    ------------------------------------------------------------
    DELETE CI
    FROM [CartItems] CI
    INNER JOIN [Carts] C ON C.[Id] = CI.[CartId]
    INNER JOIN [Users] U ON U.[Id] = C.[UserId]
    WHERE U.[Email] IN (SELECT [Email] FROM @Users);

    DELETE WA
    FROM [WalletAssets] WA
    INNER JOIN [Wallets] W ON W.[Id] = WA.[WalletId]
    INNER JOIN [Users] U ON U.[Id] = W.[UserId]
    WHERE U.[Email] IN (SELECT [Email] FROM @Users);

    DELETE TH
    FROM [TransactionHistories] TH
    INNER JOIN [Users] U ON U.[Id] = TH.[UserId]
    WHERE U.[Email] IN (SELECT [Email] FROM @Users);

    ------------------------------------------------------------
    -- 5) Products seed source
    ------------------------------------------------------------
    UPDATE [Products]
    SET [ImageUrl] = N'/images/products/gold-bar.png'
    WHERE [ImageUrl] IS NULL OR LTRIM(RTRIM([ImageUrl])) = N'';

    ;WITH SeedProducts AS (
        SELECT @SellerImseeh AS SellerId, N'IMSEEH-PRD-001' AS Sku, N'Imseeh 5g Gold Bar' AS Name, N'24K minted bar - 5 grams' AS [Description], CAST(430.00 AS decimal(18,2)) AS Price, 100 AS AvailableStock UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-002', N'Imseeh 10g Gold Bar', N'24K minted bar - 10 grams', CAST(860.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-003', N'Imseeh 20g Gold Bar', N'24K minted bar - 20 grams', CAST(1710.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-004', N'Imseeh 1oz Gold Coin', N'Fine gold investment coin', CAST(2675.00 AS decimal(18,2)), 80 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-005', N'Imseeh 50g Gold Bar', N'Premium cast bar - 50 grams', CAST(4250.00 AS decimal(18,2)), 60 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-006', N'Imseeh 100g Gold Bar', N'Premium cast bar - 100 grams', CAST(8500.00 AS decimal(18,2)), 40 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-007', N'Imseeh 1g Gold Bar', N'Entry-level gold bar', CAST(90.00 AS decimal(18,2)), 200 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-008', N'Imseeh 2.5g Gold Bar', N'Fractional minted bar', CAST(220.00 AS decimal(18,2)), 180 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-009', N'Imseeh 1/2oz Gold Coin', N'Half ounce coin', CAST(1350.00 AS decimal(18,2)), 90 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-010', N'Imseeh 1/4oz Gold Coin', N'Quarter ounce coin', CAST(690.00 AS decimal(18,2)), 120 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-011', N'Imseeh Silver 1oz Coin', N'Investment silver coin', CAST(36.00 AS decimal(18,2)), 500 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-012', N'Imseeh Silver 10oz Bar', N'Fine silver bar', CAST(340.00 AS decimal(18,2)), 200 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-013', N'Imseeh 22K Bracelet', N'Gold jewelry investment grade', CAST(980.00 AS decimal(18,2)), 50 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-014', N'Imseeh 22K Necklace', N'Premium necklace', CAST(1490.00 AS decimal(18,2)), 40 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-015', N'Imseeh Gram Saver Pack', N'10x1g package', CAST(905.00 AS decimal(18,2)), 70 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-016', N'Imseeh Wedding Set', N'Gold ceremonial set', CAST(2200.00 AS decimal(18,2)), 25 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-017', N'Imseeh Kids Gold Coin', N'Special edition coin', CAST(180.00 AS decimal(18,2)), 180 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-018', N'Imseeh Collector Coin 2026', N'Limited series', CAST(320.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-019', N'Imseeh Gift Card 500', N'Store value card', CAST(500.00 AS decimal(18,2)), 999 UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-020', N'Imseeh Gift Card 1000', N'Store value card', CAST(1000.00 AS decimal(18,2)), 999 UNION ALL

        SELECT @SellerGoldPal, N'GOLDPAL-PRD-001', N'GoldPal 5g Gold Bar', N'24K minted bar - 5 grams', CAST(432.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-002', N'GoldPal 10g Gold Bar', N'24K minted bar - 10 grams', CAST(862.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-003', N'GoldPal 20g Gold Bar', N'24K minted bar - 20 grams', CAST(1712.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-004', N'GoldPal 1oz Gold Coin', N'Fine gold investment coin', CAST(2678.00 AS decimal(18,2)), 80 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-005', N'GoldPal 50g Gold Bar', N'Premium cast bar - 50 grams', CAST(4254.00 AS decimal(18,2)), 60 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-006', N'GoldPal 100g Gold Bar', N'Premium cast bar - 100 grams', CAST(8508.00 AS decimal(18,2)), 40 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-007', N'GoldPal 1g Gold Bar', N'Entry-level gold bar', CAST(91.00 AS decimal(18,2)), 200 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-008', N'GoldPal 2.5g Gold Bar', N'Fractional minted bar', CAST(221.00 AS decimal(18,2)), 180 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-009', N'GoldPal 1/2oz Gold Coin', N'Half ounce coin', CAST(1352.00 AS decimal(18,2)), 90 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-010', N'GoldPal 1/4oz Gold Coin', N'Quarter ounce coin', CAST(692.00 AS decimal(18,2)), 120 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-011', N'GoldPal Silver 1oz Coin', N'Investment silver coin', CAST(37.00 AS decimal(18,2)), 500 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-012', N'GoldPal Silver 10oz Bar', N'Fine silver bar', CAST(342.00 AS decimal(18,2)), 200 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-013', N'GoldPal 22K Bracelet', N'Gold jewelry investment grade', CAST(982.00 AS decimal(18,2)), 50 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-014', N'GoldPal 22K Necklace', N'Premium necklace', CAST(1492.00 AS decimal(18,2)), 40 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-015', N'GoldPal Gram Saver Pack', N'10x1g package', CAST(907.00 AS decimal(18,2)), 70 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-016', N'GoldPal Wedding Set', N'Gold ceremonial set', CAST(2203.00 AS decimal(18,2)), 25 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-017', N'GoldPal Kids Gold Coin', N'Special edition coin', CAST(181.00 AS decimal(18,2)), 180 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-018', N'GoldPal Collector Coin 2026', N'Limited series', CAST(321.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-019', N'GoldPal Gift Card 500', N'Store value card', CAST(500.00 AS decimal(18,2)), 999 UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-020', N'GoldPal Gift Card 1000', N'Store value card', CAST(1000.00 AS decimal(18,2)), 999 UNION ALL

        SELECT @SellerBullion, N'BULLION-PRD-001', N'Bullion 5g Gold Bar', N'24K minted bar - 5 grams', CAST(433.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-002', N'Bullion 10g Gold Bar', N'24K minted bar - 10 grams', CAST(864.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-003', N'Bullion 20g Gold Bar', N'24K minted bar - 20 grams', CAST(1715.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-004', N'Bullion 1oz Gold Coin', N'Fine gold investment coin', CAST(2680.00 AS decimal(18,2)), 80 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-005', N'Bullion 50g Gold Bar', N'Premium cast bar - 50 grams', CAST(4258.00 AS decimal(18,2)), 60 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-006', N'Bullion 100g Gold Bar', N'Premium cast bar - 100 grams', CAST(8512.00 AS decimal(18,2)), 40 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-007', N'Bullion 1g Gold Bar', N'Entry-level gold bar', CAST(92.00 AS decimal(18,2)), 200 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-008', N'Bullion 2.5g Gold Bar', N'Fractional minted bar', CAST(222.00 AS decimal(18,2)), 180 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-009', N'Bullion 1/2oz Gold Coin', N'Half ounce coin', CAST(1355.00 AS decimal(18,2)), 90 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-010', N'Bullion 1/4oz Gold Coin', N'Quarter ounce coin', CAST(694.00 AS decimal(18,2)), 120 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-011', N'Bullion Silver 1oz Coin', N'Investment silver coin', CAST(38.00 AS decimal(18,2)), 500 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-012', N'Bullion Silver 10oz Bar', N'Fine silver bar', CAST(344.00 AS decimal(18,2)), 200 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-013', N'Bullion 22K Bracelet', N'Gold jewelry investment grade', CAST(985.00 AS decimal(18,2)), 50 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-014', N'Bullion 22K Necklace', N'Premium necklace', CAST(1495.00 AS decimal(18,2)), 40 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-015', N'Bullion Gram Saver Pack', N'10x1g package', CAST(909.00 AS decimal(18,2)), 70 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-016', N'Bullion Wedding Set', N'Gold ceremonial set', CAST(2206.00 AS decimal(18,2)), 25 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-017', N'Bullion Kids Gold Coin', N'Special edition coin', CAST(182.00 AS decimal(18,2)), 180 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-018', N'Bullion Collector Coin 2026', N'Limited series', CAST(322.00 AS decimal(18,2)), 100 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-019', N'Bullion Gift Card 500', N'Store value card', CAST(500.00 AS decimal(18,2)), 999 UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-020', N'Bullion Gift Card 1000', N'Store value card', CAST(1000.00 AS decimal(18,2)), 999
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
            T.[Category] = CASE
                WHEN S.[Name] LIKE N'%Gift Card%' THEN 10
                WHEN S.[Name] LIKE N'%Silver%' AND S.[Name] LIKE N'%Coin%' THEN 6
                WHEN S.[Name] LIKE N'%Coin%' THEN 5
                WHEN (S.[Name] LIKE N'%Bracelet%' OR S.[Name] LIKE N'%Necklace%' OR S.[Name] LIKE N'%Wedding Set%') AND S.[Name] LIKE N'%Silver%' THEN 9
                WHEN S.[Name] LIKE N'%Bracelet%' OR S.[Name] LIKE N'%Necklace%' OR S.[Name] LIKE N'%Wedding Set%' THEN 8
                WHEN S.[Name] LIKE N'%Silver%' THEN 2
                WHEN S.[Name] LIKE N'%Bar%' THEN 3
                ELSE 1
            END,
            T.[ImageUrl] = CASE
                WHEN S.[Name] LIKE N'%Silver%' THEN N'/images/products/silver.png'
                WHEN S.[Name] LIKE N'%Coin%' THEN N'/images/products/gold-coin.png'
                WHEN S.[Name] LIKE N'%Bracelet%' OR S.[Name] LIKE N'%Necklace%' OR S.[Name] LIKE N'%Wedding Set%' THEN N'/images/products/jewelry.png'
                WHEN S.[Name] LIKE N'%Gift Card%' THEN N'/images/products/gift-card.png'
                ELSE N'/images/products/gold-bar.png'
            END,
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[Name],[Sku],[Description],[Price],[AvailableStock],[Category],[ImageUrl],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (
            S.[SellerId],
            S.[Name],
            S.[Sku],
            S.[Description],
            S.[Price],
            S.[AvailableStock],
            CASE
                WHEN S.[Name] LIKE N'%Gift Card%' THEN 10
                WHEN S.[Name] LIKE N'%Silver%' AND S.[Name] LIKE N'%Coin%' THEN 6
                WHEN S.[Name] LIKE N'%Coin%' THEN 5
                WHEN (S.[Name] LIKE N'%Bracelet%' OR S.[Name] LIKE N'%Necklace%' OR S.[Name] LIKE N'%Wedding Set%') AND S.[Name] LIKE N'%Silver%' THEN 9
                WHEN S.[Name] LIKE N'%Bracelet%' OR S.[Name] LIKE N'%Necklace%' OR S.[Name] LIKE N'%Wedding Set%' THEN 8
                WHEN S.[Name] LIKE N'%Silver%' THEN 2
                WHEN S.[Name] LIKE N'%Bar%' THEN 3
                ELSE 1
            END,
            CASE
                WHEN S.[Name] LIKE N'%Silver%' THEN N'/images/products/silver.png'
                WHEN S.[Name] LIKE N'%Coin%' THEN N'/images/products/gold-coin.png'
                WHEN S.[Name] LIKE N'%Bracelet%' OR S.[Name] LIKE N'%Necklace%' OR S.[Name] LIKE N'%Wedding Set%' THEN N'/images/products/jewelry.png'
                WHEN S.[Name] LIKE N'%Gift Card%' THEN N'/images/products/gift-card.png'
                ELSE N'/images/products/gold-bar.png'
            END,
            1,
            @Now,
            NULL
        );

    ------------------------------------------------------------
    -- 6) Mobile app configuration
    ------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [MobileAppConfigurations] WHERE [ConfigKey] = N'home.carousel.images')
    BEGIN
        INSERT INTO [MobileAppConfigurations] ([ConfigKey], [JsonValue], [IsEnabled], [Description], [CreatedAtUtc], [UpdatedAtUtc])
        VALUES
        (
            N'home.carousel.images',
            N'["/images/banners/banner-1.png","/images/banners/banner-2.png","/images/banners/banner-3.png"]',
            1,
            N'Home carousel images stored on local server',
            @Now,
            NULL
        );
    END

    ------------------------------------------------------------
    -- 7) Audit logs
    ------------------------------------------------------------
    INSERT INTO [AuditLogs] ([UserId],[Action],[EntityName],[EntityId],[Details],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (NULL, N'SEED_RUN',  N'System',             NULL, N'Executed merged seed script successfully.', @Now, NULL),
        (NULL, N'SEED_NOTE', N'System',             NULL, N'Users seeded with empty cart/wallet-assets/transactions baseline.', @Now, NULL),
        (NULL, N'LOGIN',     N'Auth',               NULL, N'Template action: write this at login.', @Now, NULL),
        (NULL, N'LOGOUT',    N'Auth',               NULL, N'Template action: write this at logout.', @Now, NULL),
        (NULL, N'CART_ADD',  N'CartItem',           NULL, N'Template action: write this when product added to cart.', @Now, NULL),
        (NULL, N'ORDER_BUY', N'Order',              NULL, N'Template action: write this when buy/checkout happens.', @Now, NULL),
        (NULL, N'TX_CREATE', N'TransactionHistory', NULL, N'Template action: write this when any transaction is created.', @Now, NULL);

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;
END CATCH;

------------------------------------------------------------
-- 8) Verification
------------------------------------------------------------
SELECT COUNT(*) AS SellerCount
FROM [Sellers];

SELECT COUNT(*) AS UserCount
FROM [Users]
WHERE [Email] LIKE N'%@example.com'
   OR [Email] = N'investor@goldwallet.com';

SELECT COUNT(*) AS ProductCount
FROM [Products]
WHERE [Sku] LIKE N'IMSEEH-%'
   OR [Sku] LIKE N'GOLDPAL-%'
   OR [Sku] LIKE N'BULLION-%';

SELECT [Id], [FullName], [Email], [Role], [SellerId], [IsActive]
FROM [Users]
WHERE [Email] = N'investor@goldwallet.com';

SELECT TOP 20 [Id], [Name], [Sku], [Category], [ImageUrl]
FROM [Products]
ORDER BY [Id] DESC;
