using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Reflection;

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
        var (sql, sourceDescription) = await ReadSeedScriptAsync(fileName, cancellationToken);
        if (string.IsNullOrWhiteSpace(sql))
        {
            logger.LogWarning("{SeedType} seed script not found or empty: {FileName}", seedType, fileName);
            return;
        }

        logger.LogInformation("Running {SeedType} database seed script ({SourceDescription})", seedType, sourceDescription);
        await dbContext.Database.ExecuteSqlRawAsync(sql, cancellationToken);
        logger.LogInformation("{SeedType} database seed completed successfully.", seedType);
    }

    private static async Task<(string? Sql, string SourceDescription)> ReadSeedScriptAsync(string fileName, CancellationToken cancellationToken)
    {
        var scriptPath = ResolveSeedScriptPath(fileName);
        if (File.Exists(scriptPath))
        {
            var fileSql = await File.ReadAllTextAsync(scriptPath, cancellationToken);
            if (!string.IsNullOrWhiteSpace(fileSql))
            {
                return (fileSql, $"file: {scriptPath}");
            }
        }

        var assembly = Assembly.GetExecutingAssembly();
        var resourceName = assembly
            .GetManifestResourceNames()
            .FirstOrDefault(x => x.EndsWith(fileName, StringComparison.OrdinalIgnoreCase));

        if (resourceName is null)
        {
            return (null, $"missing file/resource for {fileName}");
        }

        await using var stream = assembly.GetManifestResourceStream(resourceName);
        if (stream is null)
        {
            return (null, $"resource stream unavailable: {resourceName}");
        }

        using var reader = new StreamReader(stream);
        var resourceSql = await reader.ReadToEndAsync(cancellationToken);
        return (resourceSql, $"embedded resource: {resourceName}");
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
        var currentDirectory = Directory.GetCurrentDirectory();
        var candidates = new[]
        {
            Path.Combine(AppContext.BaseDirectory, "Database", "Seed", fileName),
            Path.Combine(currentDirectory, "Database", "Seed", fileName),
            Path.Combine(currentDirectory, "GoldWalletSystem.Infrastructure", "Database", "Seed", fileName),
            Path.Combine(currentDirectory, "..", "GoldWalletSystem.Infrastructure", "Database", "Seed", fileName),
            Path.GetFullPath(Path.Combine(currentDirectory, "..", "GoldWalletSystem.Infrastructure", "Database", "Seed", fileName))
        };

        return candidates.FirstOrDefault(File.Exists) ?? candidates[0];
    }
}
