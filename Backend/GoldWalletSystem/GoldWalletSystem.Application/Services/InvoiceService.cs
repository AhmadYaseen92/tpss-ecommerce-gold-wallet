using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Invoices;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class InvoiceService(IInvoiceReadRepository invoiceReadRepository) : IInvoiceService
{
    public Task<PagedResult<InvoiceDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => invoiceReadRepository.GetByUserIdAsync(userId, pageNumber, pageSize, cancellationToken);
}

public interface IInvoiceReadRepository
{
    Task<PagedResult<InvoiceDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
}
