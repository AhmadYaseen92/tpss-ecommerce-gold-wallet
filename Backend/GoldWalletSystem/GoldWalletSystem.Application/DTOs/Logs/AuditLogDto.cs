namespace GoldWalletSystem.Application.DTOs.Logs;

public sealed record AuditLogDto(int Id, int? UserId, string Action, string EntityName, int? EntityId, string Details, DateTime CreatedAtUtc);
