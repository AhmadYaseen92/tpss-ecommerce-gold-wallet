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

        return new CartDto(
            cart.CustomerId,
            cart.Items.Select(item => new CartItemDto(
                    item.ProductId,
                    item.ProductName,
                    item.Quantity,
                    item.UnitPrice.Amount,
                    item.LineTotal.Amount,
                    item.UnitPrice.Currency))
                .ToList(),
            cart.Subtotal.Amount,
            cart.Items.FirstOrDefault()?.UnitPrice.Currency ?? "USD");
    }
}
