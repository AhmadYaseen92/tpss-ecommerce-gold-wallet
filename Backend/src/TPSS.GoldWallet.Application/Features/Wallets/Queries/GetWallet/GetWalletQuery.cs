using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Wallets.Queries.GetWallet;

public sealed record GetWalletQuery(Guid CustomerId) : IRequest<WalletDto>;
