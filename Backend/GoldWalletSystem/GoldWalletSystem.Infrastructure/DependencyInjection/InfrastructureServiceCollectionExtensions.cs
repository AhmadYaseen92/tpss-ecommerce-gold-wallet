using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Infrastructure.Repositories;
using GoldWalletSystem.Infrastructure.Services;
using GoldWalletSystem.Infrastructure.Services.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace GoldWalletSystem.Infrastructure.DependencyInjection;

public static class InfrastructureServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, string connectionString)
    {
        services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));
        services.AddMemoryCache();

        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<ICartRepository, CartRepository>();
        services.AddScoped<IAuditLogRepository, AuditLogRepository>();
        services.AddScoped<ITransactionHistoryReadRepository, TransactionHistoryRepository>();
        services.AddScoped<IInvoiceReadRepository, InvoiceRepository>();
        services.AddScoped<IDashboardRepository, DashboardRepository>();
        services.AddScoped<IProfileRepository, ProfileRepository>();
        services.AddScoped<INotificationRepository, NotificationRepository>();
        services.AddScoped<IUserAuthRepository, UserAuthRepository>();
        services.AddScoped<ISellerAuthRepository, SellerAuthRepository>();
        services.AddScoped<IMobileAppConfigurationRepository, MobileAppConfigurationRepository>();
        services.AddScoped<IWalletRepository, WalletRepository>();

        services.AddScoped<IProductService, ProductService>();
        services.AddScoped<ICartService, CartService>();
        services.AddScoped<IAuditLogService, AuditLogService>();
        services.AddScoped<ITransactionHistoryService, TransactionHistoryService>();
        services.AddScoped<IInvoiceService, InvoiceService>();
        services.AddScoped<IDashboardService, DashboardService>();
        services.AddScoped<IProfileService, ProfileService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ISellerAuthService, SellerAuthService>();
        services.AddScoped<IMobileAppConfigurationService, MobileAppConfigurationService>();
        services.AddScoped<IWalletService, WalletService>();
        services.AddScoped<IWalletActionValidationService, WalletActionValidationService>();
        services.AddScoped<IOtpDeliveryService, OtpDeliveryService>();
        services.AddSingleton<IOtpSessionStore, OtpSessionMemoryStore>();
        services.AddScoped<IOtpService, OtpService>();
        services.AddSingleton<IPasswordHasher, Pbkdf2PasswordHasher>();
        services.AddSingleton<ITokenService, JwtTokenService>();

        return services;
    }
}
