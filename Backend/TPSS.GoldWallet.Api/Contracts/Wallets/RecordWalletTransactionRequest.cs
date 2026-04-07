namespace TPSS.GoldWallet.Api.Contracts.Wallets;

public sealed record RecordWalletTransactionRequest(decimal Amount, string Type, string Reference);
