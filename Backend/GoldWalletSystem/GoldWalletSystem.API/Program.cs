using GoldWalletSystem.API.Extensions;
using GoldWalletSystem.API.Hubs;
using GoldWalletSystem.API.Middleware;
using GoldWalletSystem.API.Services;
using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Infrastructure.Database.Seed;
using GoldWalletSystem.Infrastructure.DependencyInjection;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

// Ensure JWT claims are not mapped to legacy Microsoft claim types
System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var validationErrors = context.ModelState
                .Where(x => x.Value?.Errors.Count > 0)
                .SelectMany(x => x.Value!.Errors)
                .Select(e => string.IsNullOrWhiteSpace(e.ErrorMessage) ? "Invalid input." : e.ErrorMessage)
                .Distinct()
                .ToArray();

            var response = GoldWalletSystem.Application.DTOs.Common.ApiResponse<object>.Fail(
                message: "Validation failed.",
                statusCode: StatusCodes.Status400BadRequest,
                errorCode: "VALIDATION_ERROR",
                errors: validationErrors);

            return new BadRequestObjectResult(response);
        };
    });
builder.Services.AddHttpContextAccessor();
builder.Services.AddOpenApi();

builder.Services.AddCors(options =>
{
    options.AddPolicy("WebApp", policy =>
    {
        policy.WithOrigins(
                "http://localhost:5173",
                "http://127.0.0.1:5173",
                "http://localhost:5174",
                "http://127.0.0.1:5174")
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=localhost;Database=GoldWalletSystemDb;Trusted_Connection=True;TrustServerCertificate=True;";

builder.Services.AddInfrastructure(connectionString);
builder.Services.AddApiLayer();
builder.Services.Configure<GoldWalletSystem.Infrastructure.Services.NotificationDeliveryOptions>(
    builder.Configuration.GetSection(GoldWalletSystem.Infrastructure.Services.NotificationDeliveryOptions.SectionName));

var jwtKey = builder.Configuration["Jwt:Key"] ?? "Please-Override-In-Production-32-Char-Min";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "GoldWallet";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "GoldWalletClient";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;

                if (!string.IsNullOrWhiteSpace(accessToken) && path.StartsWithSegments("/hubs", StringComparison.OrdinalIgnoreCase))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                var claimsIdentity = context.Principal?.Identity as System.Security.Claims.ClaimsIdentity;
                if (claimsIdentity != null)
                {
                    var loggerFactory = context.HttpContext.RequestServices.GetService(typeof(Microsoft.Extensions.Logging.ILoggerFactory)) as Microsoft.Extensions.Logging.ILoggerFactory;
                    var logger = loggerFactory?.CreateLogger("JwtDebug");
                    var roles = claimsIdentity.FindAll("http://schemas.microsoft.com/ws/2008/06/identity/claims/role").Select(r => r.Value);
                    var email = claimsIdentity.FindFirst("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress")?.Value;
                    var sub = claimsIdentity.FindFirst("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier")?.Value;
                    logger?.LogInformation("[JWT DEBUG] User authenticated. Email: {Email}, Sub: {Sub}, Roles: {Roles}", email, sub, string.Join(",", roles));
                }
                return Task.CompletedTask;
            }
        };

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            NameClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier",
            RoleClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddSignalR();
builder.Services.AddScoped<IMarketplaceRealtimeNotifier, MarketplaceRealtimeNotifier>();
builder.Services.AddScoped<GoldWalletSystem.Application.Interfaces.Services.INotificationRealtimePublisher, SignalRNotificationRealtimePublisher>();

var app = builder.Build();

await app.Services.EnsureDatabaseSeededSafeAsync();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.ContentType = "application/json";

        var exception = context.Features.Get<IExceptionHandlerPathFeature>()?.Error;

        var (statusCode, message, errorCode) = exception switch
        {
            UnauthorizedAccessException ex => (
                StatusCodes.Status401Unauthorized,
                string.IsNullOrWhiteSpace(ex.Message) ? "Invalid credentials. Please try again." : ex.Message,
                "INVALID_CREDENTIALS"),
            InvalidOperationException ex => (
                StatusCodes.Status400BadRequest,
                string.IsNullOrWhiteSpace(ex.Message) ? "Invalid request. Please review your input and try again." : ex.Message,
                "INVALID_OPERATION"),
            BadHttpRequestException => (
                StatusCodes.Status400BadRequest,
                "Invalid request. Please review your input and try again.",
                "BAD_REQUEST"),
            _ => (
                StatusCodes.Status500InternalServerError,
                "Something went wrong. Please try again later.",
                "GENERAL_ERROR")
        };

        context.Response.StatusCode = statusCode;
        var response = GoldWalletSystem.Application.DTOs.Common.ApiResponse<object>.Fail(message, statusCode, errorCode);
        await context.Response.WriteAsJsonAsync(response);
    });
});
app.UseStaticFiles();
app.UseCors("WebApp");

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
