/*
Update historical transaction + fee currencies using market mapping.
- Seller-scoped rows use seller market currency.
- Investor-only rows use investor profile market currency.
Safe to run multiple times.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

;WITH TransactionCurrency AS (
    SELECT
        TH.Id,
        CurrencyCode = COALESCE(
            NULLIF(S.MarketCurrencyCode, N''),
            CASE UPPER(LTRIM(RTRIM(COALESCE(S.MarketType, UP.MarketType, N''))))
                WHEN N'UAE' THEN N'AED'
                WHEN N'KSA' THEN N'SAR'
                WHEN N'JORDAN' THEN N'JOD'
                WHEN N'EGYPT' THEN N'EGP'
                WHEN N'INDIA' THEN N'INR'
                ELSE N'USD'
            END
        )
    FROM TransactionHistories TH
    LEFT JOIN Sellers S ON S.Id = TH.SellerId
    LEFT JOIN UserProfiles UP ON UP.UserId = TH.UserId
)
UPDATE TH
SET TH.Currency = TC.CurrencyCode,
    TH.UpdatedAtUtc = SYSUTCDATETIME()
FROM TransactionHistories TH
INNER JOIN TransactionCurrency TC ON TC.Id = TH.Id
WHERE ISNULL(TH.Currency, N'') <> TC.CurrencyCode;

;WITH FeeCurrency AS (
    SELECT
        TFB.Id,
        CurrencyCode = COALESCE(
            NULLIF(S.MarketCurrencyCode, N''),
            CASE UPPER(LTRIM(RTRIM(COALESCE(S.MarketType, UP.MarketType, N''))))
                WHEN N'UAE' THEN N'AED'
                WHEN N'KSA' THEN N'SAR'
                WHEN N'JORDAN' THEN N'JOD'
                WHEN N'EGYPT' THEN N'EGP'
                WHEN N'INDIA' THEN N'INR'
                ELSE N'USD'
            END
        )
    FROM TransactionFeeBreakdowns TFB
    LEFT JOIN TransactionHistories TH ON TH.Id = TFB.TransactionHistoryId
    LEFT JOIN Sellers S ON S.Id = TH.SellerId
    LEFT JOIN UserProfiles UP ON UP.UserId = TH.UserId
)
UPDATE TFB
SET TFB.Currency = FC.CurrencyCode,
    TFB.UpdatedAtUtc = SYSUTCDATETIME()
FROM TransactionFeeBreakdowns TFB
INNER JOIN FeeCurrency FC ON FC.Id = TFB.Id
WHERE ISNULL(TFB.Currency, N'') <> FC.CurrencyCode;

COMMIT TRAN;
