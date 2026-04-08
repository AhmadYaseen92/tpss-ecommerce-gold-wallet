using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace GoldWalletSystem.Infrastructure.DependencyInjection;

public static class InfrastructureServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, string connectionString)
    {
        services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));

        services.AddScoped<IReadRepository<GoldWalletSystem.Application.DTOs.Products.ProductDto>, ProductRepository>();
        services.AddScoped<IReadRepository<Product>, ProductEntityRepository>();
        services.AddScoped<ICartRepository, CartRepository>();
        services.AddScoped<IReadRepository<GoldWalletSystem.Application.DTOs.Logs.AuditLogDto>, AuditLogRepository>();
        services.AddScoped<ITransactionHistoryReadRepository, TransactionHistoryRepository>();
        services.AddScoped<IInvoiceReadRepository, InvoiceRepository>();

        services.AddScoped<IProductService, ProductService>();
        services.AddScoped<ICartService, CartService>();
        services.AddScoped<IAuditLogService, AuditLogService>();
        services.AddScoped<ITransactionHistoryService, TransactionHistoryService>();
        services.AddScoped<IInvoiceService, InvoiceService>();

        return services;
    }
}
