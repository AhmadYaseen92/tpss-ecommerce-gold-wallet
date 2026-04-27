IF COL_LENGTH('dbo.Products', 'VideoUrl') IS NULL
BEGIN
    ALTER TABLE dbo.Products
    ADD VideoUrl nvarchar(1000) NOT NULL CONSTRAINT DF_Products_VideoUrl DEFAULT(N'');
END

IF NOT EXISTS (
    SELECT 1
    FROM dbo.MobileAppConfigurations
    WHERE ConfigKey = N'Product_VideoMaxDurationSeconds'
)
BEGIN
    INSERT INTO dbo.MobileAppConfigurations
    (
        ConfigKey,
        Name,
        Description,
        ValueType,
        ValueBool,
        ValueInt,
        ValueDecimal,
        ValueString,
        SellerAccess,
        CreatedAtUtc
    )
    VALUES
    (
        N'Product_VideoMaxDurationSeconds',
        N'Product Video Max Duration Seconds',
        N'Max allowed uploaded product video duration in seconds',
        3,
        NULL,
        30,
        NULL,
        NULL,
        0,
        SYSUTCDATETIME()
    );
END
