using System.ComponentModel.DataAnnotations;

namespace GoldWalletSystem.Application.DTOs.Profile;

public class UpdateProfilePersonalInfoRequestDto
{
    [Required]
    public int UserId { get; set; }
    [Required]
    [MinLength(3)]
    [MaxLength(120)]
    public string FullName { get; set; } = string.Empty;
    [Required]
    [EmailAddress]
    [MaxLength(256)]
    public string Email { get; set; } = string.Empty;
    [Required]
    [RegularExpression(@"^[+0-9]{8,15}$")]
    public string? PhoneNumber { get; set; }
    [Required]
    public DateOnly? DateOfBirth { get; set; }
    [Required]
    [MinLength(2)]
    [MaxLength(80)]
    public string Nationality { get; set; } = string.Empty;
    [Required]
    [MinLength(2)]
    [MaxLength(80)]
    public string DocumentType { get; set; } = string.Empty;
    [Required]
    [RegularExpression(@"^[A-Za-z0-9-]{4,30}$")]
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
    [Required]
    public int UserId { get; set; }
    public int? PaymentMethodId { get; set; }
    [Required]
    [MinLength(2)]
    [MaxLength(60)]
    public string Type { get; set; } = string.Empty;
    [Required]
    [MinLength(4)]
    [MaxLength(128)]
    public string MaskedNumber { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
}

public class UpsertLinkedBankAccountRequestDto
{
    [Required]
    public int UserId { get; set; }
    public int? LinkedBankAccountId { get; set; }
    [Required]
    [MinLength(2)]
    [MaxLength(120)]
    public string BankName { get; set; } = string.Empty;
    [Required]
    [RegularExpression(@"^[A-Z]{2}[A-Z0-9]{13,32}$")]
    public string IbanMasked { get; set; } = string.Empty;
    public bool IsVerified { get; set; }
}
