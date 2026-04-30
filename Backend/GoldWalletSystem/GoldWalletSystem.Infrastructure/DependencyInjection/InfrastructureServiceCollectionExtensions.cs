using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Infrastructure.Database.Seed;
using GoldWalletSystem.Infrastructure.FileStorage;
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
        services.AddScoped<IDatabaseSeeder, DatabaseSeeder>();

        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<ICartRepository, CartRepository>();
        services.AddScoped<IAuditLogRepository, AuditLogRepository>();
        services.AddScoped<ITransactionHistoryReadRepository, TransactionHistoryRepository>();
        services.AddScoped<IInvoiceReadRepository, InvoiceRepository>();
        services.AddScoped<IDashboardRepository, DashboardRepository>();
        services.AddScoped<IProfileRepository, ProfileRepository>();
        services.AddScoped<INotificationRepository, NotificationRepository>();
        services.AddScoped<IUserAuthRepository, UserAuthRepository>();
        services.AddScoped<IMobileAppConfigurationRepository, MobileAppConfigurationRepository>();
        services.AddScoped<IWalletRepository, WalletRepository>();

        services.AddScoped<IProductService, ProductReadService>();
        services.AddScoped<ICartService, CartService>();
        services.AddScoped<IAuditLogService, AuditLogService>();
        services.AddScoped<ITransactionHistoryService, TransactionHistoryService>();
        services.AddScoped<IInvoiceService, InvoiceService>();
        services.AddScoped<IDashboardService, DashboardService>();
        services.AddScoped<IProfileService, ProfileService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<INotificationRealtimePublisher, NotificationRealtimePublisher>();
        services.AddScoped<IPushNotificationSender, PushNotificationSender>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IRegistrationDocumentService, RegistrationDocumentFileStorageService>();
        services.AddScoped<IProfileMediaService, ProfileMediaFileStorageService>();
        services.AddScoped<IMobileAppConfigurationService, MobileAppConfigurationService>();
        services.AddScoped<IWalletService, WalletService>();
        services.AddScoped<ICheckoutService, CheckoutService>();
        services.AddScoped<IWalletActionValidationService, WalletActionValidationService>();
        services.AddScoped<IAdminWorkspaceService, AdminWorkspaceService>();
        services.AddScoped<ISellerWorkspaceService, SellerWorkspaceService>();
        services.AddScoped<IWebAdminDashboardService, WebAdminDashboardService>();
        services.AddScoped<ISystemFeeService, SystemFeeService>();
        services.AddScoped<ISellerProductFeeService, SellerProductFeeService>();
        services.AddScoped<IAdminTransactionFeeService, AdminTransactionFeeService>();
        services.AddScoped<IFeeCalculationService, FeeCalculationService>();
        services.AddScoped<IOtpDeliveryService, OtpDeliveryService>();
        services.AddSingleton<IOtpSessionStore, OtpSessionMemoryStore>();
        services.AddScoped<IOtpService, OtpService>();
        services.AddScoped<ICheckoutOtpOrchestrator, CheckoutOtpOrchestrator>();
        services.AddSingleton<IPasswordHasher, Pbkdf2PasswordHasher>();
        services.AddSingleton<ITokenService, JwtTokenService>();

        return services;
    }
}
