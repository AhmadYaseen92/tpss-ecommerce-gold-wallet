using Microsoft.EntityFrameworkCore;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using TPSS.GoldWallet.Application.Common;
using TPSS.GoldWallet.Application.Security;
using TPSS.GoldWallet.Infrastructure.DependencyInjection;
using TPSS.GoldWallet.Infrastructure.Identity;
using TPSS.GoldWallet.Infrastructure.Persistence;
using TPSS.GoldWallet.Infrastructure.Security;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var jwtOptions = builder.Configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>() ?? new JwtOptions();
var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.Key));

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ValidIssuer = jwtOptions.Issuer,
            ValidAudience = jwtOptions.Audience,
            IssuerSigningKey = key
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy(PermissionNames.CatalogRead, policy => policy.RequireClaim("permission", PermissionNames.CatalogRead));
    options.AddPolicy(PermissionNames.CartRead, policy => policy.RequireClaim("permission", PermissionNames.CartRead));
    options.AddPolicy(PermissionNames.CartWrite, policy => policy.RequireClaim("permission", PermissionNames.CartWrite));
    options.AddPolicy(PermissionNames.WalletRead, policy => policy.RequireClaim("permission", PermissionNames.WalletRead));
    options.AddPolicy(PermissionNames.WalletWrite, policy => policy.RequireClaim("permission", PermissionNames.WalletWrite));
    options.AddPolicy(PermissionNames.ProfileRead, policy => policy.RequireClaim("permission", PermissionNames.ProfileRead));
    options.AddPolicy(PermissionNames.KycSubmit, policy => policy.RequireClaim("permission", PermissionNames.KycSubmit));
    options.AddPolicy(PermissionNames.DashboardRead, policy => policy.RequireClaim("permission", PermissionNames.DashboardRead));
    options.AddPolicy(PermissionNames.HistoryRead, policy => policy.RequireClaim("permission", PermissionNames.HistoryRead));
    options.AddPolicy(PermissionNames.AuditRead, policy => policy.RequireClaim("permission", PermissionNames.AuditRead));
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await dbContext.Database.MigrateAsync();

    var userManager = scope.ServiceProvider.GetRequiredService<Microsoft.AspNetCore.Identity.UserManager<AppIdentityUser>>();
    var roleManager = scope.ServiceProvider.GetRequiredService<Microsoft.AspNetCore.Identity.RoleManager<Microsoft.AspNetCore.Identity.IdentityRole<Guid>>>();
    await SeedData.EnsureSeededAsync(dbContext, userManager, roleManager);
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
