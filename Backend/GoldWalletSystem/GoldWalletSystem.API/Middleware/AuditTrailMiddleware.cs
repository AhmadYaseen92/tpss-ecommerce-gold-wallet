using GoldWalletSystem.Infrastructure.Database.Context;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.API.Middleware;

public sealed class AuditTrailMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context, AppDbContext dbContext)
    {
        var startedAt = DateTime.UtcNow;
        await next(context);

        if (context.Request.Path.StartsWithSegments("/health") ||
            context.Request.Path.StartsWithSegments("/openapi") ||
            context.Request.Path.StartsWithSegments("/swagger"))
        {
            return;
        }

        try
        {
            var userIdValue = context.User.FindFirst("sub")?.Value;
            var userId = int.TryParse(userIdValue, out var parsedUserId) ? parsedUserId : (int?)null;
            var details = $"{context.Request.Method} {context.Request.Path} => {context.Response.StatusCode} ({DateTime.UtcNow - startedAt:mm\\:ss})";

            dbContext.AuditLogs.Add(new AuditLog
            {
                UserId = userId,
                Action = "ApiRequest",
                EntityName = "HttpRequest",
                Details = details,
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow,
            });

            await dbContext.SaveChangesAsync();
        }
        catch
        {
            // Do not block request pipeline if audit logging fails.
        }
    }
}
