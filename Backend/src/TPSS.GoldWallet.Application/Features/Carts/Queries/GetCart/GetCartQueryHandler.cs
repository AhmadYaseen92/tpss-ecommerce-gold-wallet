using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Features.Carts.Queries.GetCart;

public sealed class GetCartQueryHandler(ICartRepository cartRepository)
    : IRequestHandler<GetCartQuery, CartDto>
{
    public async Task<CartDto> Handle(GetCartQuery request, CancellationToken cancellationToken)
    {
        var cart = await cartRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken)
            ?? new Cart(request.CustomerId);

        var items = cart.Items.Select(item => new CartItemDto(
                item.ProductId,
                item.ProductName,
                item.Quantity,
                item.UnitPrice.Amount,
                item.UnitPrice.Amount * item.Quantity,
                item.UnitPrice.Currency))
            .ToList();

        return new CartDto(
            cart.CustomerId,
            items,
            items.Sum(x => x.LineTotal),
            items.FirstOrDefault()?.Currency ?? "USD");
    }
}
