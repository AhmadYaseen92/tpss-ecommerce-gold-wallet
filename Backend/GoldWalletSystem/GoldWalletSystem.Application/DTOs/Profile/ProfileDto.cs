namespace GoldWalletSystem.Application.DTOs.Profile;

public sealed record ProfileDto(
    int UserId,
    string FullName,
    string Email,
    string? PhoneNumber,
    DateOnly? DateOfBirth,
    string Nationality,
    string DocumentType,
    string IdNumber,
    string ProfilePhotoUrl,
    string PreferredLanguage,
    string PreferredTheme,
    IReadOnlyList<PaymentMethodDto> PaymentMethods,
    IReadOnlyList<LinkedBankAccountDto> LinkedBankAccounts);

public sealed record PaymentMethodDto(int Id, string Type, string MaskedNumber, bool IsDefault);
public sealed record LinkedBankAccountDto(int Id, string BankName, string IbanMasked, bool IsVerified);
