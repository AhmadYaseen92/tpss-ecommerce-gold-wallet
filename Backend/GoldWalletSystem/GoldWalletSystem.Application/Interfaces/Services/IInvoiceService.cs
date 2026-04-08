using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Invoices;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IInvoiceService
{
    Task<PagedResult<InvoiceDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<InvoiceDto> CreateAsync(CreateInvoiceRequestDto request, CancellationToken cancellationToken = default);
}
