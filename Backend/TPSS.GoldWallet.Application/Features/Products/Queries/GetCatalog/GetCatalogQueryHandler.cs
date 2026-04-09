using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Products.Queries.GetCatalog;

public sealed class GetCatalogQueryHandler(IProductRepository productRepository)
    : IRequestHandler<GetCatalogQuery, IReadOnlyList<ProductDto>>
{
    public async Task<IReadOnlyList<ProductDto>> Handle(GetCatalogQuery request, CancellationToken cancellationToken)
    {
        var products = await productRepository.GetActiveAsync(cancellationToken);

        return products
            .Select(product => new ProductDto(
                product.Id,
                product.Sku,
                product.Name,
                product.Description,
                product.Price.Amount,
                product.Price.Currency))
            .ToList();
    }
}
