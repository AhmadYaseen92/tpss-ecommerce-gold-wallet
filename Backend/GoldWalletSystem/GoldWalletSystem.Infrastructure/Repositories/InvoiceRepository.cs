using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Invoices;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class InvoiceRepository(AppDbContext dbContext) : IInvoiceReadRepository
{
    public async Task<PagedResult<InvoiceDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Invoices.AsNoTracking()
            .Include(x => x.Items)
            .Where(x => x.InvestorUserId == userId || x.SellerUserId == userId)
            .OrderByDescending(x => x.CreatedAtUtc);

        var totalCount = await query.CountAsync(cancellationToken);
        var entities = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync(cancellationToken);
        var items = entities.Select(Map).ToList();
        return new PagedResult<InvoiceDto>(items, totalCount, pageNumber, pageSize);
    }

    public async Task<InvoiceDto> CreateAsync(CreateInvoiceRequestDto request, CancellationToken cancellationToken = default)
    {
        var sellerUserId = request.SellerUserId ?? request.InvestorUserId; // investor can become seller when selling own items.
        var subTotal = request.Items.Sum(x => x.Quantity * x.UnitPrice);
        var total = subTotal + request.TaxAmount;

        var invoice = new Invoice
        {
            InvestorUserId = request.InvestorUserId,
            SellerUserId = sellerUserId,
            InvoiceCategory = request.InvoiceCategory,
            SourceChannel = request.SourceChannel,
            InvoiceNumber = $"INV-{DateTime.UtcNow:yyyyMMddHHmmssfff}",
            InvoiceQrCode = $"QR-INV-{Guid.NewGuid():N}",
            SubTotal = subTotal,
            TaxAmount = request.TaxAmount,
            TotalAmount = total,
            IssuedOnUtc = DateTime.UtcNow,
            Status = "Generated",
            Items = request.Items.Select(x => new InvoiceItem
            {
                ProductId = x.ProductId,
                ItemName = x.ItemName,
                Quantity = x.Quantity,
                UnitPrice = x.UnitPrice,
                LineTotal = x.Quantity * x.UnitPrice,
                ItemQrCode = $"QR-ITEM-{Guid.NewGuid():N}",
            }).ToList()
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
            x.SubTotal,
            x.TaxAmount,
            x.TotalAmount,
            x.Status,
            x.InvoiceQrCode,
            x.IssuedOnUtc,
            x.Items.Select(i => new InvoiceItemDto(i.Id, i.ProductId, i.ItemName, i.Quantity, i.UnitPrice, i.LineTotal, i.ItemQrCode)).ToList());
}
