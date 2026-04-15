using GoldWalletSystem.API.Extensions;
using GoldWalletSystem.API.Hubs;
using GoldWalletSystem.API.Middleware;
using GoldWalletSystem.API.Services;
using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Infrastructure.DependencyInjection;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddOpenApi();

builder.Services.AddCors(options =>
{
    options.AddPolicy("WebApp", policy =>
    {
        policy.WithOrigins("http://localhost:5173", "http://127.0.0.1:5173")
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=localhost;Database=GoldWalletSystemDb;Trusted_Connection=True;TrustServerCertificate=True;";

builder.Services.AddInfrastructure(connectionString);
builder.Services.AddApiLayer();

var jwtKey = builder.Configuration["Jwt:Key"] ?? "Please-Override-In-Production-32-Char-Min";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "GoldWallet";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "GoldWalletClient";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            NameClaimType = "sub",
            RoleClaimType = "role"
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddSignalR();
builder.Services.AddScoped<IWebAdminDashboardService, WebAdminDashboardService>();
builder.Services.AddScoped<IMarketplaceRealtimeNotifier, MarketplaceRealtimeNotifier>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseMiddleware<GlobalExceptionMiddleware>();
app.UseStaticFiles();
app.UseCors("WebApp");

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await BaselineInitialMigrationForExistingDatabaseAsync(dbContext);
    await dbContext.Database.MigrateAsync();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseAuthentication();
app.UseMiddleware<AuditTrailMiddleware>();
app.UseAuthorization();
app.MapControllers();
app.MapHub<MarketplaceHub>("/hubs/marketplace");
app.Run();

static async Task BaselineInitialMigrationForExistingDatabaseAsync(AppDbContext dbContext)
{
    const string initialMigrationId = "20260414122117_InitialCreate";
    const string productVersion = "10.0.5";
    const string baselineTableName = "MobileAppConfigurations";

    var connectionString = dbContext.Database.GetConnectionString()
        ?? throw new InvalidOperationException("Database connection string is not configured.");
    await using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();

    await using var detectCommand = connection.CreateCommand();
    detectCommand.CommandText = """
                                SELECT CASE
                                    WHEN OBJECT_ID(N'[dbo].[' + @TableName + ']', N'U') IS NOT NULL THEN 1
                                    ELSE 0
                                END;
                                """;
    detectCommand.Parameters.AddWithValue("@TableName", baselineTableName);

    var tableExists = Convert.ToInt32(await detectCommand.ExecuteScalarAsync()) == 1;
    if (!tableExists)
    {
        return;
    }

    await using var baselineCommand = connection.CreateCommand();
    baselineCommand.CommandText = """
                                  IF OBJECT_ID(N'[__EFMigrationsHistory]', N'U') IS NULL
                                  BEGIN
                                      CREATE TABLE [__EFMigrationsHistory]
                                      (
                                          [MigrationId] nvarchar(150) NOT NULL,
                                          [ProductVersion] nvarchar(32) NOT NULL,
                                          CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
                                      );
                                  END;

                                  IF NOT EXISTS (SELECT 1 FROM [__EFMigrationsHistory] WHERE [MigrationId] = @MigrationId)
                                  BEGIN
                                      INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
                                      VALUES (@MigrationId, @ProductVersion);
                                  END;
                                  """;
    baselineCommand.Parameters.AddWithValue("@MigrationId", initialMigrationId);
    baselineCommand.Parameters.AddWithValue("@ProductVersion", productVersion);
    await baselineCommand.ExecuteNonQueryAsync();
}
