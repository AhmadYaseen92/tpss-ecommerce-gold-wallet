using TPSS.GoldWallet.Domain.Common;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class AuditLog : Entity
{
    private AuditLog() { }

    public AuditLog(Guid? actorUserId, string action, string resource, string metadata, string ipAddress)
    {
        ActorUserId = actorUserId;
        Action = action;
        Resource = resource;
        Metadata = metadata;
        IpAddress = ipAddress;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public Guid? ActorUserId { get; private set; }
    public string Action { get; private set; } = string.Empty;
    public string Resource { get; private set; } = string.Empty;
    public string Metadata { get; private set; } = string.Empty;
    public string IpAddress { get; private set; } = string.Empty;
    public DateTime CreatedAtUtc { get; private set; }
}
