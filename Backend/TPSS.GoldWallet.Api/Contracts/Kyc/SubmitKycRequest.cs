namespace TPSS.GoldWallet.Api.Contracts.Kyc;

public sealed record SubmitKycRequest(string DocumentType, string DocumentNumber, string Provider);
