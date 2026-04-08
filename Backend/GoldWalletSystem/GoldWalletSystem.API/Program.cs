using GoldWalletSystem.API.Extensions;
using GoldWalletSystem.API.Middleware;
using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Infrastructure.DependencyInjection;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddOpenApi();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=(localdb)\\mssqllocaldb;Database=GoldWalletSystemDb;Trusted_Connection=True;TrustServerCertificate=True;";

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

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseMiddleware<GlobalExceptionMiddleware>();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await dbContext.Database.MigrateAsync();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
