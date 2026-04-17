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
    public int? SellerId { get; set; }

    public string SellerCode { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Street { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
    public string CompanyName { get; set; } = string.Empty;
    public string TradeLicenseNumber { get; set; } = string.Empty;
    public string VatNumber { get; set; } = string.Empty;
    public string NationalIdNumber { get; set; } = string.Empty;
    public string BankName { get; set; } = string.Empty;
    public string Iban { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;
    public string NationalIdFrontPath { get; set; } = string.Empty;
    public string NationalIdBackPath { get; set; } = string.Empty;
    public string TradeLicensePath { get; set; } = string.Empty;
}
