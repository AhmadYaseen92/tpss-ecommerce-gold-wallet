using System.Text.RegularExpressions;

namespace GoldWalletSystem.Application.Services;

internal static partial class AuthInputValidation
{
    [GeneratedRegex(@"^\S+@\S+\.\S+$", RegexOptions.Compiled)]
    private static partial Regex EmailRegex();

    [GeneratedRegex(@"^(?:\+971|0)?5\d{8}$", RegexOptions.Compiled)]
    private static partial Regex UaeMobileRegex();

    [GeneratedRegex(@"^\+?[1-9]\d{7,14}$", RegexOptions.Compiled)]
    private static partial Regex InternationalPhoneRegex();

    [GeneratedRegex(@"^\d+$", RegexOptions.Compiled)]
    private static partial Regex NumericOnlyRegex();

    [GeneratedRegex(@"^[A-Z]{2}\d{2}[A-Z0-9]{10,30}$", RegexOptions.Compiled)]
    private static partial Regex IbanRegex();

    [GeneratedRegex(@"^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$", RegexOptions.Compiled)]
    private static partial Regex SwiftRegex();

    internal static bool IsValidEmail(string value) => EmailRegex().IsMatch(value.Trim());
    internal static bool IsValidUaeMobile(string value) => UaeMobileRegex().IsMatch(value.Trim());
    internal static bool IsValidInternationalPhone(string value) => InternationalPhoneRegex().IsMatch(NormalizePhone(value));
    internal static bool IsNumericOnly(string value) => NumericOnlyRegex().IsMatch(value.Trim());
    internal static bool IsValidIban(string value) => IbanRegex().IsMatch(value.Trim().ToUpperInvariant().Replace(" ", string.Empty));
    internal static bool IsValidSwift(string value) => SwiftRegex().IsMatch(value.Trim().ToUpperInvariant());

    private static string NormalizePhone(string value)
        => value.Trim().Replace(" ", string.Empty).Replace("-", string.Empty);
}
