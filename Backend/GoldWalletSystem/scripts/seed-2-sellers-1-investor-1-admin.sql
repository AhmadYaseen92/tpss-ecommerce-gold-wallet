/*
Seed option 2:
- 2 Sellers (full profile + address)
- 1 Investor (full profile + linked bank + payment method)
- 1 Admin
- baseline wallets/carts/products

Idempotent: safe to run multiple times.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @Now datetime2 = SYSUTCDATETIME();
    DECLARE @DefaultHash nvarchar(500) = N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000';

    ------------------------------------------------------------
    -- Users: admin + sellers + investor
    ------------------------------------------------------------
    DECLARE @SeedUsers TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        [Role] nvarchar(50),
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @SeedUsers (FullName, Email, [Role], PhoneNumber)
    VALUES
        (N'System Admin', N'admin@goldwallet.local', N'Admin', N'+962700000010'),
        (N'Seller One User', N'seller.one@goldwallet.local', N'Seller', N'+962700000011'),
        (N'Seller Two User', N'seller.two@goldwallet.local', N'Seller', N'+962700000012'),
        (N'Investor One User', N'investor.one@goldwallet.local', N'Investor', N'+962700000013');

    MERGE [Users] AS T
    USING @SeedUsers AS S
    ON T.[Email] = S.[Email]
    WHEN MATCHED THEN
        UPDATE SET
            T.[FullName] = S.[FullName],
            T.[Role] = S.[Role],
            T.[PhoneNumber] = S.[PhoneNumber],
            T.[PasswordHash] = @DefaultHash,
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([FullName],[Email],[PasswordHash],[Role],[PhoneNumber],[IsActive],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[FullName],S.[Email],@DefaultHash,S.[Role],S.[PhoneNumber],1,@Now,NULL);

    DECLARE @SellerOneUserId int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'seller.one@goldwallet.local');
    DECLARE @SellerTwoUserId int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'seller.two@goldwallet.local');
    DECLARE @InvestorUserId int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'investor.one@goldwallet.local');

    ------------------------------------------------------------
    -- Sellers + addresses (full profile)
    ------------------------------------------------------------
    MERGE [Sellers] AS T
    USING (
        VALUES
            (@SellerOneUserId, N'SEED-SLR-001', N'Seed Seller One', N'seller.one@goldwallet.local', N'+962700000011', N'CR-SEED-001', N'VAT-SEED-001', N'Precious metals retail', CAST(2 AS int)),
            (@SellerTwoUserId, N'SEED-SLR-002', N'Seed Seller Two', N'seller.two@goldwallet.local', N'+962700000012', N'CR-SEED-002', N'VAT-SEED-002', N'Coins and jewelry', CAST(2 AS int))
    ) AS S([UserId],[CompanyCode],[CompanyName],[CompanyEmail],[CompanyPhone],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[KycStatus])
    ON T.[CompanyCode] = S.[CompanyCode]
    WHEN MATCHED THEN
        UPDATE SET
            T.[UserId] = S.[UserId],
            T.[CompanyName] = S.[CompanyName],
            T.[CompanyEmail] = S.[CompanyEmail],
            T.[CompanyPhone] = S.[CompanyPhone],
            T.[CommercialRegistrationNumber] = S.[CommercialRegistrationNumber],
            T.[VatNumber] = S.[VatNumber],
            T.[BusinessActivity] = S.[BusinessActivity],
            T.[KycStatus] = S.[KycStatus],
            T.[IsActive] = 1,
            T.[ReviewedAtUtc] = @Now,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([UserId],[CompanyName],[CompanyCode],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[CompanyPhone],[CompanyEmail],[IsActive],[KycStatus],[ReviewedAtUtc],[ReviewNotes],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[UserId],S.[CompanyName],S.[CompanyCode],S.[CommercialRegistrationNumber],S.[VatNumber],S.[BusinessActivity],S.[CompanyPhone],S.[CompanyEmail],1,S.[KycStatus],@Now,N'Seeded seller',@Now,NULL);

    DECLARE @SellerOneId int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'SEED-SLR-001');
    DECLARE @SellerTwoId int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'SEED-SLR-002');

    MERGE [SellerAddresses] AS T
    USING (
        VALUES
            (@SellerOneId, N'Jordan', N'Amman', N'Mecca St', N'101', N'11180'),
            (@SellerTwoId, N'Jordan', N'Irbid', N'University St', N'202', N'21110')
    ) AS S([SellerId],[Country],[City],[Street],[BuildingNumber],[PostalCode])
    ON T.[SellerId] = S.[SellerId]
    WHEN MATCHED THEN
        UPDATE SET
            T.[Country] = S.[Country],
            T.[City] = S.[City],
            T.[Street] = S.[Street],
            T.[BuildingNumber] = S.[BuildingNumber],
            T.[PostalCode] = S.[PostalCode],
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[Country],[City],[Street],[BuildingNumber],[PostalCode],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[Country],S.[City],S.[Street],S.[BuildingNumber],S.[PostalCode],@Now,NULL);

    ------------------------------------------------------------
    -- Investor full profile + payment/bank methods
    ------------------------------------------------------------
    INSERT INTO [UserProfiles] ([UserId],[DateOfBirth],[Nationality],[PreferredLanguage],[PreferredTheme],[DocumentType],[IdNumber],[ProfilePhotoUrl],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT @InvestorUserId, '1992-01-10', N'Jordanian', N'en', N'light', N'NationalId', N'INV-SEED-001', N'/images/profiles/default-user.png', @Now, NULL
    WHERE NOT EXISTS (SELECT 1 FROM [UserProfiles] WHERE [UserId] = @InvestorUserId);

    DECLARE @InvestorProfileId int = (SELECT TOP 1 [Id] FROM [UserProfiles] WHERE [UserId] = @InvestorUserId);

    MERGE [LinkedBankAccounts] AS T
    USING (
        VALUES
            (@InvestorProfileId, N'Arab Bank', N'JO** **** **** 7788', 1, 1, N'Investor One User', N'7788990011', N'ARABJOAXXX', N'Abdali', N'Amman', N'Jordan', N'Amman', N'JOD')
    ) AS S([UserProfileId],[BankName],[IbanMasked],[IsVerified],[IsDefault],[AccountHolderName],[AccountNumber],[SwiftCode],[BranchName],[BranchAddress],[Country],[City],[Currency])
    ON T.[UserProfileId] = S.[UserProfileId] AND T.[IbanMasked] = S.[IbanMasked]
    WHEN MATCHED THEN
        UPDATE SET
            T.[BankName] = S.[BankName], T.[IsVerified] = S.[IsVerified], T.[IsDefault] = S.[IsDefault],
            T.[AccountHolderName] = S.[AccountHolderName], T.[AccountNumber] = S.[AccountNumber], T.[SwiftCode] = S.[SwiftCode],
            T.[BranchName] = S.[BranchName], T.[BranchAddress] = S.[BranchAddress], T.[Country] = S.[Country],
            T.[City] = S.[City], T.[Currency] = S.[Currency], T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([UserProfileId],[BankName],[IbanMasked],[IsVerified],[IsDefault],[AccountHolderName],[AccountNumber],[SwiftCode],[BranchName],[BranchAddress],[Country],[City],[Currency],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[UserProfileId],S.[BankName],S.[IbanMasked],S.[IsVerified],S.[IsDefault],S.[AccountHolderName],S.[AccountNumber],S.[SwiftCode],S.[BranchName],S.[BranchAddress],S.[Country],S.[City],S.[Currency],@Now,NULL);

    MERGE [PaymentMethods] AS T
    USING (
        VALUES
            (@InvestorProfileId, N'Visa / MasterCard', N'**** **** **** 4455', 1)
    ) AS S([UserProfileId],[Type],[MaskedNumber],[IsDefault])
    ON T.[UserProfileId] = S.[UserProfileId] AND T.[Type] = S.[Type] AND T.[MaskedNumber] = S.[MaskedNumber]
    WHEN MATCHED THEN
        UPDATE SET T.[IsDefault] = S.[IsDefault], T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([UserProfileId],[Type],[MaskedNumber],[IsDefault],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[UserProfileId],S.[Type],S.[MaskedNumber],S.[IsDefault],@Now,NULL);

    DECLARE @PaymentMethodId int = (
        SELECT TOP 1 [Id] FROM [PaymentMethods]
        WHERE [UserProfileId] = @InvestorProfileId AND [Type] = N'Visa / MasterCard' AND [MaskedNumber] = N'**** **** **** 4455'
        ORDER BY [Id] DESC
    );

    MERGE [CardPaymentMethodDetails] AS T
    USING (VALUES (@PaymentMethodId, N'4111111111114455', N'Investor One User', N'12/29')) AS S([PaymentMethodId],[CardNumber],[CardHolderName],[Expiry])
    ON T.[PaymentMethodId] = S.[PaymentMethodId]
    WHEN MATCHED THEN
        UPDATE SET T.[CardNumber] = S.[CardNumber], T.[CardHolderName] = S.[CardHolderName], T.[Expiry] = S.[Expiry], T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([PaymentMethodId],[CardNumber],[CardHolderName],[Expiry],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[PaymentMethodId],S.[CardNumber],S.[CardHolderName],S.[Expiry],@Now,NULL);

    ------------------------------------------------------------
    -- Wallet + cart
    ------------------------------------------------------------
    INSERT INTO [Wallets] ([UserId],[CashBalance],[CurrencyCode],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT @InvestorUserId, 10000.00, N'USD', @Now, NULL
    WHERE NOT EXISTS (SELECT 1 FROM [Wallets] WHERE [UserId] = @InvestorUserId);

    INSERT INTO [Carts] ([UserId],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT @InvestorUserId, @Now, NULL
    WHERE NOT EXISTS (SELECT 1 FROM [Carts] WHERE [UserId] = @InvestorUserId);

    ------------------------------------------------------------
    -- Products for the 2 sellers (new pricing fields)
    ------------------------------------------------------------
    MERGE [Products] AS T
    USING (
        VALUES
            (@SellerOneId, N'SEED-S1-GLD-10', N'Seller One Gold Bar 10g', N'24K Gold bar', N'/images/products/gold-bar.png', 1, 1, 3, 1, 1.000, 10.000, 1, 60.00, 600.00, 600.00, 600.00, 0.00, 0.00, 0, 0, 50),
            (@SellerOneId, N'SEED-S1-SLV-1OZ', N'Seller One Silver Coin', N'Fine silver .999', N'/images/products/silver.png', 2, 2, 2, 1, 0.999, 31.104, 3, 1.20, 37.00, 37.00, 35.00, 5.00, 0.00, 1, 1, 90),
            (@SellerTwoId, N'SEED-S2-GLD-20', N'Seller Two Gold Bar 20g', N'24K Gold bar', N'/images/products/gold-bar.png', 1, 1, 3, 1, 1.000, 20.000, 1, 60.00, 1200.00, 1200.00, 1200.00, 0.00, 0.00, 0, 0, 40),
            (@SellerTwoId, N'SEED-S2-DIA-1', N'Seller Two Diamond Pendant', N'Diamond pendant', N'/images/products/diamond.png', 3, 3, 1, 0, 1.000, 1.000, 1, 350.00, 350.00, 350.00, 325.00, 0.00, 325.00, 2, 1, 20)
    ) AS S([SellerId],[Sku],[Name],[Description],[ImageUrl],[Category],[MaterialType],[FormType],[PurityKarat],[PurityFactor],[WeightValue],[WeightUnit],[BaseMarketPrice],[AutoPrice],[FixedPrice],[SellPrice],[OfferPercent],[OfferNewPrice],[OfferType],[IsHasOffer],[AvailableStock])
    ON T.[Sku] = S.[Sku]
    WHEN MATCHED THEN
        UPDATE SET
            T.[SellerId] = S.[SellerId], T.[Name] = S.[Name], T.[Description] = S.[Description], T.[ImageUrl] = S.[ImageUrl],
            T.[Category] = S.[Category], T.[MaterialType] = S.[MaterialType], T.[FormType] = S.[FormType],
            T.[PricingMode] = 1, T.[PurityKarat] = S.[PurityKarat], T.[PurityFactor] = S.[PurityFactor],
            T.[WeightValue] = S.[WeightValue], T.[WeightUnit] = S.[WeightUnit], T.[BaseMarketPrice] = S.[BaseMarketPrice],
            T.[AutoPrice] = S.[AutoPrice], T.[FixedPrice] = S.[FixedPrice], T.[SellPrice] = S.[SellPrice],
            T.[OfferPercent] = S.[OfferPercent], T.[OfferNewPrice] = S.[OfferNewPrice], T.[OfferType] = S.[OfferType],
            T.[IsHasOffer] = S.[IsHasOffer], T.[AvailableStock] = S.[AvailableStock], T.[IsActive] = 1, T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([Name],[Sku],[Description],[ImageUrl],[Category],[MaterialType],[FormType],[PricingMode],[PurityKarat],[PurityFactor],[WeightValue],[WeightUnit],[BaseMarketPrice],[AutoPrice],[FixedPrice],[SellPrice],[OfferPercent],[OfferNewPrice],[OfferType],[IsHasOffer],[AvailableStock],[IsActive],[SellerId],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[Name],S.[Sku],S.[Description],S.[ImageUrl],S.[Category],S.[MaterialType],S.[FormType],1,S.[PurityKarat],S.[PurityFactor],S.[WeightValue],S.[WeightUnit],S.[BaseMarketPrice],S.[AutoPrice],S.[FixedPrice],S.[SellPrice],S.[OfferPercent],S.[OfferNewPrice],S.[OfferType],S.[IsHasOffer],S.[AvailableStock],1,S.[SellerId],@Now,NULL);

    COMMIT TRAN;
    PRINT 'Seed option 2 completed: 2 sellers + 1 investor + 1 admin.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;
