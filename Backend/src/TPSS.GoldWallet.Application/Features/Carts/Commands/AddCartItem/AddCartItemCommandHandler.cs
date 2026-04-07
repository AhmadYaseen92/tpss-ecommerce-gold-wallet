using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Features.Carts.Commands.AddCartItem;

public sealed class AddCartItemCommandHandler(
    ICartRepository cartRepository,
    IProductRepository productRepository,
    IUnitOfWork unitOfWork)
    : IRequestHandler<AddCartItemCommand, CartDto>
{
    public async Task<CartDto> Handle(AddCartItemCommand request, CancellationToken cancellationToken)
    {
        var product = await productRepository.GetByIdAsync(request.ProductId, cancellationToken)
                      ?? throw new InvalidOperationException("Product was not found.");

        if (!product.IsActive)
        {
            throw new InvalidOperationException("Product is inactive.");
        }

        var cart = await cartRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken);
        if (cart is null)
        {
            cart = new Cart(request.CustomerId);
            await cartRepository.AddAsync(cart, cancellationToken);
        }

        cart.AddItem(product, request.Quantity);
        cartRepository.Update(cart);

        await unitOfWork.SaveChangesAsync(cancellationToken);

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
