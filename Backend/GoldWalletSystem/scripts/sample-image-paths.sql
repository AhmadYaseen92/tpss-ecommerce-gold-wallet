-- Sample SQL data with image paths for GoldWalletSystem
-- NOTE:
-- 1) This system stores image locations in DB columns as text URLs/paths.
-- 2) There is no built-in upload endpoint/static file mapping in current API Program.cs.
-- 3) So these values are "saved" in DB, not physically uploaded by backend code.

-- Product image paths (stored in Products.ImageUrl)
UPDATE [Products]
SET [ImageUrl] = '/images/products/gold-bar-1oz.jpg'
WHERE [Sku] = 'SKU-01-001';

UPDATE [Products]
SET [ImageUrl] = '/images/products/silver-bar-1kg.jpg'
WHERE [Sku] = 'SKU-01-006';

UPDATE [Products]
SET [ImageUrl] = 'https://cdn.example.com/products/platinum-coin-1oz.png'
WHERE [Sku] = 'SKU-02-011';

-- User profile image path (stored in UserProfiles.ProfilePhotoUrl)
UPDATE [UserProfiles]
SET [ProfilePhotoUrl] = '/images/profiles/user-1001.jpg'
WHERE [UserId] = 1001;

-- Home carousel image paths (stored in MobileAppConfigurations.JsonValue)
IF EXISTS (SELECT 1 FROM [MobileAppConfigurations] WHERE [ConfigKey] = N'home.carousel.images')
BEGIN
    UPDATE [MobileAppConfigurations]
    SET [JsonValue] = N'[
        "https://cdn.example.com/banners/banner-1.webp",
        "/images/banners/banner-2.jpg",
        "/images/banners/banner-3.jpg"
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
            N'["https://cdn.example.com/banners/banner-1.webp","/images/banners/banner-2.jpg","/images/banners/banner-3.jpg"]',
            1,
            N'Home carousel image paths',
            GETUTCDATE(),
            GETUTCDATE()
        );
END;
