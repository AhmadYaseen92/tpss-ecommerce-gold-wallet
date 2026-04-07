namespace TPSS.GoldWallet.Application.DTOs;

public sealed record AuditLogDto(Guid? ActorUserId, string Action, string Resource, string Metadata, string IpAddress, DateTime CreatedAtUtc);
