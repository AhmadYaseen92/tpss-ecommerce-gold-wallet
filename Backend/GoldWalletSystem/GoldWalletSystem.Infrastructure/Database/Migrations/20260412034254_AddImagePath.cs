using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    // Compatibility migration for environments that already contain
    // MobileAppConfigurations from InitialCreate.
    public partial class AddImagePath : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF COL_LENGTH('Products', 'ImageUrl') IS NULL
BEGIN
    ALTER TABLE [Products] ADD [ImageUrl] nvarchar(1000) NOT NULL CONSTRAINT [DF_Products_ImageUrl] DEFAULT N'';
END;
");

            migrationBuilder.Sql(@"
IF OBJECT_ID(N'[MobileAppConfigurations]') IS NULL
BEGIN
    CREATE TABLE [MobileAppConfigurations] (
        [Id] int NOT NULL IDENTITY,
        [ConfigKey] nvarchar(150) NOT NULL,
        [JsonValue] nvarchar(max) NOT NULL,
        [IsEnabled] bit NOT NULL,
        [Description] nvarchar(500) NOT NULL,
        [CreatedAtUtc] datetime2 NOT NULL,
        [UpdatedAtUtc] datetime2 NULL,
        CONSTRAINT [PK_MobileAppConfigurations] PRIMARY KEY ([Id])
    );
END;
");

            migrationBuilder.Sql(@"
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_MobileAppConfigurations_ConfigKey'
      AND object_id = OBJECT_ID(N'[MobileAppConfigurations]')
)
BEGIN
    CREATE UNIQUE INDEX [IX_MobileAppConfigurations_ConfigKey]
    ON [MobileAppConfigurations]([ConfigKey]);
END;
");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Keep backward compatibility; no destructive down for shared objects.
        }
    }
}
