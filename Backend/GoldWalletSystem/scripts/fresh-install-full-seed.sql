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
        (N'Gold Wallet Admin', N'admin@goldwallet.com', N'PPJjw8OG+mRgfuQq0PwjBg==.I6aFJ1YwnTWLF8rajLp/30yOAXuGukxV5lx0zFoVuBo=.100000', N'Admin', N'+15551010001'),
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
            T.[AvailableStock] = S.[AvailableStock],
            T.[Category] = S.[Category],
            T.[MaterialType] = CASE WHEN S.[Category] IN (2,6) THEN 2 WHEN S.[Category] = 9 THEN 3 ELSE 1 END,
            T.[FormType] = CASE WHEN S.[Category] IN (8,9) THEN 1 WHEN S.[Category] IN (5,6) THEN 2 ELSE 3 END,
            T.[PricingMode] = 1,
            T.[PurityKarat] = 1,
            T.[PurityFactor] = 1.0,
            T.[WeightValue] = S.[WeightValue],
            T.[WeightUnit] = S.[WeightUnit],
            T.[BaseMarketPrice] = S.[Price],
            T.[ManualSellPrice] = S.[Price],
            T.[ImageUrl] = S.[ImageUrl],
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[Name],[Sku],[Description],[AvailableStock],[Category],[MaterialType],[FormType],[PricingMode],[PurityKarat],[PurityFactor],[WeightValue],[WeightUnit],[BaseMarketPrice],[ManualSellPrice],[OfferPercent],[OfferNewPrice],[OfferType],[IsHasOffer],[ImageUrl],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[Name],S.[Sku],S.[Description],S.[AvailableStock],S.[Category],CASE WHEN S.[Category] IN (2,6) THEN 2 WHEN S.[Category] = 9 THEN 3 ELSE 1 END,CASE WHEN S.[Category] IN (8,9) THEN 1 WHEN S.[Category] IN (5,6) THEN 2 ELSE 3 END,1,1,1.0,S.[WeightValue],S.[WeightUnit],S.[Price],S.[Price],0,0,0,0,S.[ImageUrl],1,@Now,NULL);

    ------------------------------------------------------------
    -- WalletAssets portfolio rows
    ------------------------------------------------------------
    INSERT INTO [WalletAssets] (
        [WalletId],[ProductName],[ProductSku],[ProductImageUrl],[MaterialType],[FormType],[WeightValue],[WeightUnit],[AssetType],[Category],
        [Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[AcquisitionSubTotalAmount],[AcquisitionFeesAmount],[AcquisitionDiscountAmount],[AcquisitionFinalAmount],
        [SellerName],[CreatedAtUtc],[UpdatedAtUtc]
    )
    SELECT
        W.[Id], N'Imseeh 5g Gold Bar', N'IMSEEH-PRD-001', N'/images/products/gold-bar.png', N'Gold', N'Bar', 100.000, N'gram', 1, 1,
        100.000, N'gram', 24.00, 1, 6200.00, 6400.00, 6200.00, 62.00, 0.00, 6262.00,
        N'Imseeh', @Now, NULL
    FROM [Wallets] W
    WHERE NOT EXISTS (SELECT 1 FROM [WalletAssets] A WHERE A.[WalletId] = W.[Id] AND A.[AssetType] = 1);

    INSERT INTO [WalletAssets] (
        [WalletId],[ProductName],[ProductSku],[ProductImageUrl],[MaterialType],[FormType],[WeightValue],[WeightUnit],[AssetType],[Category],
        [Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[AcquisitionSubTotalAmount],[AcquisitionFeesAmount],[AcquisitionDiscountAmount],[AcquisitionFinalAmount],
        [SellerName],[CreatedAtUtc],[UpdatedAtUtc]
    )
    SELECT
        W.[Id], N'Bullion Silver 10oz Bar', N'BULLION-PRD-003', N'/images/products/silver.png', N'Silver', N'Bar', 250.000, N'gram', 5, 2,
        250.000, N'gram', 99.90, 1, 220.00, 235.00, 220.00, 2.20, 0.00, 222.20,
        N'Bullion House', @Now, NULL
    FROM [Wallets] W
    WHERE NOT EXISTS (SELECT 1 FROM [WalletAssets] A WHERE A.[WalletId] = W.[Id] AND A.[AssetType] = 5);

    INSERT INTO [WalletAssets] (
        [WalletId],[ProductName],[ProductSku],[ProductImageUrl],[MaterialType],[FormType],[WeightValue],[WeightUnit],[AssetType],[Category],
        [Weight],[Unit],[Purity],[Quantity],[AverageBuyPrice],[CurrentMarketPrice],[AcquisitionSubTotalAmount],[AcquisitionFeesAmount],[AcquisitionDiscountAmount],[AcquisitionFinalAmount],
        [SellerName],[CreatedAtUtc],[UpdatedAtUtc]
    )
    SELECT
        W.[Id], N'GoldPal 22K Necklace', N'GOLDPAL-PRD-002', N'/images/products/jewelry.png', N'Gold', N'Necklace', 30.000, N'gram', 6, 4,
        30.000, N'gram', 18.00, 2, 1500.00, 1650.00, 3000.00, 30.00, 0.00, 3030.00,
        N'Gold Palace', @Now, NULL
    FROM [Wallets] W
    WHERE NOT EXISTS (SELECT 1 FROM [WalletAssets] A WHERE A.[WalletId] = W.[Id] AND A.[AssetType] = 6);

    ------------------------------------------------------------
    -- Mobile app config
    ------------------------------------------------------------
    MERGE [SystemConfigration] AS T
    USING (
        VALUES
            (N'MobileRelease_IsIndividualSeller', N'Mobile Release Is Individual Seller', N'Mobile release: show single seller mode', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileRelease_IndividualSellerName', N'Mobile Release Individual Seller Name', N'Mobile release seller name when single seller mode is enabled', 1, NULL, NULL, NULL, N'Imseeh', CAST(0 AS bit)),
            (N'MobileRelease_ShowWeightInGrams', N'Mobile Release Show Weight In Grams', N'Mobile release flag to show weight in grams', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileRelease_MarketWatchEnabled', N'Mobile Release Market Watch Enabled', N'Mobile release flag to enable Market Watch tab in Product screen', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileRelease_MyAccountSummaryEnabled', N'Mobile Release My Account Summary Enabled', N'Mobile release flag to show My Account Summary entry in top bar', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileSecurity_LoginByBiometric', N'Mobile Security Login By Biometric', N'Allow biometric quick unlock on mobile', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileSecurity_LoginByPin', N'Mobile Security Login By PIN', N'Allow PIN quick unlock on mobile', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_EnableWhatsapp', N'OTP Enable WhatsApp', N'Enable OTP delivery over WhatsApp channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_EnableEmail', N'OTP Enable Email', N'Enable OTP delivery over Email channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_ExpirySeconds', N'OTP Expiry Seconds', N'Number of seconds before OTP expires', 3, NULL, 300, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_ResendCooldownSeconds', N'OTP Resend Cooldown Seconds', N'Cooldown between OTP resend attempts', 3, NULL, 60, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_MaxResendCount', N'OTP Max Resend Count', N'Maximum resend attempts per OTP request', 3, NULL, 3, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_MaxVerificationAttempts', N'OTP Max Verification Attempts', N'Maximum verification attempts per OTP', 3, NULL, 5, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_RequiredActions', N'OTP Required Actions', N'Actions that require OTP verification', 1, NULL, NULL, NULL, N'registration,reset_password,checkout,sell,transfer,gift,pickup,add_bank_account,edit_bank_account,remove_bank_account,add_payment_method,edit_payment_method,remove_payment_method,change_email,change_password,change_mobile_number', CAST(0 AS bit)),
            (N'Otp_ChannelPriority', N'OTP Channel Priority', N'Preferred OTP channel priority list', 1, NULL, NULL, NULL, N'whatsapp,email', CAST(0 AS bit)),
            (N'WalletSell_Mode', N'Wallet Sell Mode', N'Wallet sell execution behavior for mobile and web', 1, NULL, NULL, NULL, N'locked_30_seconds', CAST(0 AS bit)),
            (N'WalletSell_LockSeconds', N'Wallet Sell Lock Seconds', N'Wallet sell lock duration in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit))
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

    ------------------------------------------------------------
    -- Fee-management tables
    ------------------------------------------------------------
    IF OBJECT_ID(N'[SellerProductFees]', N'U') IS NOT NULL
    BEGIN
        DELETE FROM [SellerProductFees] WHERE [FeeCode] = N'service_charge';
    END

    IF OBJECT_ID(N'[SystemFees]', N'U') IS NOT NULL
    BEGIN
        DELETE FROM [SystemFees] WHERE [FeeCode] = N'service_charge';
    END

    IF OBJECT_ID(N'[SystemFeeTypes]', N'U') IS NOT NULL
    BEGIN
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
    END

    IF OBJECT_ID(N'[AdminTransactionFees]', N'U') IS NOT NULL
    BEGIN
        MERGE [AdminTransactionFees] AS T
        USING (
            VALUES
            (N'service_fee', CAST(1 AS bit), N'percent', 1.25, NULL, CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit))
        ) AS S([FeeCode],[IsEnabled],[CalculationMode],[RatePercent],[FixedAmount],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift])
        ON T.[FeeCode] = S.[FeeCode]
        WHEN MATCHED THEN UPDATE SET
            T.[IsEnabled] = S.[IsEnabled],
            T.[CalculationMode] = S.[CalculationMode],
            T.[RatePercent] = S.[RatePercent],
            T.[FixedAmount] = S.[FixedAmount],
            T.[AppliesToBuy] = S.[AppliesToBuy],
            T.[AppliesToSell] = S.[AppliesToSell],
            T.[AppliesToPickup] = S.[AppliesToPickup],
            T.[AppliesToTransfer] = S.[AppliesToTransfer],
            T.[AppliesToGift] = S.[AppliesToGift],
            T.[UpdatedAtUtc] = @Now
        WHEN NOT MATCHED THEN
            INSERT ([FeeCode],[IsEnabled],[CalculationMode],[RatePercent],[FixedAmount],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift],[CreatedAtUtc],[UpdatedAtUtc])
            VALUES (S.[FeeCode],S.[IsEnabled],S.[CalculationMode],S.[RatePercent],S.[FixedAmount],S.[AppliesToBuy],S.[AppliesToSell],S.[AppliesToPickup],S.[AppliesToTransfer],S.[AppliesToGift],@Now,NULL);
    END

    IF OBJECT_ID(N'[SellerProductFees]', N'U') IS NOT NULL
    BEGIN
        MERGE [SellerProductFees] AS T
        USING (
            SELECT P.[SellerId] AS SellerId, P.[Id] AS ProductId, N'commission_per_transaction' AS FeeCode, CAST(1 AS bit) AS IsEnabled, N'percent_with_minimum' AS CalculationMode, CAST(1.50 AS decimal(18,6)) AS RatePercent, CAST(5.00 AS decimal(18,2)) AS MinimumAmount, NULL AS FlatAmount, NULL AS PremiumDiscountType, NULL AS ValuePerUnit, NULL AS FeePercent, NULL AS GracePeriodDays, NULL AS FixedAmount, NULL AS FeePerUnit, CAST(0 AS bit) AS IsOverride
            FROM [Products] P
            WHERE P.[SellerId] IN (@SellerImseeh, @SellerGoldPal, @SellerBullion)
            UNION ALL
            SELECT P.[SellerId], P.[Id], N'delivery_fee', CAST(1 AS bit), N'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(12.00 AS decimal(18,2)), NULL, CAST(0 AS bit)
            FROM [Products] P
            WHERE P.[SellerId] IN (@SellerImseeh, @SellerGoldPal, @SellerBullion)
        ) AS S
        ON T.[SellerId] = S.[SellerId] AND T.[ProductId] = S.[ProductId] AND T.[FeeCode] = S.[FeeCode]
        WHEN MATCHED THEN UPDATE SET
            T.[IsEnabled] = S.[IsEnabled],
            T.[CalculationMode] = S.[CalculationMode],
            T.[RatePercent] = S.[RatePercent],
            T.[MinimumAmount] = S.[MinimumAmount],
            T.[FlatAmount] = S.[FlatAmount],
            T.[PremiumDiscountType] = S.[PremiumDiscountType],
            T.[ValuePerUnit] = S.[ValuePerUnit],
            T.[FeePercent] = S.[FeePercent],
            T.[GracePeriodDays] = S.[GracePeriodDays],
            T.[FixedAmount] = S.[FixedAmount],
            T.[FeePerUnit] = S.[FeePerUnit],
            T.[IsOverride] = S.[IsOverride],
            T.[UpdatedAtUtc] = @Now
        WHEN NOT MATCHED THEN
            INSERT ([SellerId],[ProductId],[FeeCode],[IsEnabled],[CalculationMode],[RatePercent],[MinimumAmount],[FlatAmount],[PremiumDiscountType],[ValuePerUnit],[FeePercent],[GracePeriodDays],[FixedAmount],[FeePerUnit],[IsOverride],[CreatedAtUtc],[UpdatedAtUtc])
            VALUES (S.[SellerId],S.[ProductId],S.[FeeCode],S.[IsEnabled],S.[CalculationMode],S.[RatePercent],S.[MinimumAmount],S.[FlatAmount],S.[PremiumDiscountType],S.[ValuePerUnit],S.[FeePercent],S.[GracePeriodDays],S.[FixedAmount],S.[FeePerUnit],S.[IsOverride],@Now,NULL);
    END

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
