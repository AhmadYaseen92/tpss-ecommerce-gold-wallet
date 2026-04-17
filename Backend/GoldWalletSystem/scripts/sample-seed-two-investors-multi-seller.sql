-- Seed helper: two investors with shared hashed password + multi-seller products per category.
-- Safe to run multiple times (uses MERGE/upsert semantics).

SET NOCOUNT ON;

DECLARE @Now datetime2 = SYSUTCDATETIME();
DECLARE @SharedInvestorPasswordHash nvarchar(500) = N'NN53R1Ggd5QH71EKW6wALA==.UbTyu0VUnNi27SE8JQbIjY5d8gs3jgo+SiUsNtLtt8I=.100000';

DECLARE @InvestorSeed TABLE
(
    FullName nvarchar(200),
    Email nvarchar(255),
    PasswordHash nvarchar(500),
    Role nvarchar(50),
    SellerId int NULL,
    PhoneNumber nvarchar(50)
);

INSERT INTO @InvestorSeed (FullName, Email, PasswordHash, Role, SellerId, PhoneNumber)
VALUES
    (N'Investor One', N'investor1@goldwallet.com', @SharedInvestorPasswordHash, N'Investor', NULL, N'+962790001001'),
    (N'Investor Two', N'investor2@goldwallet.com', @SharedInvestorPasswordHash, N'Investor', NULL, N'+962790001002');

MERGE [Users] AS T
USING @InvestorSeed AS S
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

DECLARE @Investor1Id int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'investor1@goldwallet.com');
DECLARE @Investor2Id int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'investor2@goldwallet.com');

-- Ensure investor wallets exist.
MERGE [Wallets] AS T
USING (
    SELECT @Investor1Id AS [UserId], N'USD' AS [CurrencyCode], CAST(0 AS decimal(18,2)) AS [CashBalance]
    UNION ALL
    SELECT @Investor2Id, N'USD', CAST(0 AS decimal(18,2))
) AS S
ON T.[UserId] = S.[UserId]
WHEN MATCHED THEN
    UPDATE SET
        T.[CurrencyCode] = S.[CurrencyCode],
        T.[UpdatedAtUtc] = @Now
WHEN NOT MATCHED THEN
    INSERT ([UserId],[CashBalance],[CurrencyCode],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES (S.[UserId],S.[CashBalance],S.[CurrencyCode],@Now,NULL);

-- Pick up to 2 active sellers to enforce multi-seller data in dev environments.
DECLARE @SellerA int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [IsActive] = 1 ORDER BY [Id]);
DECLARE @SellerB int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [IsActive] = 1 AND [Id] <> @SellerA ORDER BY [Id]);

IF @SellerA IS NULL OR @SellerB IS NULL
BEGIN
    RAISERROR('Need at least 2 active sellers in [Sellers] table before running this script.', 16, 1);
    RETURN;
END;

DECLARE @ProductSeed TABLE
(
    SellerId int,
    Name nvarchar(200),
    Sku nvarchar(100),
    [Description] nvarchar(1000),
    Price decimal(18,2),
    AvailableStock int,
    WeightValue decimal(18,3),
    Category int,
    ImageUrl nvarchar(1000),
    MaterialType int,
    FormType int,
    PurityKarat int,
    PurityFactor decimal(18,3)
);

