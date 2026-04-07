using MediatR;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Domain.Enums;

namespace TPSS.GoldWallet.Application.Features.Wallets.Commands.RecordTransaction;

public sealed record RecordTransactionCommand(Guid CustomerId, decimal Amount, WalletTransactionType Type, string Reference) : IRequest<WalletDto>;
