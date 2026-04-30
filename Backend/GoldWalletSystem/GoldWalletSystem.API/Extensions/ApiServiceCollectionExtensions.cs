using GoldWalletSystem.API.Services;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.API.Extensions;

public static class ApiServiceCollectionExtensions
{
    public static IServiceCollection AddApiLayer(this IServiceCollection services)
    {
        services.AddScoped<ICurrentUserService, CurrentUserService>();
        services.AddScoped<IInvoiceDocumentService, InvoiceDocumentService>();
        services.AddScoped<IProductWriteService, ProductWriteService>();
        return services;
    }
}
