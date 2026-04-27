/*
Seed: System settings + fee management + 1 admin + 1 seller (Imseeh) + 1 investor
Idempotent, safe for repeated runs.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @Now datetime2 = SYSUTCDATETIME();
    DECLARE @AdminHash nvarchar(500) = N'PPJjw8OG+mRgfuQq0PwjBg==.I6aFJ1YwnTWLF8rajLp/30yOAXuGukxV5lx0zFoVuBo=.100000';
    DECLARE @SellerHash nvarchar(500) = N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000';
    DECLARE @InvestorHash nvarchar(500) = N'NN53R1Ggd5QH71EKW6wALA==.UbTyu0VUnNi27SE8JQbIjY5d8gs3jgo+SiUsNtLtt8I=.100000';

    ------------------------------------------------------------
    -- Users: admin + seller + investor
    ------------------------------------------------------------
    DECLARE @SeedUsers TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        PasswordHash nvarchar(500),
        [Role] nvarchar(50),
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @SeedUsers (FullName, Email, PasswordHash, [Role], PhoneNumber)
    VALUES
        (N'Gold Wallet Admin', N'admin@goldwallet.com', @AdminHash, N'Admin', N'+962790000100'),
        (N'Imseeh Seller', N'imseeh.seller@example.com', @SellerHash, N'Seller', N'+962700000001'),
        (N'Gold Wallet Investor', N'investor@goldwallet.com', @InvestorHash, N'Investor', N'+962790000999');

    MERGE [Users] AS T
    USING @SeedUsers AS S
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

    DECLARE @SellerUserId int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'imseeh.seller@example.com');
    DECLARE @InvestorUserId int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'investor@goldwallet.com');

    ------------------------------------------------------------
    -- Seller (Imseeh) full profile
    ------------------------------------------------------------
    MERGE [Sellers] AS T
    USING (
        VALUES
            (@SellerUserId, N'IMSEEH', N'Imseeh Precious Metals LLC', N'contact@imseeh.com', N'+962700000001', N'CR-IMSEEH-001', N'VAT-IMSEEH-001', N'Precious Metals Trading', CAST(2 AS int))
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
            T.[ReviewedAtUtc] = @Now,
            T.[ReviewNotes] = N'Seeded as approved seller',
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT ([UserId],[CompanyName],[CompanyCode],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[CompanyPhone],[CompanyEmail],[IsActive],[KycStatus],[ReviewedAtUtc],[ReviewNotes],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[UserId],S.[CompanyName],S.[CompanyCode],S.[CommercialRegistrationNumber],S.[VatNumber],S.[BusinessActivity],S.[CompanyPhone],S.[CompanyEmail],1,S.[KycStatus],@Now,N'Seeded as approved seller',@Now,NULL);

    DECLARE @SellerId int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'IMSEEH');

    MERGE [SellerAddresses] AS T
    USING (VALUES (@SellerId, N'Jordan', N'Amman', N'Wasfi Al Tal St', N'12A', N'11181')) AS S([SellerId],[Country],[City],[Street],[BuildingNumber],[PostalCode])
    ON T.[SellerId] = S.[SellerId]
    WHEN MATCHED THEN
        UPDATE SET T.[Country]=S.[Country],T.[City]=S.[City],T.[Street]=S.[Street],T.[BuildingNumber]=S.[BuildingNumber],T.[PostalCode]=S.[PostalCode],T.[UpdatedAtUtc]=@Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[Country],[City],[Street],[BuildingNumber],[PostalCode],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[Country],S.[City],S.[Street],S.[BuildingNumber],S.[PostalCode],@Now,NULL);

    MERGE [SellerManagers] AS T
    USING (VALUES (@SellerId, N'Imseeh Seller', N'Owner', N'Jordanian', N'+962700000001', N'imseeh.seller@example.com', N'National ID', N'9876543210'))
        AS S([SellerId],[FullName],[PositionTitle],[Nationality],[MobileNumber],[EmailAddress],[IdType],[IdNumber])
    ON T.[SellerId] = S.[SellerId] AND T.[IsPrimary] = 1
    WHEN MATCHED THEN
        UPDATE SET T.[FullName]=S.[FullName],T.[PositionTitle]=S.[PositionTitle],T.[Nationality]=S.[Nationality],T.[MobileNumber]=S.[MobileNumber],T.[EmailAddress]=S.[EmailAddress],T.[IdType]=S.[IdType],T.[IdNumber]=S.[IdNumber],T.[UpdatedAtUtc]=@Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[FullName],[PositionTitle],[Nationality],[MobileNumber],[EmailAddress],[IdType],[IdNumber],[IdExpiryDate],[IsPrimary],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[FullName],S.[PositionTitle],S.[Nationality],S.[MobileNumber],S.[EmailAddress],S.[IdType],S.[IdNumber],NULL,1,@Now,NULL);

    MERGE [SellerBranches] AS T
    USING (VALUES (@SellerId, N'Imseeh Main Branch', N'Jordan', N'Amman', N'Wasfi Al Tal St, 12A', N'12A', N'11181', N'+962700000001', N'contact@imseeh.com', CAST(1 AS bit)))
        AS S([SellerId],[BranchName],[Country],[City],[FullAddress],[BuildingNumber],[PostalCode],[PhoneNumber],[Email],[IsMainBranch])
    ON T.[SellerId] = S.[SellerId] AND T.[IsMainBranch] = 1
    WHEN MATCHED THEN
        UPDATE SET T.[BranchName]=S.[BranchName],T.[Country]=S.[Country],T.[City]=S.[City],T.[FullAddress]=S.[FullAddress],T.[BuildingNumber]=S.[BuildingNumber],T.[PostalCode]=S.[PostalCode],T.[PhoneNumber]=S.[PhoneNumber],T.[Email]=S.[Email],T.[UpdatedAtUtc]=@Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[BranchName],[Country],[City],[FullAddress],[BuildingNumber],[PostalCode],[PhoneNumber],[Email],[IsMainBranch],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[BranchName],S.[Country],S.[City],S.[FullAddress],S.[BuildingNumber],S.[PostalCode],S.[PhoneNumber],S.[Email],S.[IsMainBranch],@Now,NULL);

    MERGE [SellerBankAccounts] AS T
    USING (VALUES (@SellerId, N'Arab Bank', N'Imseeh Trading LLC', N'00131000302', N'JO94CBJO0010000000000131000302', N'ARABJOAX', N'Jordan', N'Amman', N'Main Branch', N'Shabsoogh Complex, Amman', N'USD', CAST(1 AS bit)))
        AS S([SellerId],[BankName],[AccountHolderName],[AccountNumber],[IBAN],[SwiftCode],[BankCountry],[BankCity],[BranchName],[BranchAddress],[Currency],[IsMainAccount])
    ON T.[SellerId] = S.[SellerId] AND T.[IsMainAccount] = 1
    WHEN MATCHED THEN
        UPDATE SET T.[BankName]=S.[BankName],T.[AccountHolderName]=S.[AccountHolderName],T.[AccountNumber]=S.[AccountNumber],T.[IBAN]=S.[IBAN],T.[SwiftCode]=S.[SwiftCode],T.[BankCountry]=S.[BankCountry],T.[BankCity]=S.[BankCity],T.[BranchName]=S.[BranchName],T.[BranchAddress]=S.[BranchAddress],T.[Currency]=S.[Currency],T.[UpdatedAtUtc]=@Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[BankName],[AccountHolderName],[AccountNumber],[IBAN],[SwiftCode],[BankCountry],[BankCity],[BranchName],[BranchAddress],[Currency],[IsMainAccount],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[BankName],S.[AccountHolderName],S.[AccountNumber],S.[IBAN],S.[SwiftCode],S.[BankCountry],S.[BankCity],S.[BranchName],S.[BranchAddress],S.[Currency],S.[IsMainAccount],@Now,NULL);

    MERGE [SellerDocuments] AS T
    USING (
        VALUES
            (@SellerId, N'CommercialRegistrationDocument', N'cr.pdf', N'/kyc/imseeh/cr.pdf', N'Seller', CAST(1 AS bit)),
            (@SellerId, N'ArticlesOfAssociation', N'articles.pdf', N'/kyc/imseeh/articles.pdf', N'Seller', CAST(1 AS bit)),
            (@SellerId, N'ProofOfAddress', N'proof-address.pdf', N'/kyc/imseeh/proof-address.pdf', N'Seller', CAST(1 AS bit)),
            (@SellerId, N'VatCertificate', N'vat.pdf', N'/kyc/imseeh/vat.pdf', N'Seller', CAST(1 AS bit)),
            (@SellerId, N'AmlDocumentation', N'aml.pdf', N'/kyc/imseeh/aml.pdf', N'Seller', CAST(1 AS bit)),
            (@SellerId, N'ManagerIdCopy', N'manager-id.pdf', N'/kyc/imseeh/manager-id.pdf', N'Manager', CAST(1 AS bit))
    ) AS S([SellerId],[DocumentType],[FileName],[FilePath],[RelatedEntityType],[IsRequired])
    ON T.[SellerId] = S.[SellerId] AND T.[DocumentType] = S.[DocumentType]
    WHEN MATCHED THEN
        UPDATE SET T.[FileName]=S.[FileName],T.[FilePath]=S.[FilePath],T.[ContentType]=N'application/pdf',T.[IsRequired]=S.[IsRequired],T.[RelatedEntityType]=S.[RelatedEntityType],T.[UploadedAtUtc]=@Now,T.[UpdatedAtUtc]=@Now
    WHEN NOT MATCHED THEN
        INSERT ([SellerId],[DocumentType],[FileName],[FilePath],[ContentType],[IsRequired],[UploadedAtUtc],[RelatedEntityType],[RelatedEntityId],[CreatedAtUtc],[UpdatedAtUtc])
        VALUES (S.[SellerId],S.[DocumentType],S.[FileName],S.[FilePath],N'application/pdf',S.[IsRequired],@Now,S.[RelatedEntityType],NULL,@Now,NULL);

    UPDATE [Sellers]
    SET [GoldPrice] = 430.00, [SilverPrice] = 36.00, [DiamondPrice] = 920.00, [UpdatedAtUtc] = @Now
    WHERE [Id] = @SellerId;

    ------------------------------------------------------------
    -- Investor full profile + methods
    ------------------------------------------------------------
    INSERT INTO [UserProfiles] ([UserId],[DateOfBirth],[Nationality],[PreferredLanguage],[PreferredTheme],[DocumentType],[IdNumber],[ProfilePhotoUrl],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT @InvestorUserId, '1992-03-14', N'Jordanian', N'en', N'light', N'National ID', N'INV-0001-9981', N'/images/profiles/investor-main.png', @Now, NULL
    WHERE NOT EXISTS (SELECT 1 FROM [UserProfiles] WHERE [UserId] = @InvestorUserId);

    UPDATE UP
    SET UP.[DateOfBirth] = '1992-03-14',
        UP.[Nationality] = N'Jordanian',
        UP.[PreferredLanguage] = N'en',
        UP.[PreferredTheme] = N'light',
        UP.[DocumentType] = N'National ID',
        UP.[IdNumber] = N'INV-0001-9981',
        UP.[ProfilePhotoUrl] = N'/images/profiles/investor-main.png',
        UP.[UpdatedAtUtc] = @Now
    FROM [UserProfiles] UP
    WHERE UP.[UserId] = @InvestorUserId;

    DECLARE @InvestorProfileId int = (SELECT TOP 1 [Id] FROM [UserProfiles] WHERE [UserId] = @InvestorUserId);

    DELETE A
    FROM [ApplePayPaymentMethodDetails] A
    INNER JOIN [PaymentMethods] PM ON PM.[Id] = A.[PaymentMethodId]
    WHERE PM.[UserProfileId] = @InvestorProfileId;

    DELETE C
    FROM [CardPaymentMethodDetails] C
    INNER JOIN [PaymentMethods] PM ON PM.[Id] = C.[PaymentMethodId]
    WHERE PM.[UserProfileId] = @InvestorProfileId;

    DELETE WPM
    FROM [WalletPaymentMethodDetails] WPM
    INNER JOIN [PaymentMethods] PM ON PM.[Id] = WPM.[PaymentMethodId]
    WHERE PM.[UserProfileId] = @InvestorProfileId;

    DELETE PM
    FROM [PaymentMethods] PM
    WHERE PM.[UserProfileId] = @InvestorProfileId;

    DELETE LBA
    FROM [LinkedBankAccounts] LBA
    WHERE LBA.[UserProfileId] = @InvestorProfileId;

    INSERT INTO [LinkedBankAccounts] (
        [UserProfileId],[BankName],[IbanMasked],[IsVerified],[IsDefault],[AccountHolderName],[AccountNumber],[SwiftCode],[BranchName],[BranchAddress],[Country],[City],[Currency],[CreatedAtUtc],[UpdatedAtUtc]
    )
    VALUES
        (@InvestorProfileId, N'Jordan Islamic Bank', N'JO** **** **** 6789', 1, 1, N'Gold Wallet Investor', N'1234567890', N'JIBAJOAXXX', N'Amman Main', N'Abdali Branch', N'Jordan', N'Amman', N'JOD', @Now, NULL),
        (@InvestorProfileId, N'Arab Bank', N'JO** **** **** 1140', 1, 0, N'Gold Wallet Investor', N'9876543210', N'ARABJOAXXX', N'Shmeisani', N'Shmeisani Branch', N'Jordan', N'Amman', N'JOD', @Now, NULL);

    INSERT INTO [PaymentMethods] ([UserProfileId],[Type],[MaskedNumber],[IsDefault],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (@InvestorProfileId, N'Visa / MasterCard', N'**** **** **** 9281', 1, @Now, NULL),
        (@InvestorProfileId, N'Apple Pay', N'APPLE-PAY-PRIMARY', 0, @Now, NULL),
        (@InvestorProfileId, N'ZainCash', N'ZAINCASH-7788', 0, @Now, NULL);

    DECLARE @PmCard int = (SELECT TOP 1 [Id] FROM [PaymentMethods] WHERE [UserProfileId] = @InvestorProfileId AND [Type] = N'Visa / MasterCard' ORDER BY [Id] DESC);
    DECLARE @PmApple int = (SELECT TOP 1 [Id] FROM [PaymentMethods] WHERE [UserProfileId] = @InvestorProfileId AND [Type] = N'Apple Pay' ORDER BY [Id] DESC);
    DECLARE @PmWallet int = (SELECT TOP 1 [Id] FROM [PaymentMethods] WHERE [UserProfileId] = @InvestorProfileId AND [Type] = N'ZainCash' ORDER BY [Id] DESC);

    INSERT INTO [CardPaymentMethodDetails] ([PaymentMethodId],[CardNumber],[CardHolderName],[Expiry],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES (@PmCard, N'4111111111119281', N'Gold Wallet Investor', N'12/29', @Now, NULL);

    INSERT INTO [ApplePayPaymentMethodDetails] ([PaymentMethodId],[ApplePayToken],[AccountHolderName],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES (@PmApple, N'APPLE_TOKEN_INVESTOR_MAIN', N'Gold Wallet Investor', @Now, NULL);

    INSERT INTO [WalletPaymentMethodDetails] ([PaymentMethodId],[Provider],[WalletNumber],[AccountHolderName],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES (@PmWallet, N'ZainCash', N'0780007788', N'Gold Wallet Investor', @Now, NULL);

    INSERT INTO [Wallets] ([UserId],[CashBalance],[CurrencyCode],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT @InvestorUserId, 0, N'USD', @Now, NULL
    WHERE NOT EXISTS (SELECT 1 FROM [Wallets] WHERE [UserId] = @InvestorUserId);

    INSERT INTO [Carts] ([UserId],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT @InvestorUserId, @Now, NULL
    WHERE NOT EXISTS (SELECT 1 FROM [Carts] WHERE [UserId] = @InvestorUserId);

    ------------------------------------------------------------
    -- Product for Imseeh (needed for seller fee assignments)
    ------------------------------------------------------------
    MERGE [Products] AS T
    USING (
        VALUES
            (@SellerId, N'IMSEEH-SEED-001', N'Imseeh Gold Bar 10g', N'24K Gold bar', N'/images/products/gold-bar.png', 1, 1, 3, 1, 1.000, 10.000, 1, 60.00, 600.00, 600.00, 600.00, 0.00, 0.00, 0, 0, 100)
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

    ------------------------------------------------------------
    -- System settings
    ------------------------------------------------------------
    MERGE [SystemConfigration] AS T
    USING (
        VALUES
            (N'WalletSell_Mode', N'Wallet Sell Mode', N'Wallet sell execution behavior for mobile and web', 1, NULL, NULL, NULL, N'locked_30_seconds', CAST(0 AS bit)),
            (N'WalletSell_LockSeconds', N'Wallet Sell Lock Seconds', N'Wallet sell lock duration in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
            (N'MobileRelease_IsIndividualSeller', N'Mobile Release Is Individual Seller', N'Mobile release: show single seller mode', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileRelease_IndividualSellerName', N'Mobile Release Individual Seller Name', N'Mobile release seller name when single seller mode is enabled', 1, NULL, NULL, NULL, N'Imseeh', CAST(0 AS bit)),
            (N'MobileRelease_ShowWeightInGrams', N'Mobile Release Show Weight In Grams', N'Mobile release flag to show weight in grams', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileRelease_MarketWatchEnabled', N'Mobile Release Market Watch Enabled', N'Mobile release flag to enable Market Watch tab in Product screen', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileRelease_MyAccountSummaryEnabled', N'Mobile Release My Account Summary Enabled', N'Mobile release flag to show My Account Summary entry in top bar', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'MobileSecurity_LoginByBiometric', N'Mobile Security Login By Biometric', N'Allow biometric quick unlock on mobile', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'Product_VideoMaxDurationSeconds', N'Product Video Max Duration Seconds', N'Max allowed uploaded product video duration in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
            (N'MobileSecurity_LoginByPin', N'Mobile Security Login By PIN', N'Allow PIN quick unlock on mobile', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_EnableWhatsapp', N'OTP Enable WhatsApp', N'Enable WhatsApp OTP delivery channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_EnableEmail', N'OTP Enable Email', N'Enable Email OTP delivery channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_ExpirySeconds', N'OTP Expiry Seconds', N'OTP code expiry duration in seconds', 3, NULL, 300, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_ResendCooldownSeconds', N'OTP Resend Cooldown Seconds', N'OTP resend cooldown in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_MaxResendCount', N'OTP Max Resend Count', N'Maximum number of OTP resend attempts', 3, NULL, 3, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_MaxVerificationAttempts', N'OTP Max Verification Attempts', N'Maximum OTP verification attempts before lock', 3, NULL, 5, NULL, NULL, CAST(0 AS bit)),
            (N'Otp_ChannelPriority', N'OTP Channel Priority', N'Preferred OTP channels in order', 1, NULL, NULL, NULL, N'whatsapp,email', CAST(0 AS bit)),
            (N'Otp_RequiredActions', N'OTP Required Actions', N'Actions that require OTP verification', 1, NULL, NULL, NULL, N'registration,reset_password,checkout,sell,transfer,gift,pickup,add_bank_account,edit_bank_account,remove_bank_account,add_payment_method,edit_payment_method,remove_payment_method,change_email,change_password,change_mobile_number', CAST(0 AS bit))
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
    -- Fee management
    ------------------------------------------------------------
    IF OBJECT_ID(N'[SystemFeeTypes]', N'U') IS NOT NULL
    BEGIN
        MERGE [SystemFeeTypes] AS T
        USING (
            VALUES
                (N'commission_per_transaction', N'Commission Per Transaction', N'Seller managed commission fee', CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 1),
                (N'delivery_fee', N'Delivery Fee', N'Seller managed delivery fee', CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 4),
                (N'service_fee', N'Service Fee', N'Admin managed service fee', CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), 6)
        ) AS S([FeeCode],[Name],[Description],[IsEnabled],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift],[AppliesToInvoice],[AppliesToReports],[IsAdminManaged],[SortOrder])
        ON T.[FeeCode] = S.[FeeCode]
        WHEN MATCHED THEN UPDATE SET
            T.[Name] = S.[Name], T.[Description] = S.[Description], T.[IsEnabled] = S.[IsEnabled],
            T.[AppliesToBuy] = S.[AppliesToBuy], T.[AppliesToSell] = S.[AppliesToSell], T.[AppliesToPickup] = S.[AppliesToPickup],
            T.[AppliesToTransfer] = S.[AppliesToTransfer], T.[AppliesToGift] = S.[AppliesToGift], T.[AppliesToInvoice] = S.[AppliesToInvoice],
            T.[AppliesToReports] = S.[AppliesToReports], T.[IsAdminManaged] = S.[IsAdminManaged], T.[SortOrder] = S.[SortOrder], T.[UpdatedAtUtc] = @Now
        WHEN NOT MATCHED THEN
            INSERT ([FeeCode],[Name],[Description],[IsEnabled],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift],[AppliesToInvoice],[AppliesToReports],[IsAdminManaged],[SortOrder],[CreatedAtUtc],[UpdatedAtUtc])
            VALUES (S.[FeeCode],S.[Name],S.[Description],S.[IsEnabled],S.[AppliesToBuy],S.[AppliesToSell],S.[AppliesToPickup],S.[AppliesToTransfer],S.[AppliesToGift],S.[AppliesToInvoice],S.[AppliesToReports],S.[IsAdminManaged],S.[SortOrder],@Now,NULL);
    END

    IF OBJECT_ID(N'[AdminTransactionFees]', N'U') IS NOT NULL
    BEGIN
        MERGE [AdminTransactionFees] AS T
        USING (
            VALUES (N'service_fee', CAST(1 AS bit), N'percent', 1.25, NULL, CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit))
        ) AS S([FeeCode],[IsEnabled],[CalculationMode],[RatePercent],[FixedAmount],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift])
        ON T.[FeeCode] = S.[FeeCode]
        WHEN MATCHED THEN UPDATE SET
            T.[IsEnabled] = S.[IsEnabled], T.[CalculationMode] = S.[CalculationMode], T.[RatePercent] = S.[RatePercent], T.[FixedAmount] = S.[FixedAmount],
            T.[AppliesToBuy] = S.[AppliesToBuy], T.[AppliesToSell] = S.[AppliesToSell], T.[AppliesToPickup] = S.[AppliesToPickup], T.[AppliesToTransfer] = S.[AppliesToTransfer], T.[AppliesToGift] = S.[AppliesToGift],
            T.[UpdatedAtUtc] = @Now
        WHEN NOT MATCHED THEN
            INSERT ([FeeCode],[IsEnabled],[CalculationMode],[RatePercent],[FixedAmount],[AppliesToBuy],[AppliesToSell],[AppliesToPickup],[AppliesToTransfer],[AppliesToGift],[CreatedAtUtc],[UpdatedAtUtc])
            VALUES (S.[FeeCode],S.[IsEnabled],S.[CalculationMode],S.[RatePercent],S.[FixedAmount],S.[AppliesToBuy],S.[AppliesToSell],S.[AppliesToPickup],S.[AppliesToTransfer],S.[AppliesToGift],@Now,NULL);
    END

    IF OBJECT_ID(N'[SellerProductFees]', N'U') IS NOT NULL
    BEGIN
        MERGE [SellerProductFees] AS T
        USING (
            SELECT P.[SellerId], P.[Id] AS ProductId, N'commission_per_transaction' AS FeeCode, CAST(1 AS bit) AS IsEnabled,
                   N'percent_with_minimum' AS CalculationMode, CAST(1.50 AS decimal(18,6)) AS RatePercent, CAST(5.00 AS decimal(18,2)) AS MinimumAmount,
                   NULL AS FlatAmount, NULL AS PremiumDiscountType, NULL AS ValuePerUnit, NULL AS FeePercent, NULL AS GracePeriodDays,
                   NULL AS FixedAmount, NULL AS FeePerUnit, CAST(0 AS bit) AS IsOverride
            FROM [Products] P
            WHERE P.[SellerId] = @SellerId
            UNION ALL
            SELECT P.[SellerId], P.[Id], N'delivery_fee', CAST(1 AS bit), N'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   CAST(12.00 AS decimal(18,2)), NULL, CAST(0 AS bit)
            FROM [Products] P
            WHERE P.[SellerId] = @SellerId
        ) AS S
        ON T.[SellerId] = S.[SellerId] AND T.[ProductId] = S.[ProductId] AND T.[FeeCode] = S.[FeeCode]
        WHEN MATCHED THEN UPDATE SET
            T.[IsEnabled] = S.[IsEnabled], T.[CalculationMode] = S.[CalculationMode], T.[RatePercent] = S.[RatePercent], T.[MinimumAmount] = S.[MinimumAmount],
            T.[FlatAmount] = S.[FlatAmount], T.[PremiumDiscountType] = S.[PremiumDiscountType], T.[ValuePerUnit] = S.[ValuePerUnit],
            T.[FeePercent] = S.[FeePercent], T.[GracePeriodDays] = S.[GracePeriodDays], T.[FixedAmount] = S.[FixedAmount], T.[FeePerUnit] = S.[FeePerUnit],
            T.[IsOverride] = S.[IsOverride], T.[UpdatedAtUtc] = @Now
        WHEN NOT MATCHED THEN
            INSERT ([SellerId],[ProductId],[FeeCode],[IsEnabled],[CalculationMode],[RatePercent],[MinimumAmount],[FlatAmount],[PremiumDiscountType],[ValuePerUnit],[FeePercent],[GracePeriodDays],[FixedAmount],[FeePerUnit],[IsOverride],[CreatedAtUtc],[UpdatedAtUtc])
            VALUES (S.[SellerId],S.[ProductId],S.[FeeCode],S.[IsEnabled],S.[CalculationMode],S.[RatePercent],S.[MinimumAmount],S.[FlatAmount],S.[PremiumDiscountType],S.[ValuePerUnit],S.[FeePercent],S.[GracePeriodDays],S.[FixedAmount],S.[FeePerUnit],S.[IsOverride],@Now,NULL);
    END

    COMMIT TRAN;
    PRINT 'Seed completed: system settings + fees + admin + Imseeh seller + investor@goldwallet.com';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;
