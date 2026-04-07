using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Features.Kyc.Commands.SubmitKyc;

public sealed class SubmitKycCommandHandler(
    IKycRepository kycRepository,
    IAuditLogRepository auditLogRepository,
    IUnitOfWork unitOfWork)
    : IRequestHandler<SubmitKycCommand, Guid>
{
    public async Task<Guid> Handle(SubmitKycCommand request, CancellationToken cancellationToken)
    {
        var item = new KycVerification(request.CustomerId, request.DocumentType, request.DocumentNumber, request.Provider);
        await kycRepository.AddAsync(item, cancellationToken);
        await auditLogRepository.AddAsync(new AuditLog(request.CustomerId, "kyc.submitted", "kyc", request.DocumentType, "system"), cancellationToken);

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return item.Id;
    }
}
