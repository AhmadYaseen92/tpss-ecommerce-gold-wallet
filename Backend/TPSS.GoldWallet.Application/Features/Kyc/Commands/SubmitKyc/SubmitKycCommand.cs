using MediatR;

namespace TPSS.GoldWallet.Application.Features.Kyc.Commands.SubmitKyc;

public sealed record SubmitKycCommand(Guid CustomerId, string DocumentType, string DocumentNumber, string Provider) : IRequest<Guid>;
