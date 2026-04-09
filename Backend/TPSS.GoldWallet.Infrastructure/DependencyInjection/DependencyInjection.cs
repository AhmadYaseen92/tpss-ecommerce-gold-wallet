using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Infrastructure.Identity;
using TPSS.GoldWallet.Infrastructure.Persistence;
using TPSS.GoldWallet.Infrastructure.Repositories;
using TPSS.GoldWallet.Infrastructure.Security;

namespace TPSS.GoldWallet.Infrastructure.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var sqlServer = configuration.GetConnectionString("SqlServer")
                        ?? "Server=localhost;Database=GoldWalletDb;Trusted_Connection=True;TrustServerCertificate=True;";

        services.AddDbContext<AppDbContext>(options => options.UseSqlServer(sqlServer));

        services.AddIdentity<AppIdentityUser, IdentityRole<Guid>>(options =>
            {
                options.Password.RequireDigit = true;
                options.Password.RequireUppercase = true;
                options.Password.RequireLowercase = true;
                options.Password.RequireNonAlphanumeric = true;
                options.Password.RequiredLength = 10;
                options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
                options.Lockout.MaxFailedAccessAttempts = 5;
                options.User.RequireUniqueEmail = true;
            })
            .AddEntityFrameworkStores<AppDbContext>()
            .AddDefaultTokenProviders();

        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));

        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<ICartRepository, CartRepository>();
        services.AddScoped<IWalletRepository, WalletRepository>();
        services.AddScoped<IUserProfileRepository, UserProfileRepository>();
        services.AddScoped<IKycRepository, KycRepository>();
        services.AddScoped<IAuditLogRepository, AuditLogRepository>();
        services.AddScoped<INotificationRepository, NotificationRepository>();
        services.AddScoped<IAccountSummaryRepository, AccountSummaryRepository>();
        services.AddScoped<ITradeTransactionRepository, TradeTransactionRepository>();
        services.AddScoped<ITokenService, JwtTokenService>();
        services.AddScoped<IIdentityService, IdentityService>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        return services;
    }
}
