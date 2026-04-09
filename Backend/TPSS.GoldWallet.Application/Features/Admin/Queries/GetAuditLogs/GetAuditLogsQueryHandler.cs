using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Admin.Queries.GetAuditLogs;

public sealed class GetAuditLogsQueryHandler(IAuditLogRepository auditLogRepository)
    : IRequestHandler<GetAuditLogsQuery, IReadOnlyList<AuditLogDto>>
{
    public async Task<IReadOnlyList<AuditLogDto>> Handle(GetAuditLogsQuery request, CancellationToken cancellationToken)
    {
        var logs = await auditLogRepository.GetLatestAsync(request.Take, cancellationToken);
        return logs.Select(x => new AuditLogDto(x.ActorUserId, x.Action, x.Resource, x.Metadata, x.IpAddress, x.CreatedAtUtc)).ToList();
    }
}
