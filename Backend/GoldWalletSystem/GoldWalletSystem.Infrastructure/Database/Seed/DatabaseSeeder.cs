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
    private const string BaselineSeedFileName = "baseline-data.sql";
    private const string SampleSeedFileName = "sample-data.sql";

    public async Task SeedIfNeededAsync(CancellationToken cancellationToken = default)
    {
        await dbContext.Database.MigrateAsync(cancellationToken);

        var hasAdmin = await dbContext.Users.AnyAsync(x => x.Role == Domain.Constants.SystemRoles.Admin, cancellationToken);
        var hasSystemFeeTypes = await dbContext.SystemFeeTypes.AnyAsync(cancellationToken);
        var hasSystemSettings = await dbContext.MobileAppConfigurations.AnyAsync(cancellationToken);

        if (!hasAdmin || !hasSystemFeeTypes || !hasSystemSettings)
        {
            await ExecuteSeedScriptIfExistsAsync(BaselineSeedFileName, "baseline", cancellationToken);
        }
        else
        {
            logger.LogInformation("Baseline database seed skipped (admin/system configuration/system fee types already present).");
        }

        if (ShouldApplySampleSeed())
        {
            await ExecuteSeedScriptIfExistsAsync(SampleSeedFileName, "sample", cancellationToken);
        }
        else
        {
            logger.LogInformation("Sample database seed skipped. Set GW_SEED_SAMPLE_DATA=true to enable test data seeding.");
        }
    }

    private async Task ExecuteSeedScriptIfExistsAsync(string fileName, string seedType, CancellationToken cancellationToken)
    {
        var scriptPath = ResolveSeedScriptPath(fileName);
        if (!File.Exists(scriptPath))
        {
            logger.LogWarning("{SeedType} seed script not found at: {ScriptPath}", seedType, scriptPath);
            return;
        }

        var sql = await File.ReadAllTextAsync(scriptPath, cancellationToken);
        if (string.IsNullOrWhiteSpace(sql))
        {
            logger.LogWarning("{SeedType} seed script is empty: {ScriptPath}", seedType, scriptPath);
            return;
        }

        logger.LogInformation("Running {SeedType} database seed script from {ScriptPath}", seedType, scriptPath);
        await dbContext.Database.ExecuteSqlRawAsync(sql, cancellationToken);
        logger.LogInformation("{SeedType} database seed completed successfully.", seedType);
    }

    private static bool ShouldApplySampleSeed()
    {
        var rawValue = Environment.GetEnvironmentVariable("GW_SEED_SAMPLE_DATA")
            ?? Environment.GetEnvironmentVariable("GOLDWALLET_SEED_SAMPLE_DATA");

        return rawValue is not null
            && (rawValue.Equals("1", StringComparison.OrdinalIgnoreCase)
                || rawValue.Equals("true", StringComparison.OrdinalIgnoreCase)
                || rawValue.Equals("yes", StringComparison.OrdinalIgnoreCase));
    }

    private static string ResolveSeedScriptPath(string fileName)
    {
        var candidates = new[]
        {
            Path.Combine(AppContext.BaseDirectory, "Database", "Seed", fileName),
            Path.Combine(Directory.GetCurrentDirectory(), "Database", "Seed", fileName),
            Path.Combine(Directory.GetCurrentDirectory(), "GoldWalletSystem.Infrastructure", "Database", "Seed", fileName)
        };

        return candidates.FirstOrDefault(File.Exists) ?? candidates[0];
    }
}
