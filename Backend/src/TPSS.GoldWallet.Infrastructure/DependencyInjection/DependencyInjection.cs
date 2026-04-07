using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Infrastructure.Persistence;
using TPSS.GoldWallet.Infrastructure.Repositories;

namespace TPSS.GoldWallet.Infrastructure.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>(options =>
        {
            options.UseInMemoryDatabase(configuration.GetValue<string>("Database:Name") ?? "GoldWalletDb");
        });

        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<ICartRepository, CartRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        return services;
    }
}
