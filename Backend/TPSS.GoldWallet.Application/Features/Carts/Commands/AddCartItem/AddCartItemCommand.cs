using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Carts.Commands.AddCartItem;

public sealed record AddCartItemCommand(Guid CustomerId, Guid ProductId, int Quantity) : IRequest<CartDto>;
