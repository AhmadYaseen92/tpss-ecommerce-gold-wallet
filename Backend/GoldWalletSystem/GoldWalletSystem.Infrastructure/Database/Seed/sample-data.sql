/*
Sample seed data for a fresh GoldWallet installation.
Keeps data small, clear, and safe to run multiple times.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @Now datetime2 = SYSUTCDATETIME();

    -- Ensure required tables exist.
    IF OBJECT_ID(N'[Sellers]') IS NULL OR OBJECT_ID(N'[Users]') IS NULL OR OBJECT_ID(N'[Products]') IS NULL
        THROW 50000, 'Required tables are missing. Run migrations first.', 1;

    -- 1) Sellers.
    MERGE [Sellers] AS T
    USING (
        VALUES
            (
                N'Imseeh',
                N'IMSEEH',
                N'imseeh.seller@example.com',
                N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000',
                N'contact@imseeh.com',
                N'+962700000001',
                N'Jordan',
                N'Amman',
                N'Wasfi Al Tal St',
                N'12A',
                N'11181',
                N'Imseeh Precious Metals LLC',
                N'TL-IMSEEH-001',
                N'VAT-IMSEEH-001',
                N'9876543210',
                N'Arab Bank',
                N'JO94CBJO0010000000000131000302',
                N'Imseeh Trading LLC',
                N'/kyc/imseeh/national-id-front.png',
                N'/kyc/imseeh/national-id-back.png',
                N'/kyc/imseeh/trade-license.pdf'
            ),
            (
                N'Gold Palace',
                N'GOLDPAL',
                N'goldpal.seller@example.com',
                N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000',
                N'contact@goldpalace.com',
                N'+15550000002',
                N'United States',
                N'Dallas',
                N'Elm Street',
                N'401',
                N'75201',
                N'Gold Palace Inc.',
                N'TL-GOLDPAL-002',
                N'VAT-GOLDPAL-002',
                N'1234509876',
                N'Bank of America',
                N'US64SVBKUS6S3300958879',
                N'Gold Palace Inc.',
                N'/kyc/goldpal/national-id-front.png',
                N'/kyc/goldpal/national-id-back.png',
                N'/kyc/goldpal/trade-license.pdf'
            ),
            (
                N'Bullion House',
                N'BULLION',
                N'bullion.seller@example.com',
                N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000',
                N'contact@bullionhouse.com',
                N'+15550000003',
                N'United States',
                N'Miami',
                N'Biscayne Blvd',
                N'908',
                N'33132',
                N'Bullion House LLC',
                N'TL-BULLION-003',
                N'VAT-BULLION-003',
                N'5566778899',
                N'Wells Fargo',
                N'US37WFBI00000000001234123412',
                N'Bullion House LLC',
                N'/kyc/bullion/national-id-front.png',
                N'/kyc/bullion/national-id-back.png',
                N'/kyc/bullion/trade-license.pdf'
            )
    ) AS S(
        [Name],[Code],[Email],[PasswordHash],[ContactEmail],[ContactPhone],
        [Country],[City],[Street],[BuildingNumber],[PostalCode],
        [CompanyName],[TradeLicenseNumber],[VatNumber],[NationalIdNumber],
        [BankName],[IBAN],[AccountHolderName],
        [NationalIdFrontPath],[NationalIdBackPath],[TradeLicensePath]
    )
    ON T.[Code] = S.[Code]
    WHEN MATCHED THEN
        UPDATE SET
            T.[Name] = S.[Name],
            T.[Email] = S.[Email],
            T.[PasswordHash] = S.[PasswordHash],
            T.[ContactEmail] = S.[ContactEmail],
            T.[ContactPhone] = S.[ContactPhone],
            T.[Country] = S.[Country],
            T.[City] = S.[City],
            T.[Street] = S.[Street],
            T.[BuildingNumber] = S.[BuildingNumber],
            T.[PostalCode] = S.[PostalCode],
            T.[CompanyName] = S.[CompanyName],
            T.[TradeLicenseNumber] = S.[TradeLicenseNumber],
            T.[VatNumber] = S.[VatNumber],
            T.[NationalIdNumber] = S.[NationalIdNumber],
            T.[BankName] = S.[BankName],
            T.[IBAN] = S.[IBAN],
            T.[AccountHolderName] = S.[AccountHolderName],
            T.[NationalIdFrontPath] = S.[NationalIdFrontPath],
            T.[NationalIdBackPath] = S.[NationalIdBackPath],
            T.[TradeLicensePath] = S.[TradeLicensePath],
            T.[KycStatus] = 1,
            T.[ReviewedAtUtc] = @Now,
            T.[ReviewNotes] = N'Seeded as approved seller',
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT (
            [Name],[Code],[Email],[PasswordHash],[ContactEmail],[ContactPhone],[IsActive],
            [Country],[City],[Street],[BuildingNumber],[PostalCode],
            [CompanyName],[TradeLicenseNumber],[VatNumber],[NationalIdNumber],
            [BankName],[IBAN],[AccountHolderName],
            [NationalIdFrontPath],[NationalIdBackPath],[TradeLicensePath],
            [KycStatus],[ReviewedAtUtc],[ReviewNotes],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES (
            S.[Name],S.[Code],S.[Email],S.[PasswordHash],S.[ContactEmail],S.[ContactPhone],1,
            S.[Country],S.[City],S.[Street],S.[BuildingNumber],S.[PostalCode],
            S.[CompanyName],S.[TradeLicenseNumber],S.[VatNumber],S.[NationalIdNumber],
            S.[BankName],S.[IBAN],S.[AccountHolderName],
            S.[NationalIdFrontPath],S.[NationalIdBackPath],S.[TradeLicensePath],
            1,@Now,N'Seeded as approved seller',@Now,NULL
        );

    DECLARE @SellerImseeh int  = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [Code] = N'IMSEEH');
    DECLARE @SellerGoldPal int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [Code] = N'GOLDPAL');
    DECLARE @SellerBullion int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [Code] = N'BULLION');

    -- 2) Users (including investor@goldwallet.com).
    DECLARE @Users TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        PasswordHash nvarchar(500),
        Role nvarchar(50),
        SellerId int NULL,
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @Users (FullName, Email, PasswordHash, Role, SellerId, PhoneNumber)
    VALUES
        (N'Imseeh Seller',        N'imseeh.seller@example.com',      N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller',   @SellerImseeh,  N'+962700000001'),
        (N'GoldPal Seller',       N'goldpal.seller@example.com',     N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller',   @SellerGoldPal, N'+15550000002'),
        (N'Bullion Seller',       N'bullion.seller@example.com',     N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller',   @SellerBullion, N'+15550000003'),
        (N'Imseeh Admin',         N'imseeh.admin@example.com',      N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', NULL,            N'+15551010001'),
        (N'GoldPal Admin',        N'goldpal.admin@example.com',     N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', NULL,            N'+15551020001'),
        (N'Bullion Admin',        N'bullion.admin@example.com',     N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Investor', NULL,            N'+15551030001'),
        (N'Gold Wallet Investor', N'investor@goldwallet.com',       N'NN53R1Ggd5QH71EKW6wALA==.UbTyu0VUnNi27SE8JQbIjY5d8gs3jgo+SiUsNtLtt8I=.100000', N'Investor', NULL,            N'+962790000999'),
        (N'Imseeh Investor 1',    N'imseeh.investor1@example.com',  N'E4AJcY7MeKmJOoaxRXzfXg==.Yd4IWfYBZUqs83ho+2xLhTrveNqLL+Vojtvn3jjsMN8=.100000', N'Investor', NULL,            N'+15551010002'),
        (N'GoldPal Investor 1',   N'goldpal.investor1@example.com', N'E4AJcY7MeKmJOoaxRXzfXg==.Yd4IWfYBZUqs83ho+2xLhTrveNqLL+Vojtvn3jjsMN8=.100000', N'Investor', NULL,            N'+15551020002'),
        (N'Bullion Investor 1',   N'bullion.investor1@example.com', N'E4AJcY7MeKmJOoaxRXzfXg==.Yd4IWfYBZUqs83ho+2xLhTrveNqLL+Vojtvn3jjsMN8=.100000', N'Investor', NULL,            N'+15551030002');

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

    -- 3) Profiles, wallets, and carts.
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

    -- 4) Keep startup state clean for seeded users.
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

    DELETE N
    FROM [AppNotifications] N
    INNER JOIN [Users] U ON U.[Id] = N.[UserId]
    WHERE U.[Email] IN (SELECT [Email] FROM @Users);

    DELETE I
    FROM [Invoices] I
    WHERE I.[InvestorUserId] IN (
        SELECT [Id] FROM [Users] WHERE [Email] IN (SELECT [Email] FROM @Users)
    );

    -- 4.b) Seed transaction histories + notifications + invoice records for web-admin endpoints.
    DECLARE @InvestorMain int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'investor@goldwallet.com');
    DECLARE @InvestorImseeh int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'imseeh.investor1@example.com');
    DECLARE @InvestorGoldPal int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'goldpal.investor1@example.com');
    DECLARE @SellerUserImseeh int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'imseeh.seller@example.com');

    IF COL_LENGTH('TransactionHistories', 'Status') IS NOT NULL
    BEGIN
        INSERT INTO [TransactionHistories] (
            [UserId],[SellerId],[TransactionType],[Status],[Category],[Quantity],
            [UnitPrice],[Weight],[Unit],[Purity],[Amount],[Currency],[Notes],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@InvestorMain, @SellerImseeh, N'sell', N'pending', N'Gold', 1, 740, 5.000, N'gram', 24, 740, N'USD', N'execution_mode=locked_30_seconds|wallet_asset_id=1', DATEADD(HOUR, -6, @Now), NULL),
            (@InvestorMain, @SellerImseeh, N'pickup', N'pending', N'Coins', 1, 2685, 31.104, N'gram', 24, 2685, N'USD', N'pickup_schedule=Mon, 20 Apr 2026 10:00 AM|wallet_asset_id=2', DATEADD(HOUR, -5, @Now), NULL),
            (@InvestorImseeh, @SellerImseeh, N'transfer', N'approved', N'Gold', 1, 730, 5.000, N'gram', 24, 730, N'USD', N'execution_mode=live_price|wallet_asset_id=3|recipient_investor_user_id=9|recipient_investor_name=GoldPal Investor 1', DATEADD(DAY, -2, @Now), NULL),
            (@InvestorGoldPal, @SellerImseeh, N'transfer', N'approved', N'Gold', 1, 730, 5.000, N'gram', 24, 730, N'USD', N'direction=received|from_investor_user_id=8|from_investor_name=Imseeh Investor 1|wallet_asset_id=2', DATEADD(DAY, -2, DATEADD(MINUTE, 1, @Now)), NULL),
            (@InvestorImseeh, @SellerImseeh, N'gift', N'approved', N'Gold', 1, 725, 5.000, N'gram', 24, 725, N'USD', N'execution_mode=live_price|wallet_asset_id=3|recipient_investor_user_id=9|recipient_investor_name=GoldPal Investor 1', DATEADD(DAY, -1, @Now), NULL),
            (@InvestorGoldPal, @SellerImseeh, N'gift', N'approved', N'Gold', 1, 725, 5.000, N'gram', 24, 725, N'USD', N'direction=received|from_investor_user_id=8|from_investor_name=Imseeh Investor 1|wallet_asset_id=2', DATEADD(DAY, -1, DATEADD(MINUTE, 1, @Now)), NULL);
    END
    ELSE
    BEGIN
        EXEC sp_executesql
            N'
            INSERT INTO [TransactionHistories] ([UserId],[TransactionType],[Amount],[Currency],[Reference],[CreatedAtUtc],[UpdatedAtUtc])
            VALUES
                (@InvestorMain, N''withdrawal'', 1200, N''USD'', N''channel=webadmin|status=pending'', DATEADD(DAY, -1, @Now), NULL),
                (@InvestorImseeh, N''sell'', 740, N''USD'', N''channel=webadmin|status=approved'', DATEADD(DAY, -2, @Now), NULL),
                (@InvestorGoldPal, N''transfer'', 350, N''USD'', N''channel=webadmin|status=rejected'', DATEADD(DAY, -3, @Now), NULL);
            ',
            N'@InvestorMain int, @InvestorImseeh int, @InvestorGoldPal int, @Now datetime2',
            @InvestorMain = @InvestorMain,
            @InvestorImseeh = @InvestorImseeh,
            @InvestorGoldPal = @InvestorGoldPal,
            @Now = @Now;
    END

    INSERT INTO [AppNotifications] ([UserId],[Title],[Body],[IsRead],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (@InvestorMain, N'KYC Pending', N'A new seller registration is pending approval.', 0, DATEADD(HOUR, -4, @Now), NULL),
        (@InvestorImseeh, N'Invoice Issued', N'Your latest trade invoice is available.', 0, DATEADD(HOUR, -8, @Now), NULL),
        (@InvestorGoldPal, N'Request Updated', N'Your latest request status has been updated.', 1, DATEADD(HOUR, -12, @Now), NULL);

    INSERT INTO [Invoices] (
        [InvestorUserId],[SellerUserId],[InvoiceNumber],[InvoiceCategory],[SourceChannel],
        [SubTotal],[TaxAmount],[TotalAmount],[InvoiceQrCode],[IssuedOnUtc],[Status],[CreatedAtUtc],[UpdatedAtUtc]
    )
    VALUES
        (@InvestorMain, @SellerUserImseeh, N'INV-SEED-0001', N'Trade', N'WebAdmin', 980, 0, 980, N'', DATEADD(DAY, -1, @Now), N'sent', @Now, NULL),
        (@InvestorImseeh, @SellerUserImseeh, N'INV-SEED-0002', N'Trade', N'WebAdmin', 1430, 0, 1430, N'', DATEADD(DAY, -2, @Now), N'paid', @Now, NULL);

    -- 5) Core products (starter catalog) with REQUIRED weight fields.
    -- Covers all categories except SpotMr:
    --   Gold (1), Silver (2), Diamond (3), Jewelry (4), Coins (5)
    ;WITH SeedProducts AS (
        SELECT @SellerImseeh AS SellerId, N'IMSEEH-PRD-001' AS Sku, N'Imseeh 5g Gold Bar' AS Name, N'24K minted bar - 5 grams' AS [Description], CAST(430.00 AS decimal(18,2)) AS Price, 100 AS AvailableStock, CAST(5.000 AS decimal(18,3)) AS WeightValue, 1 AS WeightUnit, 1 AS Category, 1 AS MaterialType, 3 AS FormType, N'/images/products/gold-bar.png' AS ImageUrl UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-002', N'Imseeh Silver 1oz Bar', N'Investment silver bar', CAST(36.00 AS decimal(18,2)), 300, CAST(1.000 AS decimal(18,3)), 3, 2, 2, 3, N'/images/products/silver.png' UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-003', N'Imseeh Diamond Ring', N'Certified diamond ring 18K', CAST(920.00 AS decimal(18,2)), 45, CAST(8.000 AS decimal(18,3)), 1, 3, 3, 1, N'/images/products/diamond.png' UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-004', N'Imseeh Gold Necklace', N'22K jewelry necklace', CAST(1450.00 AS decimal(18,2)), 35, CAST(24.000 AS decimal(18,3)), 1, 4, 1, 1, N'/images/products/jewelry.png' UNION ALL
        SELECT @SellerImseeh, N'IMSEEH-PRD-005', N'Imseeh 1oz Gold Coin', N'Fine gold investment coin', CAST(2675.00 AS decimal(18,2)), 60, CAST(1.000 AS decimal(18,3)), 3, 5, 1, 2, N'/images/products/gold-coin.png' UNION ALL

        SELECT @SellerGoldPal, N'GOLDPAL-PRD-001', N'GoldPal 5g Gold Bar', N'24K minted bar - 5 grams', CAST(432.00 AS decimal(18,2)), 100, CAST(5.000 AS decimal(18,3)), 1, 1, 1, 3, N'/images/products/gold-bar.png' UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-002', N'GoldPal Silver 1oz Bar', N'Investment silver bar', CAST(37.00 AS decimal(18,2)), 300, CAST(1.000 AS decimal(18,3)), 3, 2, 2, 3, N'/images/products/silver.png' UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-003', N'GoldPal Diamond Stud', N'Certified diamond stud earring', CAST(880.00 AS decimal(18,2)), 50, CAST(4.000 AS decimal(18,3)), 1, 3, 3, 1, N'/images/products/diamond.png' UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-004', N'GoldPal Gold Bracelet', N'21K jewelry bracelet', CAST(1390.00 AS decimal(18,2)), 40, CAST(20.000 AS decimal(18,3)), 1, 4, 1, 1, N'/images/products/jewelry.png' UNION ALL
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-005', N'GoldPal 1oz Gold Coin', N'Fine gold investment coin', CAST(2678.00 AS decimal(18,2)), 60, CAST(1.000 AS decimal(18,3)), 3, 5, 1, 2, N'/images/products/gold-coin.png' UNION ALL

        SELECT @SellerBullion, N'BULLION-PRD-001', N'Bullion 5g Gold Bar', N'24K minted bar - 5 grams', CAST(433.00 AS decimal(18,2)), 100, CAST(5.000 AS decimal(18,3)), 1, 1, 1, 3, N'/images/products/gold-bar.png' UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-002', N'Bullion Silver 1oz Bar', N'Investment silver bar', CAST(38.00 AS decimal(18,2)), 300, CAST(1.000 AS decimal(18,3)), 3, 2, 2, 3, N'/images/products/silver.png' UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-003', N'Bullion Diamond Pendant', N'Certified diamond pendant', CAST(960.00 AS decimal(18,2)), 42, CAST(6.000 AS decimal(18,3)), 1, 3, 3, 1, N'/images/products/diamond.png' UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-004', N'Bullion Gold Ring', N'22K jewelry ring', CAST(1210.00 AS decimal(18,2)), 38, CAST(10.000 AS decimal(18,3)), 1, 4, 1, 1, N'/images/products/jewelry.png' UNION ALL
        SELECT @SellerBullion, N'BULLION-PRD-005', N'Bullion 1oz Gold Coin', N'Fine gold investment coin', CAST(2680.00 AS decimal(18,2)), 60, CAST(1.000 AS decimal(18,3)), 3, 5, 1, 2, N'/images/products/gold-coin.png'
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
            T.[WeightValue] = S.[WeightValue],
            T.[WeightUnit] = S.[WeightUnit],
            T.[MaterialType] = S.[MaterialType],
            T.[FormType] = S.[FormType],
            T.[PricingMode] = 1,
            T.[PurityKarat] = CASE WHEN S.[Name] LIKE N'%22K%' THEN 2 ELSE 1 END,
            T.[PurityFactor] = CASE WHEN S.[Category] = 2 THEN 0.999 ELSE 1.0 END,
            T.[BaseMarketPrice] = S.[Price],
            T.[ManualSellPrice] = S.[Price],
            T.[DeliveryFee] = 5,
            T.[StorageFee] = 2,
            T.[ServiceCharge] = 1,
            T.[OfferPercent] = 0,
            T.[OfferNewPrice] = 0,
            T.[OfferType] = 0,
            T.[Category] = S.[Category],
            T.[ImageUrl] = S.[ImageUrl],
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT (
            [SellerId],
            [Name],
            [Sku],
            [Description],
            [Price],
            [AvailableStock],
            [WeightValue],
            [WeightUnit],
            [MaterialType],
            [FormType],
            [PricingMode],
            [PurityKarat],
            [PurityFactor],
            [BaseMarketPrice],
            [ManualSellPrice],
            [DeliveryFee],
            [StorageFee],
            [ServiceCharge],
            [OfferPercent],
            [OfferNewPrice],
            [OfferType],
            [Category],
            [ImageUrl],
            [IsActive],
            [CreatedAtUtc],
            [UpdatedAtUtc]
        )
        VALUES (
            S.[SellerId],
            S.[Name],
            S.[Sku],
            S.[Description],
            S.[Price],
            S.[AvailableStock],
            S.[WeightValue],
            S.[WeightUnit],
            S.[MaterialType],
            S.[FormType],
            1,
            CASE WHEN S.[Name] LIKE N'%22K%' THEN 2 ELSE 1 END,
            CASE WHEN S.[Category] = 2 THEN 0.999 ELSE 1.0 END,
            S.[Price],
            S.[Price],
            5,
            2,
            1,
            0,
            0,
            0,
            S.[Category],
            S.[ImageUrl],
            1,
            @Now,
            NULL
        );

    -- 5.b) Seed wallet assets and cart items for category analytics.
    DECLARE @WalletInvestorMain int = (SELECT TOP 1 [Id] FROM [Wallets] WHERE [UserId] = @InvestorMain);
    DECLARE @WalletInvestorImseeh int = (SELECT TOP 1 [Id] FROM [Wallets] WHERE [UserId] = @InvestorImseeh);
    DECLARE @CartInvestorMain int = (SELECT TOP 1 [Id] FROM [Carts] WHERE [UserId] = @InvestorMain);
    DECLARE @CartInvestorGoldPal int = (SELECT TOP 1 [Id] FROM [Carts] WHERE [UserId] = @InvestorGoldPal);

    DECLARE @ProductImseehGoldBar int = (SELECT TOP 1 [Id] FROM [Products] WHERE [Sku] = N'IMSEEH-PRD-001');
    DECLARE @ProductImseehGoldCoin int = (SELECT TOP 1 [Id] FROM [Products] WHERE [Sku] = N'IMSEEH-PRD-005');
    DECLARE @ProductGoldPalSilver int = (SELECT TOP 1 [Id] FROM [Products] WHERE [Sku] = N'GOLDPAL-PRD-002');

    IF COL_LENGTH('WalletAssets', 'Category') IS NOT NULL AND COL_LENGTH('WalletAssets', 'SellerId') IS NOT NULL
    BEGIN
        INSERT INTO [WalletAssets] (
            [WalletId],[AssetType],[Category],[SellerId],[Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[SellerName],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@WalletInvestorMain, 1, 1, @SellerImseeh, 5.000, N'gram', 24.00, 1, 430.00, 435.00, N'Imseeh', DATEADD(DAY, -2, @Now), NULL),
            (@WalletInvestorMain, 1, 5, @SellerImseeh, 31.104, N'gram', 24.00, 2, 2675.00, 2685.00, N'Imseeh', DATEADD(DAY, -1, @Now), NULL),
            (@WalletInvestorImseeh, 2, 2, @SellerGoldPal, 31.104, N'gram', 99.99, 3, 37.00, 38.00, N'Gold Palace', DATEADD(DAY, -1, @Now), NULL);
    END
    ELSE
    BEGIN
        INSERT INTO [WalletAssets] (
            [WalletId],[AssetType],[Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[SellerName],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@WalletInvestorMain, 1, 5.000, N'gram', 24.00, 1, 430.00, 435.00, N'Imseeh', DATEADD(DAY, -2, @Now), NULL),
            (@WalletInvestorMain, 1, 31.104, N'gram', 24.00, 2, 2675.00, 2685.00, N'Imseeh', DATEADD(DAY, -1, @Now), NULL),
            (@WalletInvestorImseeh, 2, 31.104, N'gram', 99.99, 3, 37.00, 38.00, N'Gold Palace', DATEADD(DAY, -1, @Now), NULL);
    END

    IF COL_LENGTH('CartItems', 'Category') IS NOT NULL AND COL_LENGTH('CartItems', 'SellerId') IS NOT NULL
    BEGIN
        INSERT INTO [CartItems] (
            [CartId],[ProductId],[SellerId],[Category],[Quantity],[UnitPrice],[LineTotal],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@CartInvestorMain, @ProductImseehGoldBar, @SellerImseeh, 1, 2, 430.00, 860.00, @Now, NULL),
            (@CartInvestorMain, @ProductImseehGoldCoin, @SellerImseeh, 5, 1, 2675.00, 2675.00, @Now, NULL),
            (@CartInvestorGoldPal, @ProductGoldPalSilver, @SellerGoldPal, 2, 4, 37.00, 148.00, @Now, NULL);
    END
    ELSE IF COL_LENGTH('CartItems', 'SellerId') IS NOT NULL
    BEGIN
        INSERT INTO [CartItems] (
            [CartId],[ProductId],[SellerId],[Quantity],[UnitPrice],[LineTotal],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@CartInvestorMain, @ProductImseehGoldBar, @SellerImseeh, 2, 430.00, 860.00, @Now, NULL),
            (@CartInvestorMain, @ProductImseehGoldCoin, @SellerImseeh, 1, 2675.00, 2675.00, @Now, NULL),
            (@CartInvestorGoldPal, @ProductGoldPalSilver, @SellerGoldPal, 4, 37.00, 148.00, @Now, NULL);
    END
    ELSE
    BEGIN
        INSERT INTO [CartItems] (
            [CartId],[ProductId],[Quantity],[UnitPrice],[LineTotal],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@CartInvestorMain, @ProductImseehGoldBar, 2, 430.00, 860.00, @Now, NULL),
            (@CartInvestorMain, @ProductImseehGoldCoin, 1, 2675.00, 2675.00, @Now, NULL),
            (@CartInvestorGoldPal, @ProductGoldPalSilver, 4, 37.00, 148.00, @Now, NULL);
    END

    -- 6) Home carousel config.
    MERGE [MobileAppConfigurations] AS T
    USING (
        VALUES
        (
            N'home.carousel.images',
            N'["/images/banners/banner-1.png","/images/banners/banner-2.png","/images/banners/banner-3.png"]',
            CAST(1 AS bit),
            N'Home carousel images stored on local server'
        ),
        (
            N'webadmin.fees',
            N'{"deliveryFee":12,"storageFee":4,"serviceChargePercent":2.5}',
            CAST(1 AS bit),
            N'Web admin fee configuration'
        ),
        (
            N'wallet.sell.execution',
            N'{"mode":"locked_30_seconds","lockSeconds":30}',
            CAST(1 AS bit),
            N'Wallet sell execution behavior for mobile and web'
        ),
        (
            N'mobile.release-config',
            N'{"isIndividualSellerRelease":false,"individualSellerName":"Imseeh","allSellersLabel":"All Sellers","showWeightInGrams":true}',
            CAST(1 AS bit),
            N'Mobile release configuration synced with backend defaults'
        )
    ) AS S([ConfigKey],[JsonValue],[IsEnabled],[Description])
    ON T.[ConfigKey] = S.[ConfigKey]
    WHEN MATCHED THEN
        UPDATE SET
            T.[JsonValue] = S.[JsonValue],
            T.[IsEnabled] = S.[IsEnabled],
            T.[Description] = S.[Description],
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([ConfigKey],[JsonValue],[IsEnabled],[Description],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[ConfigKey],S.[JsonValue],S.[IsEnabled],S.[Description],@Now,NULL);

    -- 7) Seed audit marker.
    INSERT INTO [AuditLogs] ([UserId],[Action],[EntityName],[EntityId],[Details],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES (NULL, N'SEED_RUN', N'System', NULL, N'Fresh sample seed applied.', @Now, NULL);

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;
END CATCH;

-- Quick checks.
SELECT COUNT(*) AS SellerCount FROM [Sellers];

SELECT COUNT(*) AS SeedUserCount
FROM [Users]
WHERE [Email] IN (
    N'imseeh.seller@example.com',
    N'goldpal.seller@example.com',
    N'bullion.seller@example.com',
    N'imseeh.admin@example.com',
    N'goldpal.admin@example.com',
    N'bullion.admin@example.com',
    N'investor@goldwallet.com',
    N'imseeh.investor1@example.com',
    N'goldpal.investor1@example.com',
    N'bullion.investor1@example.com'
);

SELECT COUNT(*) AS SeedProductCount
FROM [Products]
WHERE [Sku] LIKE N'IMSEEH-PRD-%'
   OR [Sku] LIKE N'GOLDPAL-PRD-%'
   OR [Sku] LIKE N'BULLION-PRD-%';
