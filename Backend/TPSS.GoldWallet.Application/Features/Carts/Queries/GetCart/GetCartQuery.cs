using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Carts.Queries.GetCart;

public sealed record GetCartQuery(Guid CustomerId) : IRequest<CartDto>;
