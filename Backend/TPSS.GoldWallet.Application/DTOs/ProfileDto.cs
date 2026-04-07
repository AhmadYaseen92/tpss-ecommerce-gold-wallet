using TPSS.GoldWallet.Domain.Enums;

namespace TPSS.GoldWallet.Application.DTOs;

public sealed record ProfileDto(Guid Id, string Email, string FirstName, string LastName, string CountryCode, KycStatus KycStatus);