-- Seller A: one per category.
INSERT INTO @ProductSeed
VALUES
(@SellerA, N'SellerA Gold Bar 10g',     N'SA-GLD-10G', N'24K gold bar',         780.00, 120, 10.000, 1, N'/images/products/gold-bar.png',   1, 3, 1, 1.000),
(@SellerA, N'SellerA Silver Coin 1oz',  N'SA-SLV-1OZ', N'Pure silver coin',      39.00,  180, 31.104, 2, N'/images/products/silver.png',     2, 2, 1, 0.999),
(@SellerA, N'SellerA Diamond Pendant',  N'SA-DIA-PND', N'Certified diamond',     950.00, 45,  1.500, 3, N'/images/products/diamond.png',    3, 1, 1, 1.000),
(@SellerA, N'SellerA Jewelry Ring',     N'SA-JWL-RNG', N'Gold jewelry ring',     320.00, 90,  4.200, 4, N'/images/products/jewelry.png',    1, 1, 2, 0.916),
(@SellerA, N'SellerA Gold Coin 5g',     N'SA-CIN-5G',  N'Collector gold coin',   410.00, 110, 5.000, 5, N'/images/products/gold-coin.png',  1, 2, 1, 1.000),
(@SellerA, N'SellerA Spot MR Pack',     N'SA-SPT-MR',  N'Spot market request',   85.00,  70,  2.000, 6, N'/images/products/silver.png',     2, 1, 1, 0.999),
-- Seller B: one per category.
(@SellerB, N'SellerB Gold Bar 20g',     N'SB-GLD-20G', N'24K gold bar',         1560.00, 80, 20.000, 1, N'/images/products/gold-bar.png',   1, 3, 1, 1.000),
(@SellerB, N'SellerB Silver Coin 2oz',  N'SB-SLV-2OZ', N'Pure silver coin',      78.00,  150, 62.208, 2, N'/images/products/silver.png',     2, 2, 1, 0.999),
(@SellerB, N'SellerB Diamond Stud',     N'SB-DIA-STD', N'Diamond stud pair',     1200.00, 35, 1.200, 3, N'/images/products/diamond.png',    3, 1, 1, 1.000),
(@SellerB, N'SellerB Jewelry Bracelet', N'SB-JWL-BRC', N'Gold bracelet',         540.00,  65, 7.500, 4, N'/images/products/jewelry.png',    1, 1, 2, 0.916),
(@SellerB, N'SellerB Gold Coin 10g',    N'SB-CIN-10G', N'Premium gold coin',     820.00,  95,10.000, 5, N'/images/products/gold-coin.png',  1, 2, 1, 1.000),
(@SellerB, N'SellerB Spot MR Plus',     N'SB-SPT-MR',  N'Spot market request',   140.00, 55,  3.500, 6, N'/images/products/silver.png',     2, 1, 1, 0.999);

MERGE [Products] AS T
USING @ProductSeed AS S
ON T.[SellerId] = S.[SellerId] AND T.[Sku] = S.[Sku]
WHEN MATCHED THEN
    UPDATE SET
        T.[Name] = S.[Name],
        T.[Description] = S.[Description],
        T.[Price] = S.[Price],
        T.[AvailableStock] = S.[AvailableStock],
        T.[WeightValue] = S.[WeightValue],
        T.[WeightUnit] = 1,
        T.[MaterialType] = S.[MaterialType],
        T.[FormType] = S.[FormType],
        T.[PricingMode] = 1,
        T.[PurityKarat] = S.[PurityKarat],
        T.[PurityFactor] = S.[PurityFactor],
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
        [SellerId],[Name],[Sku],[Description],[Price],[AvailableStock],[WeightValue],[WeightUnit],[MaterialType],[FormType],
        [PricingMode],[PurityKarat],[PurityFactor],[BaseMarketPrice],[ManualSellPrice],[DeliveryFee],[StorageFee],[ServiceCharge],
        [OfferPercent],[OfferNewPrice],[OfferType],[Category],[ImageUrl],[IsActive],[CreatedAtUtc],[UpdatedAtUtc]
    )
    VALUES (
        S.[SellerId],S.[Name],S.[Sku],S.[Description],S.[Price],S.[AvailableStock],S.[WeightValue],1,S.[MaterialType],S.[FormType],
        1,S.[PurityKarat],S.[PurityFactor],S.[Price],S.[Price],5,2,1,
        0,0,0,S.[Category],S.[ImageUrl],1,@Now,NULL
    );

SELECT TOP 2 [Id], [FullName], [Email], [Role], [SellerId], [IsActive]
FROM [Users]
WHERE [Email] IN (N'investor1@goldwallet.com', N'investor2@goldwallet.com')
ORDER BY [Email];

SELECT [SellerId], [Category], COUNT(*) AS ProductCount
FROM [Products]
WHERE [SellerId] IN (@SellerA, @SellerB)
GROUP BY [SellerId], [Category]
ORDER BY [SellerId], [Category];
