using GoldWalletSystem.API.Services;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.API.Extensions;

public static class ApiServiceCollectionExtensions
{
    public static IServiceCollection AddApiLayer(this IServiceCollection services)
    {
        services.AddScoped<ICurrentUserService, CurrentUserService>();
        return services;
    }
}
