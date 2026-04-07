namespace TPSS.GoldWallet.Application.DTOs;

public sealed record AccountSummaryDto(decimal HoldMarketValue, decimal GoldValue, decimal SilverValue, decimal JewelleryValue, decimal AvailableCash, decimal UsdtBalance, decimal EDirhamBalance);
