namespace TPSS.GoldWallet.Infrastructure.Security;

public sealed class JwtOptions
{
    public const string SectionName = "Jwt";
    public string Issuer { get; init; } = "TPSS";
    public string Audience { get; init; } = "TPSS.Client";
    public string Key { get; init; } = "CHANGE_ME_32_CHARS_MINIMUM_SECRET_KEY";
    public int ExpiryMinutes { get; init; } = 120;
}
