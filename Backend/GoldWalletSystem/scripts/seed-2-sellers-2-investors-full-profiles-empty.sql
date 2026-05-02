/*
Seed exactly:
- 2 Sellers (different market types)
- 2 Investors (different market types)
- same password for all users
- full profiles (seller + investor profile, bank account, payment method)
- NO products, NO transactions, NO wallet assets
Idempotent script.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

DECLARE @Now datetime2 = SYSUTCDATETIME();
DECLARE @SharedPasswordHash nvarchar(500) = N'NN53R1Ggd5QH71EKW6wALA==.UbTyu0VUnNi27SE8JQbIjY5d8gs3jgo+SiUsNtLtt8I=.100000';

DECLARE @Users TABLE(
    FullName nvarchar(200),
    Email nvarchar(255),
    Role nvarchar(50),
    PhoneNumber nvarchar(50)
);

INSERT INTO @Users VALUES
(N'Seller UAE', N'seller.uae@goldwallet.com', N'Seller', N'+971500000101'),
(N'Seller KSA', N'seller.ksa@goldwallet.com', N'Seller', N'+966500000102'),
(N'Investor UAE', N'investor.uae@goldwallet.com', N'Investor', N'+971500000201'),
(N'Investor KSA', N'investor.ksa@goldwallet.com', N'Investor', N'+966500000202');

MERGE [Users] AS T
USING @Users AS S ON T.Email = S.Email
WHEN MATCHED THEN UPDATE SET
    T.FullName = S.FullName,
    T.PasswordHash = @SharedPasswordHash,
    T.Role = S.Role,
    T.PhoneNumber = S.PhoneNumber,
    T.IsActive = 1,
    T.UpdatedAtUtc = @Now
WHEN NOT MATCHED THEN INSERT ([FullName],[Email],[PasswordHash],[Role],[PhoneNumber],[IsActive],[CreatedAtUtc])
VALUES (S.FullName,S.Email,@SharedPasswordHash,S.Role,S.PhoneNumber,1,@Now);

DECLARE @SellerUaeUserId int = (SELECT TOP 1 Id FROM Users WHERE Email=N'seller.uae@goldwallet.com');
DECLARE @SellerKsaUserId int = (SELECT TOP 1 Id FROM Users WHERE Email=N'seller.ksa@goldwallet.com');
DECLARE @InvestorUaeUserId int = (SELECT TOP 1 Id FROM Users WHERE Email=N'investor.uae@goldwallet.com');
DECLARE @InvestorKsaUserId int = (SELECT TOP 1 Id FROM Users WHERE Email=N'investor.ksa@goldwallet.com');

MERGE [Sellers] AS T
USING (
    VALUES
    (@SellerUaeUserId,N'UAESELL',N'UAE Seller Metals LLC',N'CR-UAE-001',N'VAT-UAE-001',N'Precious Metals',N'+971500000101',N'seller.uae@goldwallet.com',N'UAE',N'AED'),
    (@SellerKsaUserId,N'KSASELL',N'KSA Seller Bullion Co',N'CR-KSA-001',N'VAT-KSA-001',N'Precious Metals',N'+966500000102',N'seller.ksa@goldwallet.com',N'KSA',N'SAR')
) AS S([UserId],[CompanyCode],[CompanyName],[CR],[VAT],[Activity],[Phone],[Email],[MarketType],[MarketCurrencyCode])
ON T.CompanyCode = S.CompanyCode
WHEN MATCHED THEN UPDATE SET
    T.UserId=S.UserId,T.CompanyName=S.CompanyName,T.CommercialRegistrationNumber=S.CR,T.VatNumber=S.VAT,
    T.BusinessActivity=S.Activity,T.CompanyPhone=S.Phone,T.CompanyEmail=S.Email,
    T.MarketType=S.MarketType,T.MarketCurrencyCode=S.MarketCurrencyCode,T.KycStatus=2,T.IsActive=1,T.UpdatedAtUtc=@Now,T.ReviewedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT
([UserId],[CompanyName],[CompanyCode],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[CompanyPhone],[CompanyEmail],[IsActive],[KycStatus],[MarketType],[MarketCurrencyCode],[CreatedAtUtc],[ReviewedAtUtc])
VALUES
(S.UserId,S.CompanyName,S.CompanyCode,S.CR,S.VAT,S.Activity,S.Phone,S.Email,1,2,S.MarketType,S.MarketCurrencyCode,@Now,@Now);

DECLARE @SellerUaeId int = (SELECT TOP 1 Id FROM Sellers WHERE CompanyCode=N'UAESELL');
DECLARE @SellerKsaId int = (SELECT TOP 1 Id FROM Sellers WHERE CompanyCode=N'KSASELL');

MERGE [SellerAddresses] AS T
USING (
    VALUES
    (@SellerUaeId,N'UAE',N'Dubai',N'Sheikh Zayed Rd',N'10',N'00001'),
    (@SellerKsaId,N'KSA',N'Riyadh',N'King Fahd Rd',N'20',N'11564')
) AS S([SellerId],[Country],[City],[Street],[BuildingNumber],[PostalCode])
ON T.SellerId = S.SellerId
WHEN MATCHED THEN UPDATE SET T.Country=S.Country,T.City=S.City,T.Street=S.Street,T.BuildingNumber=S.BuildingNumber,T.PostalCode=S.PostalCode,T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT ([SellerId],[Country],[City],[Street],[BuildingNumber],[PostalCode],[CreatedAtUtc])
VALUES (S.SellerId,S.Country,S.City,S.Street,S.BuildingNumber,S.PostalCode,@Now);

INSERT INTO UserProfiles ([UserId],[DateOfBirth],[Nationality],[PreferredLanguage],[PreferredTheme],[MarketType],[DocumentType],[IdNumber],[ProfilePhotoUrl],[CreatedAtUtc])
SELECT U.Id,NULL,N'Unknown',N'en',N'light',
CASE WHEN U.Id=@InvestorUaeUserId THEN N'UAE' WHEN U.Id=@InvestorKsaUserId THEN N'KSA' ELSE N'UAE' END,
N'National ID',N'',N'/images/profiles/default-user.png',@Now
FROM Users U
WHERE U.Id IN (@InvestorUaeUserId,@InvestorKsaUserId)
AND NOT EXISTS (SELECT 1 FROM UserProfiles P WHERE P.UserId=U.Id);

UPDATE UserProfiles
SET MarketType = CASE WHEN UserId=@InvestorUaeUserId THEN N'UAE' WHEN UserId=@InvestorKsaUserId THEN N'KSA' ELSE MarketType END,
    UpdatedAtUtc = @Now
WHERE UserId IN (@InvestorUaeUserId,@InvestorKsaUserId);

DECLARE @ProfileUae int = (SELECT TOP 1 Id FROM UserProfiles WHERE UserId=@InvestorUaeUserId);
DECLARE @ProfileKsa int = (SELECT TOP 1 Id FROM UserProfiles WHERE UserId=@InvestorKsaUserId);

MERGE Wallets AS T
USING (VALUES (@InvestorUaeUserId,N'AED'),(@InvestorKsaUserId,N'SAR')) AS S(UserId,CurrencyCode)
ON T.UserId=S.UserId
WHEN MATCHED THEN UPDATE SET T.CurrencyCode=S.CurrencyCode,T.CashBalance=0,T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT ([UserId],[CashBalance],[CurrencyCode],[CreatedAtUtc]) VALUES (S.UserId,0,S.CurrencyCode,@Now);

MERGE LinkedBankAccounts AS T
USING (
 VALUES
 (@ProfileUae,N'Emirates NBD',N'AE** **** **** 1001',N'Investor UAE',N'AED'),
 (@ProfileKsa,N'Al Rajhi Bank',N'SA** **** **** 2002',N'Investor KSA',N'SAR')
) AS S([UserProfileId],[BankName],[IbanMasked],[AccountHolderName],[Currency])
ON T.UserProfileId=S.UserProfileId AND T.BankName=S.BankName
WHEN MATCHED THEN UPDATE SET T.IbanMasked=S.IbanMasked,T.AccountHolderName=S.AccountHolderName,T.Currency=S.Currency,T.IsVerified=1,T.IsDefault=1,T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT ([UserProfileId],[BankName],[IbanMasked],[IsVerified],[IsDefault],[AccountHolderName],[AccountNumber],[SwiftCode],[BranchName],[BranchAddress],[Country],[City],[Currency],[CreatedAtUtc])
VALUES (S.UserProfileId,S.BankName,S.IbanMasked,1,1,S.AccountHolderName,N'',N'',N'Main',N'',N'',N'',S.Currency,@Now);

INSERT INTO PaymentMethods ([UserProfileId],[Type],[MaskedNumber],[IsDefault],[CreatedAtUtc])
SELECT X.UserProfileId,N'Visa / MasterCard',X.Masked,1,@Now
FROM (VALUES (@ProfileUae,N'**** **** **** 1201'),(@ProfileKsa,N'**** **** **** 2202')) X(UserProfileId,Masked)
WHERE NOT EXISTS (SELECT 1 FROM PaymentMethods P WHERE P.UserProfileId=X.UserProfileId AND P.Type=N'Visa / MasterCard');

-- Enforce EMPTY domain data
DELETE FROM TransactionFeeBreakdowns WHERE TransactionHistoryId IN (SELECT Id FROM TransactionHistories WHERE UserId IN (@InvestorUaeUserId,@InvestorKsaUserId));
DELETE FROM TransactionHistories WHERE UserId IN (@InvestorUaeUserId,@InvestorKsaUserId);
DELETE WA FROM WalletAssets WA INNER JOIN Wallets W ON W.Id=WA.WalletId WHERE W.UserId IN (@InvestorUaeUserId,@InvestorKsaUserId);
DELETE FROM Products WHERE SellerId IN (@SellerUaeId,@SellerKsaId);

COMMIT TRAN;

SELECT U.Email,U.Role,UP.MarketType,W.CurrencyCode
FROM Users U
LEFT JOIN UserProfiles UP ON UP.UserId=U.Id
LEFT JOIN Wallets W ON W.UserId=U.Id
WHERE U.Email IN (N'seller.uae@goldwallet.com',N'seller.ksa@goldwallet.com',N'investor.uae@goldwallet.com',N'investor.ksa@goldwallet.com')
ORDER BY U.Role,U.Email;

END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRAN;
 THROW;
END CATCH;
