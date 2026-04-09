namespace TPSS.GoldWallet.Application.DTOs;

public sealed record AuthTokenDto(string AccessToken, DateTime ExpiresAtUtc, string Role);
