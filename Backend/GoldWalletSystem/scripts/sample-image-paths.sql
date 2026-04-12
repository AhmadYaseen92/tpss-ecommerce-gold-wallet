-- Sample SQL data with image paths for GoldWalletSystem
-- NOTE:
-- 1) This system stores image locations in DB columns as text URLs/paths.
-- 2) The API serves static files from wwwroot via app.UseStaticFiles().
-- 3) So these values are "saved" in DB, not physically uploaded by backend code.

-- Product image paths (stored in Products.ImageUrl)
UPDATE [Products]
SET [ImageUrl] = '/images/products/gold-bar.png'
WHERE [Sku] = 'SKU-01-001';

UPDATE [Products]
SET [ImageUrl] = '/images/products/silver.png'
WHERE [Sku] = 'SKU-01-006';

UPDATE [Products]
SET [ImageUrl] = '/images/products/gold-coin.png'
WHERE [Sku] = 'SKU-02-011';

-- User profile image path (stored in UserProfiles.ProfilePhotoUrl)
UPDATE [UserProfiles]
SET [ProfilePhotoUrl] = '/images/profiles/default-user.png'
WHERE [UserId] = 1001;

-- Home carousel image paths (stored in MobileAppConfigurations.JsonValue)
IF EXISTS (SELECT 1 FROM [MobileAppConfigurations] WHERE [ConfigKey] = N'home.carousel.images')
BEGIN
    UPDATE [MobileAppConfigurations]
    SET [JsonValue] = N'[
        "/images/banners/banner-1.png",
        "/images/banners/banner-2.png",
        "/images/banners/banner-3.png"
    ]'
    WHERE [ConfigKey] = N'home.carousel.images';
END
ELSE
BEGIN
    INSERT INTO [MobileAppConfigurations]
        ([ConfigKey], [JsonValue], [IsEnabled], [Description], [CreatedAtUtc], [UpdatedAtUtc])
    VALUES
        (
            N'home.carousel.images',
            N'["/images/banners/banner-1.png","/images/banners/banner-2.png","/images/banners/banner-3.png"]',
            1,
            N'Home carousel image paths',
            GETUTCDATE(),
            GETUTCDATE()
        );
END;
