/* Seller registration / KYC normalization migration */
BEGIN TRANSACTION;

IF COL_LENGTH('Sellers', 'CompanyCode') IS NULL
BEGIN
  EXEC sp_rename 'Sellers.Code', 'CompanyCode', 'COLUMN';
END;

IF COL_LENGTH('Sellers', 'CommercialRegistrationNumber') IS NULL
BEGIN
  EXEC sp_rename 'Sellers.TradeLicenseNumber', 'CommercialRegistrationNumber', 'COLUMN';
END;

IF COL_LENGTH('Sellers', 'CompanyPhone') IS NULL
BEGIN
  ALTER TABLE Sellers ADD CompanyPhone nvarchar(50) NULL;
  UPDATE Sellers SET CompanyPhone = ContactPhone;
  ALTER TABLE Sellers ALTER COLUMN CompanyPhone nvarchar(50) NOT NULL;
END;

IF COL_LENGTH('Sellers', 'CompanyEmail') IS NULL
BEGIN
  ALTER TABLE Sellers ADD CompanyEmail nvarchar(200) NULL;
  UPDATE Sellers SET CompanyEmail = ContactEmail;
  ALTER TABLE Sellers ALTER COLUMN CompanyEmail nvarchar(200) NOT NULL;
END;

IF COL_LENGTH('Sellers', 'BusinessActivity') IS NULL ALTER TABLE Sellers ADD BusinessActivity nvarchar(150) NOT NULL DEFAULT('');
IF COL_LENGTH('Sellers', 'EstablishedDate') IS NULL ALTER TABLE Sellers ADD EstablishedDate date NULL;
IF COL_LENGTH('Sellers', 'Website') IS NULL ALTER TABLE Sellers ADD Website nvarchar(250) NULL;
IF COL_LENGTH('Sellers', 'Description') IS NULL ALTER TABLE Sellers ADD Description nvarchar(2000) NULL;

IF OBJECT_ID('SellerAddresses') IS NULL
CREATE TABLE SellerAddresses (
  Id int identity(1,1) primary key,
  SellerId int not null unique,
  Country nvarchar(80) not null,
  City nvarchar(80) not null,
  Street nvarchar(150) not null,
  BuildingNumber nvarchar(30) not null,
  PostalCode nvarchar(30) not null,
  CreatedAtUtc datetime2 not null,
  UpdatedAtUtc datetime2 null,
  CONSTRAINT FK_SellerAddresses_Sellers_SellerId FOREIGN KEY (SellerId) REFERENCES Sellers(Id) ON DELETE CASCADE
);

IF OBJECT_ID('SellerManagers') IS NULL
CREATE TABLE SellerManagers (
  Id int identity(1,1) primary key,
  SellerId int not null,
  FullName nvarchar(150) not null,
  PositionTitle nvarchar(100) not null,
  Nationality nvarchar(80) not null,
  MobileNumber nvarchar(50) not null,
  EmailAddress nvarchar(200) not null,
  IdType nvarchar(50) not null,
  IdNumber nvarchar(100) not null,
  IdExpiryDate date null,
  IsPrimary bit not null,
  CreatedAtUtc datetime2 not null,
  UpdatedAtUtc datetime2 null,
  CONSTRAINT FK_SellerManagers_Sellers_SellerId FOREIGN KEY (SellerId) REFERENCES Sellers(Id) ON DELETE CASCADE
);

IF OBJECT_ID('SellerBranches') IS NULL
CREATE TABLE SellerBranches (
  Id int identity(1,1) primary key,
  SellerId int not null,
  BranchName nvarchar(150) not null,
  Country nvarchar(80) not null,
  City nvarchar(80) not null,
  FullAddress nvarchar(250) not null,
  BuildingNumber nvarchar(30) not null,
  PostalCode nvarchar(30) not null,
  PhoneNumber nvarchar(50) not null,
  Email nvarchar(200) not null,
  IsMainBranch bit not null,
  CreatedAtUtc datetime2 not null,
  UpdatedAtUtc datetime2 null,
  CONSTRAINT FK_SellerBranches_Sellers_SellerId FOREIGN KEY (SellerId) REFERENCES Sellers(Id) ON DELETE CASCADE
);

IF OBJECT_ID('SellerBankAccounts') IS NULL
CREATE TABLE SellerBankAccounts (
  Id int identity(1,1) primary key,
  SellerId int not null,
  BankName nvarchar(150) not null,
  AccountHolderName nvarchar(150) not null,
  AccountNumber nvarchar(100) not null,
  IBAN nvarchar(100) not null,
  SwiftCode nvarchar(50) not null,
  BankCountry nvarchar(80) not null,
  BankCity nvarchar(80) not null,
  BranchName nvarchar(120) not null,
  BranchAddress nvarchar(250) not null,
  Currency nvarchar(10) not null,
  IsMainAccount bit not null,
  CreatedAtUtc datetime2 not null,
  UpdatedAtUtc datetime2 null,
  CONSTRAINT FK_SellerBankAccounts_Sellers_SellerId FOREIGN KEY (SellerId) REFERENCES Sellers(Id) ON DELETE CASCADE
);

IF OBJECT_ID('SellerDocuments') IS NULL
CREATE TABLE SellerDocuments (
  Id int identity(1,1) primary key,
  SellerId int not null,
  DocumentType nvarchar(100) not null,
  FileName nvarchar(255) not null,
  FilePath nvarchar(500) not null,
  ContentType nvarchar(150) not null,
  IsRequired bit not null,
  UploadedAtUtc datetime2 not null,
  RelatedEntityType nvarchar(50) null,
  RelatedEntityId int null,
  CreatedAtUtc datetime2 not null,
  UpdatedAtUtc datetime2 null,
  CONSTRAINT FK_SellerDocuments_Sellers_SellerId FOREIGN KEY (SellerId) REFERENCES Sellers(Id) ON DELETE CASCADE
);

COMMIT TRANSACTION;
