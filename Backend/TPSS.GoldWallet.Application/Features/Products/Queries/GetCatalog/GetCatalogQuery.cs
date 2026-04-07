using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Products.Queries.GetCatalog;

public sealed record GetCatalogQuery : IRequest<IReadOnlyList<ProductDto>>;
