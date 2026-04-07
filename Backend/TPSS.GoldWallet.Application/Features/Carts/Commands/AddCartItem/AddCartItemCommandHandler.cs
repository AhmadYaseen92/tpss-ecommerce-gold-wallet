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

        var items = cart.Items.ToList();
        var existing = items.SingleOrDefault(x => x.ProductId == request.ProductId);

        if (existing is null)
        {
            items.Add(new CartItem(product.Id, product.Name, product.Price, request.Quantity));
        }
        else
        {
            items.Remove(existing);
            items.Add(new CartItem(existing.ProductId, existing.ProductName, existing.UnitPrice, existing.Quantity + request.Quantity));
        }

        cart.ReplaceItems(items);
        cartRepository.Update(cart);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return ToDto(cart);
    }

    private static CartDto ToDto(Cart cart)
    {
        var lines = cart.Items
            .Select(item => new CartItemDto(
                item.ProductId,
                item.ProductName,
                item.Quantity,
                item.UnitPrice.Amount,
                item.UnitPrice.Amount * item.Quantity,
                item.UnitPrice.Currency))
            .ToList();

        return new CartDto(
            cart.CustomerId,
            lines,
            lines.Sum(x => x.LineTotal),
            lines.FirstOrDefault()?.Currency ?? "USD");
    }
}
