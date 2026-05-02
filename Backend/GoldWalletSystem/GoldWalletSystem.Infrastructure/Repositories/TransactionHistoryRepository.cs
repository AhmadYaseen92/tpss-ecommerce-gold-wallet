using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Transactions;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class TransactionHistoryRepository(AppDbContext dbContext) : ITransactionHistoryReadRepository
{
    public Task<PagedResult<TransactionHistoryDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => FilterAsync(new TransactionHistoryFilterRequestDto
        {
            UserId = userId,
            PageNumber = pageNumber,
            PageSize = pageSize,
        }, cancellationToken);

    public async Task<PagedResult<TransactionHistoryDto>> FilterAsync(TransactionHistoryFilterRequestDto request, CancellationToken cancellationToken = default)
    {
        var query = dbContext.TransactionHistories
            .AsNoTracking()
            .AsQueryable();

        if (request.SellerId.HasValue)
        {
            query = query.Where(x => x.SellerId == request.SellerId.Value);
        }
        else
        {
            query = query.Where(x => x.UserId == request.UserId);
        }

        if (!string.IsNullOrWhiteSpace(request.TransactionType))
        {
            var type = request.TransactionType.Trim();
            query = query.Where(x => x.TransactionType == type);
        }
        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = request.Status.Trim();
            query = query.Where(x => x.Status == status);
        }
        if (!string.IsNullOrWhiteSpace(request.Category))
        {
            var category = request.Category.Trim();
            query = query.Where(x => x.Category == category);
        }

        if (request.DateFromUtc is DateTime dateFromUtc)
            query = query.Where(x => x.CreatedAtUtc >= dateFromUtc);

        if (request.DateToUtc is DateTime dateToUtc)
            query = query.Where(x => x.CreatedAtUtc <= dateToUtc);

        query = query.OrderByDescending(x => x.CreatedAtUtc);

        var totalCount = await query.CountAsync(cancellationToken);
        var rows = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Join(
                dbContext.Users.AsNoTracking(),
                history => history.UserId,
                user => user.Id,
                (history, user) => new
                {
                    history,
                    InvestorName = user.FullName
                })
            .ToListAsync(cancellationToken);

        var invoiceIds = rows
            .Where(r => r.history.InvoiceId.HasValue)
            .Select(r => r.history.InvoiceId!.Value)
            .Distinct()
            .ToList();

        var invoiceLookup = invoiceIds.Count == 0
            ? new Dictionary<int, string?>()
            : await dbContext.Invoices
                .AsNoTracking()
                .Where(x => invoiceIds.Contains(x.Id))
                .Select(x => new { x.Id, x.PdfUrl })
                .ToDictionaryAsync(x => x.Id, x => x.PdfUrl, cancellationToken);

        var historyIds = rows.Select(r => r.history.Id).ToList();
        var feeBreakdownLookup = new Dictionary<int, List<TransactionFeeBreakdownDto>>();
        if (historyIds.Count > 0)
        {
            var feeRows = await dbContext.TransactionFeeBreakdowns
                .AsNoTracking()
                .Where(x => x.TransactionHistoryId.HasValue && historyIds.Contains(x.TransactionHistoryId.Value))
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new { x.TransactionHistoryId, Item = new TransactionFeeBreakdownDto(x.FeeCode, x.FeeName, x.CalculationMode, x.BaseAmount, x.Quantity, x.AppliedRate, x.AppliedValue, x.IsDiscount, x.Currency, x.SourceType, x.DisplayOrder) })
                .ToListAsync(cancellationToken);

            feeBreakdownLookup = feeRows
                .Where(x => x.TransactionHistoryId.HasValue)
                .GroupBy(x => x.TransactionHistoryId!.Value)
                .ToDictionary(g => g.Key, g => g.Select(v => v.Item).ToList());
        }

        var walletItemIds = rows
            .Where(x => x.history.WalletItemId.HasValue)
            .Select(x => x.history.WalletItemId!.Value)
            .Distinct()
            .ToList();

        var walletAssetLookup = walletItemIds.Count == 0
            ? new Dictionary<int, WalletAssetProjection>()
            : await dbContext.WalletAssets
                .AsNoTracking()
                .Where(x => walletItemIds.Contains(x.Id))
                .Select(x => new WalletAssetProjection(
                    x.Id,
                    x.SellerId,
                    x.ProductId,
                    x.ProductName,
                    x.ProductImageUrl,
                    x.ProductSku))
                .ToDictionaryAsync(x => x.Id, cancellationToken);

        var productIds = rows
            .Where(x => x.history.ProductId.HasValue)
            .Select(x => x.history.ProductId!.Value)
            .Concat(walletAssetLookup.Values.Where(x => x.ProductId.HasValue).Select(x => x.ProductId!.Value))
            .Distinct()
            .ToList();

        var productsById = productIds.Count == 0
            ? new Dictionary<int, ProductProjection>()
            : await dbContext.Products
                .AsNoTracking()
                .Where(x => productIds.Contains(x.Id))
                .Select(x => new ProductProjection(x.Id, x.SellerId, x.Sku, x.Name, x.ImageUrl))
                .ToDictionaryAsync(x => x.Id, cancellationToken);

        var sellerIds = rows
            .Where(x => x.history.SellerId.HasValue)
            .Select(x => x.history.SellerId!.Value)
            .Concat(walletAssetLookup.Values.Where(x => x.SellerId.HasValue).Select(x => x.SellerId!.Value))
            .Distinct()
            .ToList();

        var productsBySellerSku = await dbContext.Products
            .AsNoTracking()
            .Where(x => sellerIds.Contains(x.SellerId))
            .Select(x => new { x.SellerId, x.Sku, x.Name, x.ImageUrl })
            .ToListAsync(cancellationToken);

        var productLookup = productsBySellerSku.ToDictionary(
            x => (x.SellerId, x.Sku),
            x => (x.Name, x.ImageUrl),
            EqualityComparer<(int SellerId, string Sku)>.Default);

        var sellerCurrencyLookup = sellerIds.Count == 0
            ? new Dictionary<int, string>()
            : await dbContext.Sellers
                .AsNoTracking()
                .Where(x => sellerIds.Contains(x.Id))
                .Select(x => new { x.Id, x.MarketCurrencyCode, x.MarketType })
                .ToDictionaryAsync(x => x.Id, x => NormalizeCurrencyCode(x.MarketCurrencyCode, x.MarketType), cancellationToken);

        var userIds = rows.Select(x => x.history.UserId).Distinct().ToList();
        var investorCurrencyLookup = userIds.Count == 0
            ? new Dictionary<int, string>()
            : await dbContext.UserProfiles
                .AsNoTracking()
                .Where(x => userIds.Contains(x.UserId))
                .Select(x => new { x.UserId, x.MarketType })
                .ToDictionaryAsync(x => x.UserId, x => MarketTypeToCurrencyCode(x.MarketType), cancellationToken);

        var items = rows
            .Select(row =>
            {
                var (productName, productImageUrl) = ResolveProductInfo(
                    row.history.ProductId,
                    row.history.SellerId,
                    row.history.WalletItemId,
                    row.history.Notes,
                    row.history.Category,
                    walletAssetLookup,
                    productsById,
                    productLookup);
                var effectiveCurrency = ResolveEffectiveCurrency(row.history.SellerId, row.history.UserId, row.history.Currency, sellerCurrencyLookup, investorCurrencyLookup);

                var feeLines = feeBreakdownLookup.TryGetValue(row.history.Id, out var mappedFeeLines)
                    ? mappedFeeLines.Select(line => line with { Currency = effectiveCurrency }).ToList()
                    : [];

                return new TransactionHistoryDto(
                    row.history.Id,
                    row.history.UserId,
                    row.InvestorName,
                    row.history.SellerId,
                    row.history.TransactionType,
                    row.history.Status,
                    productName,
                    row.history.Category,
                    row.history.Quantity,
                    row.history.UnitPrice,
                    row.history.Weight,
                    row.history.Unit,
                    row.history.Purity,
                    row.history.FinalAmount,
                    row.history.SubTotalAmount,
                    row.history.TotalFeesAmount,
                    row.history.DiscountAmount,
                    row.history.FinalAmount,
                    effectiveCurrency,
                    row.history.WalletItemId,
                    row.history.InvoiceId,
                    row.history.InvoiceId.HasValue && invoiceLookup.TryGetValue(row.history.InvoiceId.Value, out var pdfUrl) ? pdfUrl : null,
                    row.history.Notes,
                    row.history.CreatedAtUtc,
                    productImageUrl,
                    feeLines);
            })
            .ToList();

        var totalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize);
        return new PagedResult<TransactionHistoryDto>(items, totalCount, request.PageNumber, request.PageSize, totalPages);
    }

    private static (string ProductName, string ProductImageUrl) ResolveProductInfo(
        int? productId,
        int? sellerId,
        int? walletItemId,
        string? notes,
        string fallback,
        IReadOnlyDictionary<int, WalletAssetProjection> walletAssetsById,
        IReadOnlyDictionary<int, ProductProjection> productsById,
        IReadOnlyDictionary<(int SellerId, string Sku), (string Name, string ImageUrl)> productLookup)
    {
        if (productId.HasValue && productsById.TryGetValue(productId.Value, out var explicitProduct))
        {
            return (explicitProduct.Name, explicitProduct.ImageUrl ?? string.Empty);
        }

        if (walletItemId.HasValue && walletAssetsById.TryGetValue(walletItemId.Value, out var walletAsset))
        {
            if (walletAsset.ProductId.HasValue && productsById.TryGetValue(walletAsset.ProductId.Value, out var walletProduct))
            {
                return (walletProduct.Name, walletProduct.ImageUrl ?? string.Empty);
            }

            if (!string.IsNullOrWhiteSpace(walletAsset.ProductName) || !string.IsNullOrWhiteSpace(walletAsset.ProductImageUrl))
            {
                return (
                    string.IsNullOrWhiteSpace(walletAsset.ProductName) ? fallback : walletAsset.ProductName!,
                    walletAsset.ProductImageUrl ?? string.Empty);
            }

            if (walletAsset.SellerId.HasValue && !string.IsNullOrWhiteSpace(walletAsset.ProductSku) &&
                productLookup.TryGetValue((walletAsset.SellerId.Value, walletAsset.ProductSku), out var walletSkuProduct))
            {
                return (walletSkuProduct.Name, walletSkuProduct.ImageUrl ?? string.Empty);
            }
        }

        if (!sellerId.HasValue) return (fallback, string.Empty);
        var sku = TryExtractSku(notes);
        if (string.IsNullOrWhiteSpace(sku)) return (fallback, string.Empty);
        return productLookup.TryGetValue((sellerId.Value, sku), out var product)
            ? (product.Name, product.ImageUrl)
            : (fallback, string.Empty);
    }

    private sealed record WalletAssetProjection(
        int Id,
        int? SellerId,
        int? ProductId,
        string? ProductName,
        string? ProductImageUrl,
        string? ProductSku);

    private sealed record ProductProjection(
        int Id,
        int SellerId,
        string? Sku,
        string Name,
        string? ImageUrl);

    private static string ResolveEffectiveCurrency(int? sellerId, int userId, string? fallbackCurrency, IReadOnlyDictionary<int, string> sellerCurrencyLookup, IReadOnlyDictionary<int, string> investorCurrencyLookup)
    {
        if (sellerId.HasValue && sellerCurrencyLookup.TryGetValue(sellerId.Value, out var sellerCurrency) && !string.IsNullOrWhiteSpace(sellerCurrency))
            return sellerCurrency;

        if (investorCurrencyLookup.TryGetValue(userId, out var investorCurrency) && !string.IsNullOrWhiteSpace(investorCurrency))
            return investorCurrency;

        return string.IsNullOrWhiteSpace(fallbackCurrency) ? "USD" : fallbackCurrency.Trim().ToUpperInvariant();
    }

    private static string NormalizeCurrencyCode(string? currencyCode, string? marketType)
    {
        if (!string.IsNullOrWhiteSpace(currencyCode))
            return currencyCode.Trim().ToUpperInvariant();

        return MarketTypeToCurrencyCode(marketType);
    }

    private static string MarketTypeToCurrencyCode(string? marketType)
    {
        return (marketType ?? string.Empty).Trim().ToUpperInvariant() switch
        {
            "UAE" => "AED",
            "KSA" => "SAR",
            "JORDAN" => "JOD",
            "EGYPT" => "EGP",
            "INDIA" => "INR",
            _ => "USD"
        };
    }

    private static string? TryExtractSku(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;

        const string marker = "SKU=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;

        var tail = notes[valueStart..].Trim();
        if (tail.Length == 0) return null;

        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        return stopAt > 0 ? tail[..stopAt].Trim() : tail;
    }
}
