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

public sealed record PaymentMethodDto(
    int Id,
    string Type,
    string MaskedNumber,
    bool IsDefault,
    string HolderName,
    string Expiry,
    string CardNumber,
    string ApplePayToken,
    string WalletProvider,
    string WalletNumber,
    string CliqAlias,
    string CliqBankName);
public sealed record LinkedBankAccountDto(
    int Id,
    string BankName,
    string IbanMasked,
    bool IsVerified,
    bool IsDefault,
    string AccountHolderName,
    string AccountNumber,
    string SwiftCode,
    string BranchName,
    string BranchAddress,
    string Country,
    string City,
    string Currency);
