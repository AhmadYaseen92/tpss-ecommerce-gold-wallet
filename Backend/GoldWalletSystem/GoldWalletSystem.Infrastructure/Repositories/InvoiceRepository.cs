using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Invoices;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class InvoiceRepository(AppDbContext dbContext) : IInvoiceReadRepository
{
    private static readonly HashSet<string> AllowedInvoiceCategories = ["Buy", "Sell", "Transfer", "Gift", "Pickup"];
    private static readonly HashSet<string> AllowedInvoiceStatuses = ["Draft", "Issued", "Completed", "Cancelled"];
    private static readonly HashSet<string> AllowedPaymentStatuses = ["Pending", "Paid", "Failed", "Cancelled"];

    public async Task<PagedResult<InvoiceDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Invoices.AsNoTracking()
            .Where(x => x.InvestorUserId == userId || x.SellerUserId == userId)
            .OrderByDescending(x => x.CreatedAtUtc);

        var totalCount = await query.CountAsync(cancellationToken);
        var entities = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync(cancellationToken);
        var items = entities.Select(Map).ToList();
        var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);
        return new PagedResult<InvoiceDto>(items, totalCount, pageNumber, pageSize, totalPages);
    }

    public async Task<InvoiceDto> CreateAsync(CreateInvoiceRequestDto request, CancellationToken cancellationToken = default)
    {
        var sellerUserId = request.SellerUserId ?? request.InvestorUserId;
        var quantity = Math.Max(1, request.Quantity);
        var resolvedUnitPrice = request.UnitPrice > 0 ? request.UnitPrice : request.SubTotal;
        var subTotal = request.SubTotal > 0 ? request.SubTotal : quantity * resolvedUnitPrice;
        var total = subTotal + request.FeesAmount + request.TaxAmount - request.DiscountAmount;
        var invoiceCategory = NormalizeAllowedValue(request.InvoiceCategory, AllowedInvoiceCategories, "Buy");
        var paymentStatus = NormalizeAllowedValue(request.PaymentStatus, AllowedPaymentStatuses, "Pending");
        var status = paymentStatus == "Paid" ? "Completed" : "Issued";
        status = NormalizeAllowedValue(status, AllowedInvoiceStatuses, "Draft");

        var invoice = new Invoice
        {
            InvestorUserId = request.InvestorUserId,
            SellerUserId = sellerUserId,
            InvoiceCategory = invoiceCategory,
            SourceChannel = request.SourceChannel,
            ExternalReference = request.ExternalReference,
            InvoiceNumber = $"INV-{DateTime.UtcNow:yyyyMMddHHmmssfff}",
            InvoiceQrCode = $"QR-INV-{Guid.NewGuid():N}",
            SubTotal = subTotal,
            FeesAmount = request.FeesAmount,
            DiscountAmount = request.DiscountAmount,
            TaxAmount = request.TaxAmount,
            TotalAmount = total,
            Currency = string.IsNullOrWhiteSpace(request.Currency) ? "USD" : request.Currency.Trim().ToUpperInvariant(),
            PaymentMethod = string.IsNullOrWhiteSpace(request.PaymentMethod) ? "Unknown" : request.PaymentMethod.Trim(),
            PaymentStatus = paymentStatus,
            PaymentTransactionId = request.PaymentTransactionId,
            WalletItemId = request.WalletItemId,
            ProductId = request.ProductId,
            ProductName = request.ProductName,
            Quantity = quantity,
            UnitPrice = resolvedUnitPrice,
            Weight = request.Weight,
            Purity = request.Purity,
            FromPartyType = request.FromPartyType,
            ToPartyType = request.ToPartyType,
            FromPartyUserId = request.FromPartyUserId,
            ToPartyUserId = request.ToPartyUserId,
            OwnershipEffectiveOnUtc = request.OwnershipEffectiveOnUtc,
            RelatedTransactionId = request.RelatedTransactionId,
            PdfUrl = request.PdfUrl,
            IssuedOnUtc = DateTime.UtcNow,
            PaidOnUtc = paymentStatus == "Paid" ? request.PaidOnUtc ?? DateTime.UtcNow : null,
            Status = status,
        };

        dbContext.Invoices.Add(invoice);
        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(invoice);
    }

    private static InvoiceDto Map(Invoice x)
        => new(
            x.Id,
            x.InvestorUserId,
            x.SellerUserId,
            x.InvoiceNumber,
            x.InvoiceCategory,
            x.SourceChannel,
            x.ExternalReference,
            x.SubTotal,
            x.FeesAmount,
            x.DiscountAmount,
            x.TaxAmount,
            x.TotalAmount,
            x.Currency,
            x.PaymentMethod,
            x.PaymentStatus,
            x.PaymentTransactionId,
            x.WalletItemId,
            x.ProductId,
            x.ProductName,
            x.Quantity,
            x.UnitPrice,
            x.Weight,
            x.Purity,
            x.FromPartyType,
            x.ToPartyType,
            x.FromPartyUserId,
            x.ToPartyUserId,
            x.OwnershipEffectiveOnUtc,
            x.RelatedTransactionId,
            x.Status,
            x.InvoiceQrCode,
            x.PdfUrl,
            x.IssuedOnUtc,
            x.PaidOnUtc);

    private static string NormalizeAllowedValue(string? candidate, IReadOnlySet<string> allowedValues, string fallback)
    {
        if (string.IsNullOrWhiteSpace(candidate)) return fallback;
        var value = candidate.Trim();
        var exact = allowedValues.FirstOrDefault(x => string.Equals(x, value, StringComparison.OrdinalIgnoreCase));
        return exact ?? fallback;
    }
}
