/*
Seeds market users only:
- 2 sellers per market: UAE, KSA, Jordan, Egypt, India
- 2 investors per market: UAE, KSA, Jordan, Egypt, India
- full profiles
No products, no configurations, no transactions, no wallet assets.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

DECLARE @Now datetime2 = SYSUTCDATETIME();
DECLARE @SharedPasswordHash nvarchar(500) = N'NN53R1Ggd5QH71EKW6wALA==.UbTyu0VUnNi27SE8JQbIjY5d8gs3jgo+SiUsNtLtt8I=.100000';

DECLARE @Markets TABLE (MarketType nvarchar(20), CurrencyCode nvarchar(10));
INSERT INTO @Markets VALUES (N'UAE',N'AED'),(N'KSA',N'SAR'),(N'Jordan',N'JOD'),(N'Egypt',N'EGP'),(N'India',N'INR');

DECLARE @Users TABLE(FullName nvarchar(200), Email nvarchar(255), Role nvarchar(50), PhoneNumber nvarchar(50), MarketType nvarchar(20), CurrencyCode nvarchar(10), Seq int);

INSERT INTO @Users
SELECT CONCAT(N'Seller ',M.MarketType,N' ',V.Seq),
       CONCAT(LOWER(M.MarketType),N'.seller',V.Seq,N'@goldwallet.com'),
       N'Seller',CONCAT(N'+100000',ROW_NUMBER() OVER(ORDER BY M.MarketType,V.Seq)),
       M.MarketType,M.CurrencyCode,V.Seq
FROM @Markets M CROSS JOIN (VALUES (1),(2)) V(Seq)
UNION ALL
SELECT CONCAT(N'Investor ',M.MarketType,N' ',V.Seq),
       CONCAT(LOWER(M.MarketType),N'.investor',V.Seq,N'@goldwallet.com'),
       N'Investor',CONCAT(N'+200000',ROW_NUMBER() OVER(ORDER BY M.MarketType,V.Seq)),
       M.MarketType,M.CurrencyCode,V.Seq
FROM @Markets M CROSS JOIN (VALUES (1),(2)) V(Seq);

MERGE Users AS T
USING @Users AS S ON T.Email=S.Email
WHEN MATCHED THEN UPDATE SET T.FullName=S.FullName,T.PasswordHash=@SharedPasswordHash,T.Role=S.Role,T.PhoneNumber=S.PhoneNumber,T.IsActive=1,T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT ([FullName],[Email],[PasswordHash],[Role],[PhoneNumber],[IsActive],[CreatedAtUtc]) VALUES (S.FullName,S.Email,@SharedPasswordHash,S.Role,S.PhoneNumber,1,@Now);

;WITH SellerRows AS (
  SELECT U.Id AS UserId, D.MarketType, D.CurrencyCode, D.Seq,
         CompanyCode = CONCAT(UPPER(D.MarketType),N'-S',D.Seq),
         CompanyName = CONCAT(D.MarketType,N' Seller ',D.Seq,N' Metals LLC'),
         Email = D.Email,
         Phone = D.PhoneNumber
  FROM @Users D INNER JOIN Users U ON U.Email=D.Email
  WHERE D.Role=N'Seller'
)
MERGE Sellers AS T
USING SellerRows AS S ON T.CompanyCode=S.CompanyCode
WHEN MATCHED THEN UPDATE SET
  T.UserId=S.UserId,T.CompanyName=S.CompanyName,T.CompanyEmail=S.Email,T.CompanyPhone=S.Phone,
  T.CommercialRegistrationNumber=CONCAT(N'CR-',S.CompanyCode),T.VatNumber=CONCAT(N'VAT-',S.CompanyCode),
  T.BusinessActivity=N'Precious Metals Trading',T.MarketType=S.MarketType,T.MarketCurrencyCode=S.CurrencyCode,
  T.KycStatus=2,T.IsActive=1,T.ReviewedAtUtc=@Now,T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT
([UserId],[CompanyName],[CompanyCode],[CommercialRegistrationNumber],[VatNumber],[BusinessActivity],[CompanyPhone],[CompanyEmail],[IsActive],[KycStatus],[ReviewNotes],[MarketType],[MarketCurrencyCode],[CreatedAtUtc],[ReviewedAtUtc])
VALUES
(S.UserId,S.CompanyName,S.CompanyCode,CONCAT(N'CR-',S.CompanyCode),CONCAT(N'VAT-',S.CompanyCode),N'Precious Metals Trading',S.Phone,S.Email,1,2,N'Seeded market seller',S.MarketType,S.CurrencyCode,@Now,@Now);

MERGE SellerAddresses AS T
USING (
  SELECT S.Id AS SellerId, S.MarketType
  FROM Sellers S
  WHERE EXISTS (SELECT 1 FROM @Users U INNER JOIN Users US ON US.Email=U.Email WHERE U.Role=N'Seller' AND US.Id=S.UserId)
) X
ON T.SellerId=X.SellerId
WHEN MATCHED THEN UPDATE SET T.Country=X.MarketType,T.City=X.MarketType,T.Street=N'Main Street',T.BuildingNumber=N'1',T.PostalCode=N'00000',T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT ([SellerId],[Country],[City],[Street],[BuildingNumber],[PostalCode],[CreatedAtUtc]) VALUES (X.SellerId,X.MarketType,X.MarketType,N'Main Street',N'1',N'00000',@Now);

INSERT INTO UserProfiles ([UserId],[DateOfBirth],[Nationality],[PreferredLanguage],[PreferredTheme],[MarketType],[DocumentType],[IdNumber],[ProfilePhotoUrl],[CreatedAtUtc])
SELECT U.Id,NULL,N'Unknown',N'en',N'light',D.MarketType,N'National ID',CONCAT(N'ID-',U.Id),N'/images/profiles/default-user.png',@Now
FROM @Users D INNER JOIN Users U ON U.Email=D.Email
WHERE NOT EXISTS (SELECT 1 FROM UserProfiles P WHERE P.UserId=U.Id);

UPDATE P SET P.MarketType=D.MarketType,P.UpdatedAtUtc=@Now
FROM UserProfiles P
INNER JOIN Users U ON U.Id=P.UserId
INNER JOIN @Users D ON D.Email=U.Email;

MERGE Wallets AS T
USING (
 SELECT U.Id AS UserId, D.CurrencyCode
 FROM @Users D INNER JOIN Users U ON U.Email=D.Email
 WHERE D.Role=N'Investor'
) S
ON T.UserId=S.UserId
WHEN MATCHED THEN UPDATE SET T.CurrencyCode=S.CurrencyCode,T.CashBalance=0,T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT ([UserId],[CashBalance],[CurrencyCode],[CreatedAtUtc]) VALUES (S.UserId,0,S.CurrencyCode,@Now);

MERGE LinkedBankAccounts AS T
USING (
 SELECT P.Id AS UserProfileId, D.MarketType, D.CurrencyCode, D.FullName
 FROM @Users D INNER JOIN Users U ON U.Email=D.Email INNER JOIN UserProfiles P ON P.UserId=U.Id
 WHERE D.Role=N'Investor'
) S
ON T.UserProfileId=S.UserProfileId AND T.IsDefault=1
WHEN MATCHED THEN UPDATE SET T.BankName=CONCAT(S.MarketType,N' National Bank'),T.IbanMasked=CONCAT(LEFT(UPPER(S.CurrencyCode),2),N'** **** **** ',RIGHT(CAST(S.UserProfileId AS nvarchar(20)),4)),T.IsVerified=1,T.AccountHolderName=S.FullName,T.Currency=S.CurrencyCode,T.UpdatedAtUtc=@Now
WHEN NOT MATCHED THEN INSERT ([UserProfileId],[BankName],[IbanMasked],[IsVerified],[IsDefault],[AccountHolderName],[AccountNumber],[SwiftCode],[BranchName],[BranchAddress],[Country],[City],[Currency],[CreatedAtUtc])
VALUES (S.UserProfileId,CONCAT(S.MarketType,N' National Bank'),CONCAT(LEFT(UPPER(S.CurrencyCode),2),N'** **** **** ',RIGHT(CAST(S.UserProfileId AS nvarchar(20)),4)),1,1,S.FullName,N'',N'',N'Main',N'',S.MarketType,S.MarketType,S.CurrencyCode,@Now);

INSERT INTO PaymentMethods ([UserProfileId],[Type],[MaskedNumber],[IsDefault],[CreatedAtUtc])
SELECT P.Id,N'Visa / MasterCard',CONCAT(N'**** **** **** ',RIGHT(CAST(U.Id AS nvarchar(10)),4)),1,@Now
FROM @Users D INNER JOIN Users U ON U.Email=D.Email INNER JOIN UserProfiles P ON P.UserId=U.Id
WHERE D.Role=N'Investor'
AND NOT EXISTS (SELECT 1 FROM PaymentMethods PM WHERE PM.UserProfileId=P.Id AND PM.Type=N'Visa / MasterCard');

-- cleanup: keep empty trading data for seeded users/sellers
DELETE FROM TransactionFeeBreakdowns WHERE TransactionHistoryId IN (
  SELECT TH.Id FROM TransactionHistories TH INNER JOIN Users U ON U.Id=TH.UserId INNER JOIN @Users D ON D.Email=U.Email
);
DELETE TH FROM TransactionHistories TH INNER JOIN Users U ON U.Id=TH.UserId INNER JOIN @Users D ON D.Email=U.Email;
DELETE WA FROM WalletAssets WA INNER JOIN Wallets W ON W.Id=WA.WalletId INNER JOIN Users U ON U.Id=W.UserId INNER JOIN @Users D ON D.Email=U.Email;
DELETE P FROM Products P INNER JOIN Sellers S ON S.Id=P.SellerId INNER JOIN Users U ON U.Id=S.UserId INNER JOIN @Users D ON D.Email=U.Email WHERE D.Role=N'Seller';

COMMIT TRAN;

SELECT D.Role,D.MarketType,COUNT(*) AS Total
FROM @Users D
GROUP BY D.Role,D.MarketType
ORDER BY D.Role,D.MarketType;

END TRY
BEGIN CATCH
IF @@TRANCOUNT>0 ROLLBACK TRAN;
THROW;
END CATCH;
