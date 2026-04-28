using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace GoldWalletSystem.Infrastructure.Database.Seed;

public static class DatabaseSeederExtensions
{
    public static async Task EnsureDatabaseSeededSafeAsync(this IServiceProvider services, CancellationToken cancellationToken = default)
    {
        using var scope = services.CreateScope();
        var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("DatabaseSeeder");

        try
        {
            var seeder = scope.ServiceProvider.GetRequiredService<IDatabaseSeeder>();
            await seeder.SeedIfNeededAsync(cancellationToken);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Database seeding failed. Application startup continues for safety.");
        }
    }
}
