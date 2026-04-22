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

    /*
        Optional cleanup mode:
        - Keeps users + sellers information.
        - Clears products and operational/action data so you can create products/actions manually.
        Set to 1 when needed.
    */
    DECLARE @CleanDatabaseExceptUsersAndSellers bit = 0;
    IF @CleanDatabaseExceptUsersAndSellers = 1
    BEGIN
        IF OBJECT_ID(N'[TransactionFeeBreakdowns]') IS NOT NULL DELETE FROM [TransactionFeeBreakdowns];
        IF OBJECT_ID(N'[SellerProductFees]') IS NOT NULL DELETE FROM [SellerProductFees];
        IF OBJECT_ID(N'[AdminTransactionFees]') IS NOT NULL DELETE FROM [AdminTransactionFees];
        IF OBJECT_ID(N'[Products]') IS NOT NULL DELETE FROM [Products];

        IF OBJECT_ID(N'[CartItems]') IS NOT NULL DELETE FROM [CartItems];
        IF OBJECT_ID(N'[Carts]') IS NOT NULL DELETE FROM [Carts];

        IF OBJECT_ID(N'[WalletAssets]') IS NOT NULL DELETE FROM [WalletAssets];
        IF OBJECT_ID(N'[Wallets]') IS NOT NULL DELETE FROM [Wallets];

        IF OBJECT_ID(N'[Invoices]') IS NOT NULL DELETE FROM [Invoices];
        IF OBJECT_ID(N'[TransactionHistories]') IS NOT NULL DELETE FROM [TransactionHistories];
        IF OBJECT_ID(N'[PaymentTransactions]') IS NOT NULL DELETE FROM [PaymentTransactions];
        IF OBJECT_ID(N'[Orders]') IS NOT NULL DELETE FROM [Orders];

        IF OBJECT_ID(N'[CardPaymentMethodDetails]') IS NOT NULL DELETE FROM [CardPaymentMethodDetails];
        IF OBJECT_ID(N'[ApplePayPaymentMethodDetails]') IS NOT NULL DELETE FROM [ApplePayPaymentMethodDetails];
        IF OBJECT_ID(N'[WalletPaymentMethodDetails]') IS NOT NULL DELETE FROM [WalletPaymentMethodDetails];
        IF OBJECT_ID(N'[CliqPaymentMethodDetails]') IS NOT NULL DELETE FROM [CliqPaymentMethodDetails];
        IF OBJECT_ID(N'[PaymentMethods]') IS NOT NULL DELETE FROM [PaymentMethods];
        IF OBJECT_ID(N'[LinkedBankAccounts]') IS NOT NULL DELETE FROM [LinkedBankAccounts];

        IF OBJECT_ID(N'[AppNotifications]') IS NOT NULL DELETE FROM [AppNotifications];
        IF OBJECT_ID(N'[UserPushTokens]') IS NOT NULL DELETE FROM [UserPushTokens];
        IF OBJECT_ID(N'[AuditLogs]') IS NOT NULL DELETE FROM [AuditLogs];

        PRINT 'Cleanup mode complete: kept Users/Sellers information, cleared products + action/transaction data.';
    END;

    -- Ensure seller user accounts exist before seeding Sellers (Sellers.UserId is required).
    DECLARE @SellerUsers TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        PasswordHash nvarchar(500),
        Role nvarchar(50),
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @SellerUsers (FullName, Email, PasswordHash, Role, PhoneNumber)
    VALUES
        (N'Imseeh Seller',   N'imseeh.seller@example.com',   N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller', N'+962700000001'),
        (N'GoldPal Seller',  N'goldpal.seller@example.com',  N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller', N'+15550000002');

    MERGE [Users] AS T
    USING @SellerUsers AS S
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

    -- 1) Sellers + normalized registration tables.
    DECLARE @SellerSeed TABLE (
        CompanyCode nvarchar(50),
        CompanyName nvarchar(150),
        SellerEmail nvarchar(200),
        CompanyEmail nvarchar(200),
        CompanyPhone nvarchar(50),
        Country nvarchar(80),
        City nvarchar(80),
        Street nvarchar(150),
        BuildingNumber nvarchar(30),
        PostalCode nvarchar(30),
        CommercialRegistrationNumber nvarchar(100),
        VatNumber nvarchar(100),
        BusinessActivity nvarchar(150),
        ManagerFullName nvarchar(150),
        ManagerPosition nvarchar(100),
        ManagerNationality nvarchar(80),
        ManagerMobile nvarchar(50),
        ManagerEmail nvarchar(200),
        ManagerIdType nvarchar(50),
        ManagerIdNumber nvarchar(100),
        BankName nvarchar(150),
        AccountHolderName nvarchar(150),
        AccountNumber nvarchar(100),
        IBAN nvarchar(100),
        SwiftCode nvarchar(50),
        BankCountry nvarchar(80),
        BankCity nvarchar(80),
        BankBranchName nvarchar(120),
        BankBranchAddress nvarchar(250)
    );

    INSERT INTO @SellerSeed
    VALUES
        (N'IMSEEH', N'Imseeh Precious Metals LLC', N'imseeh.seller@example.com', N'contact@imseeh.com', N'+962700000001', N'Jordan', N'Amman', N'Wasfi Al Tal St', N'12A', N'11181', N'CR-IMSEEH-001', N'VAT-IMSEEH-001', N'Precious Metals Trading', N'Imseeh Seller', N'Owner', N'Jordanian', N'+962700000001', N'imseeh.seller@example.com', N'National ID', N'9876543210', N'Arab Bank', N'Imseeh Trading LLC', N'00131000302', N'JO94CBJO0010000000000131000302', N'ARABJOAX', N'Jordan', N'Amman', N'Main Branch', N'Shabsoogh Complex, Amman'),
        (N'GOLDPAL', N'Gold Palace Inc.', N'goldpal.seller@example.com', N'contact@goldpalace.com', N'+15550000002', N'United States', N'Dallas', N'Elm Street', N'401', N'75201', N'CR-GOLDPAL-002', N'VAT-GOLDPAL-002', N'Bullion Retail', N'GoldPal Seller', N'Manager', N'American', N'+15550000002', N'goldpal.seller@example.com', N'Passport', N'1234509876', N'Bank of America', N'Gold Palace Inc.', N'3300958879', N'US64SVBKUS6S3300958879', N'BOFAUS3N', N'United States', N'Dallas', N'Downtown', N'901 Main St, Dallas');

    MERGE [Sellers] AS T
    USING @SellerSeed AS S
    ON T.[CompanyCode] = S.[CompanyCode]
    WHEN MATCHED THEN
        UPDATE SET
            T.[CompanyName] = S.[CompanyName],
            T.[CommercialRegistrationNumber] = S.[CommercialRegistrationNumber],
            T.[VatNumber] = S.[VatNumber],
            T.[BusinessActivity] = S.[BusinessActivity],
            T.[CompanyPhone] = S.[CompanyPhone],
            T.[CompanyEmail] = S.[CompanyEmail],
            T.[UserId] = COALESCE((SELECT TOP 1 U.[Id] FROM [Users] U WHERE U.[Email] = S.[SellerEmail]), T.[UserId]),
            T.[KycStatus] = 2,
            T.[ReviewedAtUtc] = @Now,
            T.[ReviewNotes] = N'Seeded as approved seller',
            T.[IsActive] = 1,
            T.[UpdatedAtUtc] = @Now
    WHEN NOT MATCHED THEN
        INSERT (
            [UserId],[CompanyName],[CompanyCode],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[EstablishedDate],
            [CompanyPhone],[CompanyEmail],[Website],[Description],[IsActive],[KycStatus],[ReviewedAtUtc],[ReviewNotes],
            [GoldPrice],[SilverPrice],[DiamondPrice],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES (
            (SELECT TOP 1 U.[Id] FROM [Users] U WHERE U.[Email] = S.[SellerEmail]),
            S.[CompanyName],S.[CompanyCode],S.[CommercialRegistrationNumber],S.[VatNumber],S.[BusinessActivity],NULL,
            S.[CompanyPhone],S.[CompanyEmail],NULL,NULL,1,2,@Now,N'Seeded as approved seller',
            NULL,NULL,NULL,@Now,NULL
        );

    MERGE [SellerAddresses] AS T
    USING (
        SELECT S.Id AS SellerId, Seed.Country, Seed.City, Seed.Street, Seed.BuildingNumber, Seed.PostalCode
        FROM [Sellers] S
        JOIN @SellerSeed Seed ON Seed.CompanyCode = S.CompanyCode
    ) AS X
    ON T.SellerId = X.SellerId
    WHEN MATCHED THEN UPDATE SET T.Country=X.Country,T.City=X.City,T.Street=X.Street,T.BuildingNumber=X.BuildingNumber,T.PostalCode=X.PostalCode,T.UpdatedAtUtc=@Now
    WHEN NOT MATCHED THEN
        INSERT (SellerId,Country,City,Street,BuildingNumber,PostalCode,CreatedAtUtc,UpdatedAtUtc)
        VALUES (X.SellerId,X.Country,X.City,X.Street,X.BuildingNumber,X.PostalCode,@Now,NULL);

    MERGE [SellerManagers] AS T
    USING (
        SELECT S.Id AS SellerId, Seed.ManagerFullName, Seed.ManagerPosition, Seed.ManagerNationality, Seed.ManagerMobile, Seed.ManagerEmail, Seed.ManagerIdType, Seed.ManagerIdNumber
        FROM [Sellers] S
        JOIN @SellerSeed Seed ON Seed.CompanyCode = S.CompanyCode
    ) AS X
    ON T.SellerId = X.SellerId AND T.IsPrimary = 1
    WHEN MATCHED THEN UPDATE SET T.FullName=X.ManagerFullName,T.PositionTitle=X.ManagerPosition,T.Nationality=X.ManagerNationality,T.MobileNumber=X.ManagerMobile,T.EmailAddress=X.ManagerEmail,T.IdType=X.ManagerIdType,T.IdNumber=X.ManagerIdNumber,T.UpdatedAtUtc=@Now
    WHEN NOT MATCHED THEN
        INSERT (SellerId,FullName,PositionTitle,Nationality,MobileNumber,EmailAddress,IdType,IdNumber,IdExpiryDate,IsPrimary,CreatedAtUtc,UpdatedAtUtc)
        VALUES (X.SellerId,X.ManagerFullName,X.ManagerPosition,X.ManagerNationality,X.ManagerMobile,X.ManagerEmail,X.ManagerIdType,X.ManagerIdNumber,NULL,1,@Now,NULL);

    MERGE [SellerBranches] AS T
    USING (
        SELECT S.Id AS SellerId, S.CompanyName + N' Main Branch' AS BranchName, A.Country, A.City, A.Street + N', ' + A.BuildingNumber AS FullAddress, A.BuildingNumber, A.PostalCode, S.CompanyPhone AS PhoneNumber, S.CompanyEmail AS Email
        FROM [Sellers] S
        JOIN [SellerAddresses] A ON A.SellerId = S.Id
    ) AS X
    ON T.SellerId = X.SellerId AND T.IsMainBranch = 1
    WHEN MATCHED THEN UPDATE SET T.BranchName=X.BranchName,T.Country=X.Country,T.City=X.City,T.FullAddress=X.FullAddress,T.BuildingNumber=X.BuildingNumber,T.PostalCode=X.PostalCode,T.PhoneNumber=X.PhoneNumber,T.Email=X.Email,T.UpdatedAtUtc=@Now
    WHEN NOT MATCHED THEN
        INSERT (SellerId,BranchName,Country,City,FullAddress,BuildingNumber,PostalCode,PhoneNumber,Email,IsMainBranch,CreatedAtUtc,UpdatedAtUtc)
        VALUES (X.SellerId,X.BranchName,X.Country,X.City,X.FullAddress,X.BuildingNumber,X.PostalCode,X.PhoneNumber,X.Email,1,@Now,NULL);

    MERGE [SellerBankAccounts] AS T
    USING (
        SELECT S.Id AS SellerId, Seed.BankName, Seed.AccountHolderName, Seed.AccountNumber, Seed.IBAN, Seed.SwiftCode, Seed.BankCountry, Seed.BankCity, Seed.BankBranchName, Seed.BankBranchAddress
        FROM [Sellers] S
        JOIN @SellerSeed Seed ON Seed.CompanyCode = S.CompanyCode
    ) AS X
    ON T.SellerId = X.SellerId AND T.IsMainAccount = 1
    WHEN MATCHED THEN UPDATE SET T.BankName=X.BankName,T.AccountHolderName=X.AccountHolderName,T.AccountNumber=X.AccountNumber,T.IBAN=X.IBAN,T.SwiftCode=X.SwiftCode,T.BankCountry=X.BankCountry,T.BankCity=X.BankCity,T.BranchName=X.BankBranchName,T.BranchAddress=X.BankBranchAddress,T.Currency=N'USD',T.UpdatedAtUtc=@Now
    WHEN NOT MATCHED THEN
        INSERT (SellerId,BankName,AccountHolderName,AccountNumber,IBAN,SwiftCode,BankCountry,BankCity,BranchName,BranchAddress,Currency,IsMainAccount,CreatedAtUtc,UpdatedAtUtc)
        VALUES (X.SellerId,X.BankName,X.AccountHolderName,X.AccountNumber,X.IBAN,X.SwiftCode,X.BankCountry,X.BankCity,X.BankBranchName,X.BankBranchAddress,N'USD',1,@Now,NULL);

    MERGE [SellerDocuments] AS T
    USING (
        SELECT S.Id AS SellerId, D.DocumentType, D.FileName, D.FilePath, D.RelatedEntityType, D.IsRequired
        FROM [Sellers] S
        CROSS APPLY (VALUES
            (N'CommercialRegistrationDocument', N'cr.pdf', N'/kyc/' + LOWER(S.CompanyCode) + N'/cr.pdf', N'Seller', 1),
            (N'ArticlesOfAssociation', N'articles.pdf', N'/kyc/' + LOWER(S.CompanyCode) + N'/articles.pdf', N'Seller', 1),
            (N'ProofOfAddress', N'proof-address.pdf', N'/kyc/' + LOWER(S.CompanyCode) + N'/proof-address.pdf', N'Seller', 1),
            (N'VatCertificate', N'vat.pdf', N'/kyc/' + LOWER(S.CompanyCode) + N'/vat.pdf', N'Seller', 1),
            (N'AmlDocumentation', N'aml.pdf', N'/kyc/' + LOWER(S.CompanyCode) + N'/aml.pdf', N'Seller', 1),
            (N'ManagerIdCopy', N'manager-id.pdf', N'/kyc/' + LOWER(S.CompanyCode) + N'/manager-id.pdf', N'Manager', 1)
        ) D(DocumentType, FileName, FilePath, RelatedEntityType, IsRequired)
    ) AS X
    ON T.SellerId = X.SellerId AND T.DocumentType = X.DocumentType
    WHEN MATCHED THEN UPDATE SET T.FileName=X.FileName,T.FilePath=X.FilePath,T.ContentType=N'application/pdf',T.IsRequired=X.IsRequired,T.RelatedEntityType=X.RelatedEntityType,T.UploadedAtUtc=@Now,T.UpdatedAtUtc=@Now
    WHEN NOT MATCHED THEN
        INSERT (SellerId,DocumentType,FileName,FilePath,ContentType,IsRequired,UploadedAtUtc,RelatedEntityType,RelatedEntityId,CreatedAtUtc,UpdatedAtUtc)
        VALUES (X.SellerId,X.DocumentType,X.FileName,X.FilePath,N'application/pdf',X.IsRequired,@Now,X.RelatedEntityType,NULL,@Now,NULL);

    DECLARE @SellerImseeh int  = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'IMSEEH');
    DECLARE @SellerGoldPal int = (SELECT TOP 1 [Id] FROM [Sellers] WHERE [CompanyCode] = N'GOLDPAL');

    UPDATE [Sellers] SET [GoldPrice] = 430.00, [SilverPrice] = 36.00, [DiamondPrice] = 920.00, [UpdatedAtUtc] = @Now WHERE [Id] = @SellerImseeh;
    UPDATE [Sellers] SET [GoldPrice] = 432.00, [SilverPrice] = 37.00, [DiamondPrice] = 880.00, [UpdatedAtUtc] = @Now WHERE [Id] = @SellerGoldPal;

    -- 2) Users (sellers, admins, and investors).
    DECLARE @Users TABLE (
        FullName nvarchar(150),
        Email nvarchar(200),
        PasswordHash nvarchar(500),
        Role nvarchar(50),
        PhoneNumber nvarchar(30)
    );

    INSERT INTO @Users (FullName, Email, PasswordHash, Role, PhoneNumber)
    VALUES
        (N'Imseeh Seller',        N'imseeh.seller@example.com',      N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller',   N'+962700000001'),
        (N'GoldPal Seller',       N'goldpal.seller@example.com',     N'mC80KKdQIwUFXvdjaAEpcg==.zleByP5/d6gSWrKMe44R5bkV4vdJGsZHStS2ZB6b6do=.100000', N'Seller',   N'+15550000002'),
        (N'Gold Wallet Admin',    N'admin@goldwallet.com',          N'oZeUFZdNlzg+6Ra4C4EmlA==.maYFfxklpEO8qX1HBhaRZUT3JCfbgmd8cmZJo/Q6xcE=.100000', N'Admin',    N'+15551010001'),
        (N'Gold Wallet Investor', N'investor@goldwallet.com',       N'NN53R1Ggd5QH71EKW6wALA==.UbTyu0VUnNi27SE8JQbIjY5d8gs3jgo+SiUsNtLtt8I=.100000', N'Investor', N'+962790000999'),
        (N'Imseeh Investor 1',    N'imseeh.investor1@example.com',  N'E4AJcY7MeKmJOoaxRXzfXg==.Yd4IWfYBZUqs83ho+2xLhTrveNqLL+Vojtvn3jjsMN8=.100000', N'Investor', N'+15551010002');

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

    -- 3) Profiles, wallets, and carts.
    INSERT INTO [UserProfiles] ([UserId],[DateOfBirth],[Nationality],[PreferredLanguage],[PreferredTheme],[DocumentType],[IdNumber],[ProfilePhotoUrl],[CreatedAtUtc],[UpdatedAtUtc])
    SELECT U.[Id], NULL, N'Unknown', N'en', N'light', N'', N'', N'/images/profiles/default-user.png', @Now, NULL
    FROM [Users] U
    WHERE U.[Email] IN (SELECT [Email] FROM @Users)
      AND NOT EXISTS (SELECT 1 FROM [UserProfiles] P WHERE P.[UserId] = U.[Id]);

    UPDATE UP
    SET
        UP.[DateOfBirth] = CASE U.[Email]
            WHEN N'investor@goldwallet.com' THEN '1992-03-14'
            WHEN N'imseeh.investor1@example.com' THEN '1988-11-02'
            ELSE UP.[DateOfBirth]
        END,
        UP.[Nationality] = CASE U.[Email]
            WHEN N'investor@goldwallet.com' THEN N'Jordanian'
            WHEN N'imseeh.investor1@example.com' THEN N'Jordanian'
            ELSE UP.[Nationality]
        END,
        UP.[PreferredLanguage] = N'en',
        UP.[PreferredTheme] = N'light',
        UP.[DocumentType] = CASE U.[Email]
            WHEN N'investor@goldwallet.com' THEN N'National ID'
            WHEN N'imseeh.investor1@example.com' THEN N'Passport'
            ELSE UP.[DocumentType]
        END,
        UP.[IdNumber] = CASE U.[Email]
            WHEN N'investor@goldwallet.com' THEN N'INV-0001-9981'
            WHEN N'imseeh.investor1@example.com' THEN N'INV-0002-7711'
            ELSE UP.[IdNumber]
        END,
        UP.[ProfilePhotoUrl] = CASE U.[Email]
            WHEN N'investor@goldwallet.com' THEN N'/images/profiles/investor-main.png'
            WHEN N'imseeh.investor1@example.com' THEN N'/images/profiles/investor-imseeh.png'
            ELSE UP.[ProfilePhotoUrl]
        END,
        UP.[UpdatedAtUtc] = @Now
    FROM [UserProfiles] UP
    INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
    WHERE U.[Email] IN (N'investor@goldwallet.com', N'imseeh.investor1@example.com');

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

    -- 3.b) Seed profile-linked bank accounts and payment methods used by checkout/wallet actions.
    DELETE A
    FROM [ApplePayPaymentMethodDetails] A
    INNER JOIN [PaymentMethods] PM ON PM.[Id] = A.[PaymentMethodId]
    INNER JOIN [UserProfiles] UP ON UP.[Id] = PM.[UserProfileId]
    INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
    WHERE U.[Email] IN (N'investor@goldwallet.com', N'imseeh.investor1@example.com');

    DELETE C
    FROM [CardPaymentMethodDetails] C
    INNER JOIN [PaymentMethods] PM ON PM.[Id] = C.[PaymentMethodId]
    INNER JOIN [UserProfiles] UP ON UP.[Id] = PM.[UserProfileId]
    INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
    WHERE U.[Email] IN (N'investor@goldwallet.com', N'imseeh.investor1@example.com');

    DELETE WPM
    FROM [WalletPaymentMethodDetails] WPM
    INNER JOIN [PaymentMethods] PM ON PM.[Id] = WPM.[PaymentMethodId]
    INNER JOIN [UserProfiles] UP ON UP.[Id] = PM.[UserProfileId]
    INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
    WHERE U.[Email] IN (N'investor@goldwallet.com', N'imseeh.investor1@example.com');

    DELETE CL
    FROM [CliqPaymentMethodDetails] CL
    INNER JOIN [PaymentMethods] PM ON PM.[Id] = CL.[PaymentMethodId]
    INNER JOIN [UserProfiles] UP ON UP.[Id] = PM.[UserProfileId]
    INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
    WHERE U.[Email] IN (N'investor@goldwallet.com', N'imseeh.investor1@example.com');

    DELETE PM
    FROM [PaymentMethods] PM
    INNER JOIN [UserProfiles] UP ON UP.[Id] = PM.[UserProfileId]
    INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
    WHERE U.[Email] IN (N'investor@goldwallet.com', N'imseeh.investor1@example.com');

    DELETE LBA
    FROM [LinkedBankAccounts] LBA
    INNER JOIN [UserProfiles] UP ON UP.[Id] = LBA.[UserProfileId]
    INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
    WHERE U.[Email] IN (N'investor@goldwallet.com', N'imseeh.investor1@example.com');

    DECLARE @ProfileInvestorMain int = (
        SELECT TOP 1 UP.[Id]
        FROM [UserProfiles] UP
        INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
        WHERE U.[Email] = N'investor@goldwallet.com'
    );
    DECLARE @ProfileInvestorImseeh int = (
        SELECT TOP 1 UP.[Id]
        FROM [UserProfiles] UP
        INNER JOIN [Users] U ON U.[Id] = UP.[UserId]
        WHERE U.[Email] = N'imseeh.investor1@example.com'
    );

    INSERT INTO [LinkedBankAccounts] (
        [UserProfileId],[BankName],[IbanMasked],[IsVerified],[IsDefault],[AccountHolderName],[AccountNumber],[SwiftCode],
        [BranchName],[BranchAddress],[Country],[City],[Currency],[CreatedAtUtc],[UpdatedAtUtc]
    )
    VALUES
        (@ProfileInvestorMain, N'Jordan Islamic Bank', N'JO** **** **** 6789', 1, 1, N'Gold Wallet Investor', N'1234567890', N'JIBAJOAXXX', N'Amman Main', N'Abdali Branch', N'Jordan', N'Amman', N'JOD', @Now, NULL),
        (@ProfileInvestorMain, N'Arab Bank', N'JO** **** **** 1140', 1, 0, N'Gold Wallet Investor', N'9876543210', N'ARABJOAXXX', N'Shmeisani', N'Shmeisani Branch', N'Jordan', N'Amman', N'JOD', @Now, NULL),
        (@ProfileInvestorImseeh, N'Cairo Amman Bank', N'JO** **** **** 4412', 1, 1, N'Imseeh Investor 1', N'5566778899', N'CAABJOAXXX', N'Zarqa Main', N'Zarqa Downtown', N'Jordan', N'Zarqa', N'JOD', @Now, NULL);

    INSERT INTO [PaymentMethods] ([UserProfileId],[Type],[MaskedNumber],[IsDefault],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (@ProfileInvestorMain, N'Visa / MasterCard', N'**** **** **** 9281', 1, @Now, NULL),
        (@ProfileInvestorMain, N'Apple Pay', N'APPLE-PAY-PRIMARY', 0, @Now, NULL),
        (@ProfileInvestorMain, N'ZainCash', N'ZAINCASH-7788', 0, @Now, NULL),
        (@ProfileInvestorImseeh, N'Visa / MasterCard', N'**** **** **** 5521', 1, @Now, NULL);

    DECLARE @PmInvestorMainCard int = (
        SELECT TOP 1 [Id] FROM [PaymentMethods]
        WHERE [UserProfileId] = @ProfileInvestorMain AND [Type] = N'Visa / MasterCard'
        ORDER BY [Id] DESC
    );
    DECLARE @PmInvestorMainApple int = (
        SELECT TOP 1 [Id] FROM [PaymentMethods]
        WHERE [UserProfileId] = @ProfileInvestorMain AND [Type] = N'Apple Pay'
        ORDER BY [Id] DESC
    );
    DECLARE @PmInvestorMainWallet int = (
        SELECT TOP 1 [Id] FROM [PaymentMethods]
        WHERE [UserProfileId] = @ProfileInvestorMain AND [Type] = N'ZainCash'
        ORDER BY [Id] DESC
    );
    DECLARE @PmInvestorImseehCard int = (
        SELECT TOP 1 [Id] FROM [PaymentMethods]
        WHERE [UserProfileId] = @ProfileInvestorImseeh AND [Type] = N'Visa / MasterCard'
        ORDER BY [Id] DESC
    );

    INSERT INTO [CardPaymentMethodDetails] ([PaymentMethodId],[CardNumber],[CardHolderName],[Expiry],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (@PmInvestorMainCard, N'4111111111119281', N'Gold Wallet Investor', N'12/29', @Now, NULL),
        (@PmInvestorImseehCard, N'5555555555555521', N'Imseeh Investor 1', N'10/28', @Now, NULL);

    INSERT INTO [ApplePayPaymentMethodDetails] ([PaymentMethodId],[ApplePayToken],[AccountHolderName],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (@PmInvestorMainApple, N'APPLE_TOKEN_INVESTOR_MAIN', N'Gold Wallet Investor', @Now, NULL);

    INSERT INTO [WalletPaymentMethodDetails] ([PaymentMethodId],[Provider],[WalletNumber],[AccountHolderName],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (@PmInvestorMainWallet, N'ZainCash', N'0780007788', N'Gold Wallet Investor', @Now, NULL);

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
    DECLARE @SellerUserImseeh int = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = N'imseeh.seller@example.com');

    IF COL_LENGTH('TransactionHistories', 'Status') IS NOT NULL
    BEGIN
        INSERT INTO [TransactionHistories] (
            [UserId],[SellerId],[TransactionType],[Status],[Category],[Quantity],
            [UnitPrice],[Weight],[Unit],[Purity],[Amount],[SubTotalAmount],[TotalFeesAmount],[DiscountAmount],[FinalAmount],[Currency],[Notes],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@InvestorMain, @SellerImseeh, N'sell', N'pending', N'Gold', 1, 740, 5.000, N'gram', 24, 740, 730, 10, 0, 740, N'USD', N'SKU=IMSEEH-PRD-001|execution_mode=locked_30_seconds|wallet_asset_id=1', DATEADD(HOUR, -6, @Now), NULL),
            (@InvestorMain, @SellerImseeh, N'pickup', N'pending_delivered', N'Coins', 1, 2685, 31.104, N'gram', 24, 2685, 2650, 35, 0, 2685, N'USD', N'SKU=IMSEEH-PRD-005|pickup_schedule=Mon, 20 Apr 2026 10:00 AM|wallet_asset_id=2', DATEADD(HOUR, -5, @Now), NULL),
            (@InvestorImseeh, @SellerImseeh, N'transfer', N'approved', N'Gold', 1, 730, 5.000, N'gram', 24, 730, 720, 10, 0, 730, N'USD', CONCAT(N'SKU=IMSEEH-PRD-001|execution_mode=live_price|wallet_asset_id=3|recipient_investor_user_id=', @InvestorMain, N'|recipient_investor_name=Gold Wallet Investor'), DATEADD(DAY, -2, @Now), NULL),
            (@InvestorMain, @SellerImseeh, N'transfer', N'approved', N'Gold', 1, 730, 5.000, N'gram', 24, 730, 720, 10, 0, 730, N'USD', CONCAT(N'SKU=IMSEEH-PRD-001|direction=received|from_investor_user_id=', @InvestorImseeh, N'|from_investor_name=Imseeh Investor 1|wallet_asset_id=2'), DATEADD(DAY, -2, DATEADD(MINUTE, 1, @Now)), NULL),
            (@InvestorImseeh, @SellerImseeh, N'gift', N'approved', N'Gold', 1, 725, 5.000, N'gram', 24, 725, 715, 10, 0, 725, N'USD', CONCAT(N'SKU=IMSEEH-PRD-001|execution_mode=live_price|wallet_asset_id=3|recipient_investor_user_id=', @InvestorMain, N'|recipient_investor_name=Gold Wallet Investor'), DATEADD(DAY, -1, @Now), NULL),
            (@InvestorMain, @SellerImseeh, N'gift', N'approved', N'Gold', 1, 725, 5.000, N'gram', 24, 725, 715, 10, 0, 725, N'USD', CONCAT(N'SKU=IMSEEH-PRD-001|direction=received|from_investor_user_id=', @InvestorImseeh, N'|from_investor_name=Imseeh Investor 1|wallet_asset_id=2'), DATEADD(DAY, -1, DATEADD(MINUTE, 1, @Now)), NULL);
    END
    ELSE
    BEGIN
        EXEC sp_executesql
            N'
            INSERT INTO [TransactionHistories] ([UserId],[TransactionType],[Amount],[Currency],[Reference],[CreatedAtUtc],[UpdatedAtUtc])
            VALUES
                (@InvestorMain, N''withdrawal'', 1200, N''USD'', N''channel=webadmin|status=pending'', DATEADD(DAY, -1, @Now), NULL),
                (@InvestorImseeh, N''sell'', 740, N''USD'', N''channel=webadmin|status=approved'', DATEADD(DAY, -2, @Now), NULL),
                (@InvestorMain, N''transfer'', 350, N''USD'', N''channel=webadmin|status=rejected'', DATEADD(DAY, -3, @Now), NULL);
            ',
            N'@InvestorMain int, @InvestorImseeh int, @Now datetime2',
            @InvestorMain = @InvestorMain,
            @InvestorImseeh = @InvestorImseeh,
            @Now = @Now;
    END

    INSERT INTO [AppNotifications] ([UserId],[Title],[Body],[IsRead],[CreatedAtUtc],[UpdatedAtUtc])
    VALUES
        (@InvestorMain, N'KYC Pending', N'A new seller registration is pending approval.', 0, DATEADD(HOUR, -4, @Now), NULL),
        (@InvestorImseeh, N'Invoice Issued', N'Your latest trade invoice is available.', 0, DATEADD(HOUR, -8, @Now), NULL);

    INSERT INTO [Invoices] (
        [InvestorUserId],[SellerUserId],[InvoiceNumber],[InvoiceCategory],[SourceChannel],
        [ExternalReference],[SubTotal],[FeesAmount],[DiscountAmount],[TaxAmount],[TotalAmount],[Currency],
        [PaymentMethod],[PaymentStatus],[PaymentTransactionId],[WalletItemId],[ProductId],[ProductName],[Quantity],[UnitPrice],[Weight],[Purity],
        [FromPartyType],[ToPartyType],[FromPartyUserId],[ToPartyUserId],[OwnershipEffectiveOnUtc],[RelatedTransactionId],[InvoiceQrCode],[PdfUrl],
        [IssuedOnUtc],[PaidOnUtc],[Status],[CreatedAtUtc],[UpdatedAtUtc]
    )
    VALUES
        (@InvestorMain, @SellerUserImseeh, N'INV-SEED-0001', N'Buy', N'WebAdmin', N'SEED-ORDER-0001', 980, 0, 0, 0, 980, N'USD', N'Card', N'Pending', NULL, NULL, NULL, N'Imseeh 5g Gold Bar', 2, 490, 10.000, 24.00, N'Seller', N'Investor', @SellerUserImseeh, @InvestorMain, DATEADD(DAY, -1, @Now), NULL, N'', NULL, DATEADD(DAY, -1, @Now), NULL, N'Issued', @Now, NULL),
        (@InvestorImseeh, @SellerUserImseeh, N'INV-SEED-0002', N'Sell', N'WebAdmin', N'SEED-ORDER-0002', 1430, 5, 0, 0, 1435, N'USD', N'WalletCredit', N'Paid', N'SEED-TXN-0002', NULL, NULL, N'Imseeh Gold Coin', 1, 1430, 31.104, 24.00, N'Investor', N'Seller', @InvestorImseeh, @SellerUserImseeh, DATEADD(DAY, -2, @Now), NULL, N'', N'/Certificats/seed/invoice-seed-0002.pdf', DATEADD(DAY, -2, @Now), DATEADD(DAY, -2, @Now), N'Completed', @Now, NULL);

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
        SELECT @SellerGoldPal, N'GOLDPAL-PRD-005', N'GoldPal 1oz Gold Coin', N'Fine gold investment coin', CAST(2678.00 AS decimal(18,2)), 60, CAST(1.000 AS decimal(18,3)), 3, 5, 1, 2, N'/images/products/gold-coin.png'
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
            T.[WeightValue] = S.[WeightValue],
            T.[WeightUnit] = S.[WeightUnit],
            T.[MaterialType] = S.[MaterialType],
            T.[FormType] = S.[FormType],
            T.[PricingMode] = 1,
            T.[PurityKarat] = CASE WHEN S.[Name] LIKE N'%22K%' THEN 2 ELSE 1 END,
            T.[PurityFactor] = CASE WHEN S.[Category] = 2 THEN 0.999 ELSE 1.0 END,
            T.[BaseMarketPrice] = S.[Price],
            T.[ManualSellPrice] = S.[Price],
            T.[OfferPercent] = CASE
                WHEN S.[Sku] IN (N'IMSEEH-PRD-001', N'GOLDPAL-PRD-004') THEN 12
                WHEN S.[Sku] IN (N'IMSEEH-PRD-003', N'GOLDPAL-PRD-002') THEN 7
                ELSE 0
            END,
            T.[OfferNewPrice] = CASE
                WHEN S.[Sku] IN (N'IMSEEH-PRD-001', N'GOLDPAL-PRD-004') THEN ROUND(S.[Price] * 0.88, 2)
                WHEN S.[Sku] IN (N'IMSEEH-PRD-003', N'GOLDPAL-PRD-002') THEN ROUND(S.[Price] * 0.93, 2)
                ELSE 0
            END,
            T.[OfferType] = CASE
                WHEN S.[Sku] IN (N'IMSEEH-PRD-001', N'GOLDPAL-PRD-004', N'IMSEEH-PRD-003', N'GOLDPAL-PRD-002') THEN 1
                ELSE 0
            END,
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
            CASE
                WHEN S.[Sku] IN (N'IMSEEH-PRD-001', N'GOLDPAL-PRD-004') THEN 12
                WHEN S.[Sku] IN (N'IMSEEH-PRD-003', N'GOLDPAL-PRD-002') THEN 7
                ELSE 0
            END,
            CASE
                WHEN S.[Sku] IN (N'IMSEEH-PRD-001', N'GOLDPAL-PRD-004') THEN ROUND(S.[Price] * 0.88, 2)
                WHEN S.[Sku] IN (N'IMSEEH-PRD-003', N'GOLDPAL-PRD-002') THEN ROUND(S.[Price] * 0.93, 2)
                ELSE 0
            END,
            CASE
                WHEN S.[Sku] IN (N'IMSEEH-PRD-001', N'GOLDPAL-PRD-004', N'IMSEEH-PRD-003', N'GOLDPAL-PRD-002') THEN 1
                ELSE 0
            END,
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
    DECLARE @CartInvestorImseeh int = (SELECT TOP 1 [Id] FROM [Carts] WHERE [UserId] = @InvestorImseeh);

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

    DECLARE @WalletAssetMainGoldBar int = (
        SELECT TOP 1 [Id] FROM [WalletAssets]
        WHERE [WalletId] = @WalletInvestorMain AND [SellerName] = N'Imseeh'
        ORDER BY [CreatedAtUtc] ASC, [Id] ASC
    );

    DECLARE @WalletAssetMainGoldCoin int = (
        SELECT TOP 1 [Id] FROM [WalletAssets]
        WHERE [WalletId] = @WalletInvestorMain AND [SellerName] = N'Imseeh'
        ORDER BY [CreatedAtUtc] DESC, [Id] DESC
    );

    DECLARE @WalletAssetImseehSilver int = (
        SELECT TOP 1 [Id] FROM [WalletAssets]
        WHERE [WalletId] = @WalletInvestorImseeh
        ORDER BY [CreatedAtUtc] DESC, [Id] DESC
    );

    DECLARE @TxSellMain int = (
        SELECT TOP 1 [Id] FROM [TransactionHistories]
        WHERE [UserId] = @InvestorMain AND [TransactionType] = N'sell'
        ORDER BY [CreatedAtUtc] DESC, [Id] DESC
    );

    DECLARE @TxSellImseeh int = (
        SELECT TOP 1 [Id] FROM [TransactionHistories]
        WHERE [UserId] = @InvestorImseeh AND [TransactionType] = N'sell'
        ORDER BY [CreatedAtUtc] DESC, [Id] DESC
    );

    -- Backfill seeded invoices with wallet/product/transaction links so certificate + wallet actions can resolve records reliably.
    UPDATE [Invoices]
    SET
        [WalletItemId] = COALESCE([WalletItemId], @WalletAssetMainGoldBar),
        [ProductId] = COALESCE([ProductId], @ProductImseehGoldBar),
        [PaymentTransactionId] = COALESCE(NULLIF([PaymentTransactionId], N''), N'SEED-TXN-INV-0001'),
        [RelatedTransactionId] = COALESCE([RelatedTransactionId], @TxSellMain),
        [InvoiceQrCode] = CASE WHEN [InvoiceQrCode] IS NULL OR LTRIM(RTRIM([InvoiceQrCode])) = N'' THEN N'/Certificats/seed/invoice-seed-0001.pdf' ELSE [InvoiceQrCode] END,
        [PdfUrl] = COALESCE(NULLIF([PdfUrl], N''), N'/Certificats/seed/invoice-seed-0001.pdf'),
        [UpdatedAtUtc] = @Now
    WHERE [InvoiceNumber] = N'INV-SEED-0001';

    UPDATE [Invoices]
    SET
        [WalletItemId] = COALESCE([WalletItemId], @WalletAssetImseehSilver),
        [ProductId] = COALESCE([ProductId], @ProductGoldPalSilver),
        [PaymentTransactionId] = COALESCE(NULLIF([PaymentTransactionId], N''), N'SEED-TXN-INV-0002'),
        [RelatedTransactionId] = COALESCE([RelatedTransactionId], @TxSellImseeh),
        [InvoiceQrCode] = CASE WHEN [InvoiceQrCode] IS NULL OR LTRIM(RTRIM([InvoiceQrCode])) = N'' THEN N'/Certificats/seed/invoice-seed-0002.pdf' ELSE [InvoiceQrCode] END,
        [PdfUrl] = COALESCE(NULLIF([PdfUrl], N''), N'/Certificats/seed/invoice-seed-0002.pdf'),
        [UpdatedAtUtc] = @Now
    WHERE [InvoiceNumber] = N'INV-SEED-0002';

    IF NOT EXISTS (SELECT 1 FROM [Invoices] WHERE [InvoiceNumber] = N'INV-SEED-0003')
    BEGIN
        INSERT INTO [Invoices] (
            [InvestorUserId],[SellerUserId],[InvoiceNumber],[InvoiceCategory],[SourceChannel],[ExternalReference],
            [SubTotal],[FeesAmount],[DiscountAmount],[TaxAmount],[TotalAmount],[Currency],[PaymentMethod],[PaymentStatus],
            [PaymentTransactionId],[WalletItemId],[ProductId],[ProductName],[Quantity],[UnitPrice],[Weight],[Purity],
            [FromPartyType],[ToPartyType],[FromPartyUserId],[ToPartyUserId],[OwnershipEffectiveOnUtc],[RelatedTransactionId],
            [InvoiceQrCode],[PdfUrl],[IssuedOnUtc],[PaidOnUtc],[Status],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@InvestorMain, @SellerUserImseeh, N'INV-SEED-0003', N'Transfer', N'MobileWallet', N'SEED-WALLET-TRANSFER-0003',
             730, 0, 0, 0, 730, N'USD', N'WalletCredit', N'Pending', NULL, @WalletAssetMainGoldBar, @ProductImseehGoldBar,
             N'Imseeh 5g Gold Bar', 1, 730, 5.000, 24.00, N'Investor', N'Investor', @InvestorMain, @InvestorImseeh,
             DATEADD(HOUR, -6, @Now), NULL, N'', N'/Certificats/seed/invoice-seed-0003.pdf', DATEADD(HOUR, -6, @Now), NULL, N'Issued', @Now, NULL),

            (@InvestorMain, @SellerUserImseeh, N'INV-SEED-0004', N'Pickup', N'MobileWallet', N'SEED-WALLET-PICKUP-0004',
             2675, 0, 0, 0, 2675, N'USD', N'N/A', N'Pending', NULL, @WalletAssetMainGoldCoin, @ProductImseehGoldCoin,
             N'Imseeh Gold Coin', 1, 2675, 31.104, 24.00, N'Investor', N'Seller', @InvestorMain, @SellerUserImseeh,
             DATEADD(HOUR, -3, @Now), NULL, N'', N'/Certificats/seed/invoice-seed-0004.pdf', DATEADD(HOUR, -3, @Now), NULL, N'Issued', @Now, NULL);
    END

    IF COL_LENGTH('CartItems', 'Category') IS NOT NULL AND COL_LENGTH('CartItems', 'SellerId') IS NOT NULL
    BEGIN
        INSERT INTO [CartItems] (
            [CartId],[ProductId],[SellerId],[Category],[Quantity],[UnitPrice],[LineTotal],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@CartInvestorMain, @ProductImseehGoldBar, @SellerImseeh, 1, 2, 430.00, 860.00, @Now, NULL),
            (@CartInvestorMain, @ProductImseehGoldCoin, @SellerImseeh, 5, 1, 2675.00, 2675.00, @Now, NULL),
            (@CartInvestorImseeh, @ProductGoldPalSilver, @SellerGoldPal, 2, 4, 37.00, 148.00, @Now, NULL);
    END
    ELSE IF COL_LENGTH('CartItems', 'SellerId') IS NOT NULL
    BEGIN
        INSERT INTO [CartItems] (
            [CartId],[ProductId],[SellerId],[Quantity],[UnitPrice],[LineTotal],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@CartInvestorMain, @ProductImseehGoldBar, @SellerImseeh, 2, 430.00, 860.00, @Now, NULL),
            (@CartInvestorMain, @ProductImseehGoldCoin, @SellerImseeh, 1, 2675.00, 2675.00, @Now, NULL),
            (@CartInvestorImseeh, @ProductGoldPalSilver, @SellerGoldPal, 4, 37.00, 148.00, @Now, NULL);
    END
    ELSE
    BEGIN
        INSERT INTO [CartItems] (
            [CartId],[ProductId],[Quantity],[UnitPrice],[LineTotal],[CreatedAtUtc],[UpdatedAtUtc]
        )
        VALUES
            (@CartInvestorMain, @ProductImseehGoldBar, 2, 430.00, 860.00, @Now, NULL),
            (@CartInvestorMain, @ProductImseehGoldCoin, 1, 2675.00, 2675.00, @Now, NULL),
            (@CartInvestorImseeh, @ProductGoldPalSilver, 4, 37.00, 148.00, @Now, NULL);
    END

    -- 6) Flat mobile/web configuration rows (typed values).
    MERGE [SystemConfigration] AS T
    USING (
        VALUES
        (N'WalletSell_Mode', N'Wallet Sell Mode', N'Wallet sell execution behavior for mobile and web', 1, NULL, NULL, NULL, N'locked_30_seconds', CAST(0 AS bit)),
        (N'WalletSell_LockSeconds', N'Wallet Sell Lock Seconds', N'Wallet sell lock duration in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
        (N'MobileRelease_IsIndividualSeller', N'Mobile Release Is Individual Seller', N'Mobile release: show single seller mode', 2, CAST(0 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'MobileRelease_IndividualSellerName', N'Mobile Release Individual Seller Name', N'Mobile release seller name when single seller mode is enabled', 1, NULL, NULL, NULL, N'Imseeh', CAST(0 AS bit)),
        (N'MobileRelease_ShowWeightInGrams', N'Mobile Release Show Weight In Grams', N'Mobile release flag to show weight in grams', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_EnableWhatsapp', N'OTP Enable WhatsApp', N'Enable WhatsApp OTP delivery channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_EnableEmail', N'OTP Enable Email', N'Enable Email OTP delivery channel', 2, CAST(1 AS bit), NULL, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_ExpirySeconds', N'OTP Expiry Seconds', N'OTP code expiry duration in seconds', 3, NULL, 300, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_ResendCooldownSeconds', N'OTP Resend Cooldown Seconds', N'OTP resend cooldown in seconds', 3, NULL, 30, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_MaxResendCount', N'OTP Max Resend Count', N'Maximum number of OTP resend attempts', 3, NULL, 3, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_MaxVerificationAttempts', N'OTP Max Verification Attempts', N'Maximum OTP verification attempts before lock', 3, NULL, 5, NULL, NULL, CAST(0 AS bit)),
        (N'Otp_ChannelPriority', N'OTP Channel Priority', N'Preferred OTP channels in order', 1, NULL, NULL, NULL, N'whatsapp,email', CAST(0 AS bit)),
        (N'Otp_RequiredActions', N'OTP Required Actions', N'Actions that require OTP verification', 1, NULL, NULL, NULL, N'registration,reset_password,checkout,buy,sell,transfer,gift,pickup,add_bank_account,edit_bank_account,remove_bank_account,add_payment_method,edit_payment_method,remove_payment_method,change_email,change_password,change_mobile_number', CAST(0 AS bit))
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

    -- 6.b) Seed fee-management tables when available.
    IF OBJECT_ID(N'[SystemFeeTypes]', N'U') IS NOT NULL
    BEGIN
        MERGE [SystemFeeTypes] AS T
        USING (
            VALUES
            (N'commission_per_transaction', N'Commission Per Transaction', N'Seller managed commission fee', CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 1),
            (N'premium_discount', N'Premium / Discount', N'Seller managed premium or discount fee', CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 2),
            (N'storage_custody_fee', N'Storage / Custody Fee', N'Seller managed custody fee', CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 3),
            (N'delivery_fee', N'Delivery Fee', N'Seller managed delivery fee', CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 4),
            (N'service_charge', N'Service Charge', N'Seller managed service charge', CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), CAST(0 AS bit), CAST(1 AS bit), CAST(1 AS bit), CAST(0 AS bit), 5),
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
            WHERE P.[SellerId] IN (@SellerImseeh, @SellerGoldPal)
            UNION ALL
            SELECT P.[SellerId], P.[Id], N'service_charge', CAST(1 AS bit), N'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(2.50 AS decimal(18,2)), NULL, CAST(0 AS bit)
            FROM [Products] P
            WHERE P.[SellerId] IN (@SellerImseeh, @SellerGoldPal)
            UNION ALL
            SELECT P.[SellerId], P.[Id], N'delivery_fee', CAST(1 AS bit), N'fixed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(12.00 AS decimal(18,2)), NULL, CAST(0 AS bit)
            FROM [Products] P
            WHERE P.[SellerId] IN (@SellerImseeh, @SellerGoldPal)
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



    -- 6.c) Seed transaction fee breakdown rows when table exists.
    IF OBJECT_ID(N'[TransactionFeeBreakdowns]', N'U') IS NOT NULL
    BEGIN
        INSERT INTO [TransactionFeeBreakdowns] (
            [TransactionHistoryId],[ProductId],[SellerId],[FeeCode],[FeeName],[CalculationMode],[BaseAmount],[Quantity],[AppliedRate],[AppliedValue],[IsDiscount],[Currency],[SourceType],[ConfigSnapshotJson],[DisplayOrder],[CreatedAtUtc],[UpdatedAtUtc]
        )
        SELECT TH.[Id], NULL, TH.[SellerId], N'service_fee', N'Service Fee', N'percent', TH.[SubTotalAmount], TH.[Quantity], 1.25, TH.[TotalFeesAmount], 0, TH.[Currency], N'AdminServiceFee', N'{"seed":true}', 1, @Now, NULL
        FROM [TransactionHistories] TH
        WHERE TH.[CreatedAtUtc] >= DATEADD(DAY, -10, @Now)
          AND TH.[TotalFeesAmount] > 0
          AND NOT EXISTS (SELECT 1 FROM [TransactionFeeBreakdowns] FB WHERE FB.[TransactionHistoryId] = TH.[Id]);
    END

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
    N'admin@goldwallet.com',
    N'investor@goldwallet.com',
    N'imseeh.investor1@example.com'
);

SELECT COUNT(*) AS SeedProductCount
FROM [Products]
WHERE [Sku] LIKE N'IMSEEH-PRD-%'
   OR [Sku] LIKE N'GOLDPAL-PRD-%';
