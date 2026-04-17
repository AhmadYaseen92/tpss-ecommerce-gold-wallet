-- Sample verification queries for transfer/gift flows.
-- Use this script after running a wallet action to verify sender debit,
-- recipient credit, portfolio totals, and transaction metadata.

DECLARE @RequestId INT = 9;          -- r-9 => 9
DECLARE @SenderUserId INT = 10;      -- i-10 => 10
DECLARE @RecipientUserId INT = 11;   -- recipient investor user id

/* 1) Load the transfer/gift transaction details by request id */
SELECT
    th.Id,
    th.UserId,
    th.TransactionType,
    th.Status,
    th.Category,
    th.Quantity,
    th.Weight,
    th.UnitPrice,
    th.Amount,
    th.Currency,
    th.Notes,
    th.CreatedAtUtc,
    th.UpdatedAtUtc
FROM TransactionHistories th
WHERE th.Id = @RequestId
ORDER BY th.CreatedAtUtc DESC;

/* 2) Check sender and recipient wallets + live portfolio value */
SELECT
    w.UserId,
    w.CurrencyCode,
    w.CashBalance,
    ISNULL(SUM(wa.Quantity), 0) AS TotalUnits,
    ISNULL(SUM(wa.Weight), 0) AS TotalWeight,
    ISNULL(SUM(wa.CurrentMarketPrice * wa.Quantity), 0) AS PortfolioValue
FROM Wallets w
LEFT JOIN WalletAssets wa ON wa.WalletId = w.Id
WHERE w.UserId IN (@SenderUserId, @RecipientUserId)
GROUP BY w.UserId, w.CurrencyCode, w.CashBalance
ORDER BY w.UserId;

/* 3) Check recipient wallet assets to confirm received item is present */
SELECT
    wa.Id AS WalletAssetId,
    wa.WalletId,
    wa.SellerId,
    wa.SellerName,
    wa.Category,
    wa.AssetType,
    wa.Quantity,
    wa.Weight,
    wa.Unit,
    wa.Purity,
    wa.AverageBuyPrice,
    wa.CurrentMarketPrice,
    wa.CreatedAtUtc,
    wa.UpdatedAtUtc
FROM WalletAssets wa
INNER JOIN Wallets w ON w.Id = wa.WalletId
WHERE w.UserId = @RecipientUserId
ORDER BY wa.UpdatedAtUtc DESC, wa.Id DESC;

/* 4) Show sender + recipient transfer/gift history timeline */
SELECT
    th.Id,
    th.UserId,
    u.FullName AS InvestorName,
    th.TransactionType,
    th.Status,
    th.Category,
    th.Quantity,
    th.Weight,
    th.UnitPrice,
    th.Amount,
    th.Currency,
    th.Notes,
    th.CreatedAtUtc
FROM TransactionHistories th
INNER JOIN Users u ON u.Id = th.UserId
WHERE th.UserId IN (@SenderUserId, @RecipientUserId)
  AND th.TransactionType IN ('transfer', 'gift')
ORDER BY th.CreatedAtUtc DESC, th.Id DESC;

/* 5) Optional: extract metadata from notes for quick auditing */
SELECT
    th.Id,
    th.UserId,
    CASE
        WHEN CHARINDEX('recipient_investor_user_id=', th.Notes) > 0
            THEN SUBSTRING(
                th.Notes,
                CHARINDEX('recipient_investor_user_id=', th.Notes) + LEN('recipient_investor_user_id='),
                CHARINDEX('|', th.Notes + '|', CHARINDEX('recipient_investor_user_id=', th.Notes))
                - (CHARINDEX('recipient_investor_user_id=', th.Notes) + LEN('recipient_investor_user_id='))
            )
        ELSE NULL
    END AS RecipientInvestorUserId,
    CASE
        WHEN CHARINDEX('from_investor_name=', th.Notes) > 0
            THEN SUBSTRING(
                th.Notes,
                CHARINDEX('from_investor_name=', th.Notes) + LEN('from_investor_name='),
                CHARINDEX('|', th.Notes + '|', CHARINDEX('from_investor_name=', th.Notes))
                - (CHARINDEX('from_investor_name=', th.Notes) + LEN('from_investor_name='))
            )
        ELSE NULL
    END AS GiftFromInvestorName,
    th.Notes
FROM TransactionHistories th
WHERE th.Id = @RequestId
   OR (th.UserId = @RecipientUserId AND th.TransactionType IN ('transfer', 'gift'))
ORDER BY th.CreatedAtUtc DESC;
