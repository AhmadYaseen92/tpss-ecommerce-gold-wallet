-- PostgreSQL initialization script for TPSS Gold Wallet backend.
-- Run: psql -h localhost -U postgres -d gold_wallet -f Backend/scripts/001_init_schema.sql

CREATE TABLE IF NOT EXISTS "UserProfiles" (
    "Id" uuid PRIMARY KEY,
    "Email" varchar(256) NOT NULL UNIQUE,
    "FirstName" varchar(128) NOT NULL,
    "LastName" varchar(128) NOT NULL,
    "CountryCode" varchar(8) NOT NULL,
    "KycStatus" integer NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL
);

CREATE TABLE IF NOT EXISTS "Products" (
    "Id" uuid PRIMARY KEY,
    "Sku" varchar(32) NOT NULL,
    "Name" varchar(256) NOT NULL,
    "Description" text NOT NULL,
    "Price" numeric(18,2) NOT NULL,
    "Currency" varchar(8) NOT NULL,
    "IsActive" boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS "Carts" (
    "Id" uuid PRIMARY KEY,
    "CustomerId" uuid NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS "CartItems" (
    "Id" uuid PRIMARY KEY,
    "ProductId" uuid NOT NULL,
    "ProductName" varchar(256) NOT NULL,
    "UnitPrice" numeric(18,2) NOT NULL,
    "UnitCurrency" varchar(8) NOT NULL,
    "Quantity" integer NOT NULL,
    "CartId" uuid NOT NULL REFERENCES "Carts"("Id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "WalletAccounts" (
    "Id" uuid PRIMARY KEY,
    "CustomerId" uuid NOT NULL UNIQUE,
    "Currency" varchar(8) NOT NULL,
    "Balance" numeric(18,2) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL
);

CREATE TABLE IF NOT EXISTS "WalletTransactions" (
    "Id" uuid PRIMARY KEY,
    "WalletAccountId" uuid NOT NULL REFERENCES "WalletAccounts"("Id") ON DELETE CASCADE,
    "Amount" numeric(18,2) NOT NULL,
    "Currency" varchar(8) NOT NULL,
    "Type" integer NOT NULL,
    "Reference" varchar(256) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL
);

CREATE TABLE IF NOT EXISTS "KycVerifications" (
    "Id" uuid PRIMARY KEY,
    "CustomerId" uuid NOT NULL,
    "DocumentType" varchar(64) NOT NULL,
    "DocumentNumber" varchar(128) NOT NULL,
    "Provider" varchar(64) NOT NULL,
    "Status" integer NOT NULL,
    "SubmittedAtUtc" timestamp with time zone NOT NULL,
    "ReviewedAtUtc" timestamp with time zone NULL
);

CREATE TABLE IF NOT EXISTS "AuditLogs" (
    "Id" uuid PRIMARY KEY,
    "ActorUserId" uuid NULL,
    "Action" varchar(128) NOT NULL,
    "Resource" varchar(128) NOT NULL,
    "Metadata" text NOT NULL,
    "IpAddress" varchar(64) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL
);

CREATE INDEX IF NOT EXISTS "IX_AuditLogs_CreatedAtUtc" ON "AuditLogs"("CreatedAtUtc");
CREATE INDEX IF NOT EXISTS "IX_KycVerifications_CustomerId" ON "KycVerifications"("CustomerId");

CREATE TABLE IF NOT EXISTS "Notifications" (
    "Id" uuid PRIMARY KEY,
    "CustomerId" uuid NOT NULL,
    "Title" varchar(256) NOT NULL,
    "Description" text NOT NULL,
    "Category" varchar(64) NOT NULL,
    "IsRead" boolean NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL
);

CREATE TABLE IF NOT EXISTS "AccountSummaries" (
    "Id" uuid PRIMARY KEY,
    "CustomerId" uuid NOT NULL,
    "HoldMarketValue" numeric(18,2) NOT NULL,
    "GoldValue" numeric(18,2) NOT NULL,
    "SilverValue" numeric(18,2) NOT NULL,
    "JewelleryValue" numeric(18,2) NOT NULL,
    "AvailableCash" numeric(18,2) NOT NULL,
    "UsdtBalance" numeric(18,2) NOT NULL,
    "EDirhamBalance" numeric(18,2) NOT NULL,
    "CreatedAtUtc" timestamp with time zone NOT NULL
);

CREATE TABLE IF NOT EXISTS "TradeTransactions" (
    "Id" uuid PRIMARY KEY,
    "CustomerId" uuid NOT NULL,
    "Title" varchar(128) NOT NULL,
    "Type" varchar(32) NOT NULL,
    "Status" varchar(32) NOT NULL,
    "DateUtc" timestamp with time zone NOT NULL,
    "Amount" varchar(64) NOT NULL,
    "SellerName" varchar(128) NOT NULL,
    "SecondaryAmount" varchar(64) NULL
);

CREATE INDEX IF NOT EXISTS "IX_Notifications_CustomerId" ON "Notifications"("CustomerId");
CREATE INDEX IF NOT EXISTS "IX_AccountSummaries_CustomerId" ON "AccountSummaries"("CustomerId");
CREATE INDEX IF NOT EXISTS "IX_TradeTransactions_CustomerId" ON "TradeTransactions"("CustomerId");
