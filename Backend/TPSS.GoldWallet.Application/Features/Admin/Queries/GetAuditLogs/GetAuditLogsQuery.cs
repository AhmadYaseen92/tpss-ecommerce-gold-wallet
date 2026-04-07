using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Admin.Queries.GetAuditLogs;

public sealed record GetAuditLogsQuery(int Take = 100) : IRequest<IReadOnlyList<AuditLogDto>>;
