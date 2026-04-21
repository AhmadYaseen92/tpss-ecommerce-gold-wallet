namespace GoldWalletSystem.Application.DTOs.Auth;

public class RegisterRequestDto
{
    public string FirstName { get; set; } = string.Empty;
    public string MiddleName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string Nationality { get; set; } = string.Empty;
    public string DocumentType { get; set; } = string.Empty;
    public string IdNumber { get; set; } = string.Empty;
    public string ProfilePhotoUrl { get; set; } = string.Empty;
    public string PreferredLanguage { get; set; } = "en";
    public string PreferredTheme { get; set; } = "light";
    public string Role { get; set; } = GoldWalletSystem.Domain.Constants.SystemRoles.Investor;

    public SellerCompanyInfoDto CompanyInfo { get; set; } = new();
    public SellerManagerDto Manager { get; set; } = new();
    public List<SellerBranchDto> Branches { get; set; } = [];
    public List<SellerBankAccountDto> BankAccounts { get; set; } = [];
    public List<SellerDocumentUploadDto> Documents { get; set; } = [];
}

public class SellerCompanyInfoDto
{
    public string CompanyName { get; set; } = string.Empty;
    public string CompanyCode { get; set; } = string.Empty;
    public string CommercialRegistrationNumber { get; set; } = string.Empty;
    public string VatNumber { get; set; } = string.Empty;
    public string BusinessActivity { get; set; } = string.Empty;
    public DateOnly? EstablishedDate { get; set; }
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Street { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
    public string CompanyPhone { get; set; } = string.Empty;
    public string CompanyEmail { get; set; } = string.Empty;
    public string? Website { get; set; }
    public string? Description { get; set; }
}

public class SellerManagerDto
{
    public string FullName { get; set; } = string.Empty;
    public string PositionTitle { get; set; } = string.Empty;
    public string Nationality { get; set; } = string.Empty;
    public string MobileNumber { get; set; } = string.Empty;
    public string EmailAddress { get; set; } = string.Empty;
    public string IdType { get; set; } = string.Empty;
    public string IdNumber { get; set; } = string.Empty;
    public DateOnly? IdExpiryDate { get; set; }
}

public class SellerBranchDto
{
    public string BranchName { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string FullAddress { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool IsMainBranch { get; set; }
}

public class SellerBankAccountDto
{
    public string BankName { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string Iban { get; set; } = string.Empty;
    public string SwiftCode { get; set; } = string.Empty;
    public string BankCountry { get; set; } = string.Empty;
    public string BankCity { get; set; } = string.Empty;
    public string BranchName { get; set; } = string.Empty;
    public string BranchAddress { get; set; } = string.Empty;
    public string Currency { get; set; } = string.Empty;
    public bool IsMainAccount { get; set; }
}

public class SellerDocumentUploadDto
{
    public string DocumentType { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public string ContentType { get; set; } = "application/octet-stream";
    public bool IsRequired { get; set; }
    public string? RelatedEntityType { get; set; }
    public int? RelatedEntityId { get; set; }
}
