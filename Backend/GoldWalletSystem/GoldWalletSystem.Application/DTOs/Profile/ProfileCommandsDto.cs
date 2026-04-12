namespace GoldWalletSystem.Application.DTOs.Profile;

public class UpdateProfilePersonalInfoRequestDto
{
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string Nationality { get; set; } = string.Empty;
    public string DocumentType { get; set; } = string.Empty;
    public string IdNumber { get; set; } = string.Empty;
    public string ProfilePhotoUrl { get; set; } = string.Empty;
}

public class UpdateProfileSettingsRequestDto
{
    public int UserId { get; set; }
    public string PreferredLanguage { get; set; } = "en";
    public string PreferredTheme { get; set; } = "light";
}

public class UpdatePasswordRequestDto
{
    public int UserId { get; set; }
    public string CurrentPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

public class UpsertPaymentMethodRequestDto
{
    public int UserId { get; set; }
    public int? PaymentMethodId { get; set; }
    public string Type { get; set; } = string.Empty;
    public string MaskedNumber { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
}

public class UpsertLinkedBankAccountRequestDto
{
    public int UserId { get; set; }
    public int? LinkedBankAccountId { get; set; }
    public string BankName { get; set; } = string.Empty;
    public string IbanMasked { get; set; } = string.Empty;
    public bool IsVerified { get; set; }
}
