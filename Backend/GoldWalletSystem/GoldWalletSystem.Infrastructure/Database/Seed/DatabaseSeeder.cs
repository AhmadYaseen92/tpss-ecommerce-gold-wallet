using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace GoldWalletSystem.Infrastructure.Database.Seed;

public interface IDatabaseSeeder
{
    Task SeedIfNeededAsync(CancellationToken cancellationToken = default);
}

public sealed class DatabaseSeeder(
    AppDbContext dbContext,
    IHostEnvironment hostEnvironment,
    ILogger<DatabaseSeeder> logger) : IDatabaseSeeder
{
    public async Task SeedIfNeededAsync(CancellationToken cancellationToken = default)
    {
        await dbContext.Database.MigrateAsync(cancellationToken);

        var hasAdmin = await dbContext.Users.AnyAsync(x => x.Role == Domain.Constants.SystemRoles.Admin, cancellationToken);
        var hasSystemFeeTypes = await dbContext.SystemFeeTypes.AnyAsync(cancellationToken);
        var hasSystemSettings = await dbContext.MobileAppConfigurations.AnyAsync(cancellationToken);

        if (hasAdmin && hasSystemFeeTypes && hasSystemSettings)
        {
            logger.LogInformation("Database seed skipped (baseline records already present).");
            return;
        }

        var scriptPath = ResolveSeedScriptPath(hostEnvironment.ContentRootPath);
        if (!File.Exists(scriptPath))
        {
            logger.LogWarning("Database seed script not found at: {ScriptPath}", scriptPath);
            return;
        }

        var sql = await File.ReadAllTextAsync(scriptPath, cancellationToken);
        if (string.IsNullOrWhiteSpace(sql))
        {
            logger.LogWarning("Database seed script is empty: {ScriptPath}", scriptPath);
            return;
        }

        logger.LogInformation("Running database seed script from {ScriptPath}", scriptPath);
        await dbContext.Database.ExecuteSqlRawAsync(sql, cancellationToken);
        logger.LogInformation("Database seed completed successfully.");
    }

    private static string ResolveSeedScriptPath(string contentRootPath)
    {
        var candidate1 = Path.Combine(contentRootPath, "Database", "Seed", "sample-data.sql");
        if (File.Exists(candidate1)) return candidate1;

        var candidate2 = Path.Combine(contentRootPath, "GoldWalletSystem.Infrastructure", "Database", "Seed", "sample-data.sql");
        if (File.Exists(candidate2)) return candidate2;

        return Path.Combine(AppContext.BaseDirectory, "Database", "Seed", "sample-data.sql");
    }
}
