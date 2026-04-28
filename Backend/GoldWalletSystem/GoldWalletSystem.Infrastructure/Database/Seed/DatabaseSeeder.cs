using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace GoldWalletSystem.Infrastructure.Database.Seed;

public interface IDatabaseSeeder
{
    Task SeedIfNeededAsync(CancellationToken cancellationToken = default);
}

public sealed class DatabaseSeeder(
    AppDbContext dbContext,
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

        var scriptPath = ResolveSeedScriptPath();
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

    private static string ResolveSeedScriptPath()
    {
        var candidates = new[]
        {
            Path.Combine(AppContext.BaseDirectory, "Database", "Seed", "sample-data.sql"),
            Path.Combine(Directory.GetCurrentDirectory(), "Database", "Seed", "sample-data.sql"),
            Path.Combine(Directory.GetCurrentDirectory(), "GoldWalletSystem.Infrastructure", "Database", "Seed", "sample-data.sql")
        };

        return candidates.FirstOrDefault(File.Exists) ?? candidates[0];
    }
}
