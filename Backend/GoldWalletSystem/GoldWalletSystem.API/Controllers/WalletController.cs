using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Wallet;
using GoldWalletSystem.Application.Interfaces.Realtime;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Realtime;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/wallet")]
public class WalletController(
    IWalletService walletService,
    ICurrentUserService currentUser,
    AppDbContext dbContext,
    IMarketplaceRealtimeEventPublisher realtimeEventPublisher) : SecuredControllerBase(currentUser)
{
    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await walletService.GetByUserIdAsync(request.UserId, cancellationToken);
        return Ok(ApiResponse<WalletDto>.Ok(data));
    }

    [HttpPost("actions/request")]
    public async Task<IActionResult> CreateWalletActionRequest([FromBody] WalletActionRequest request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var wallet = await dbContext.Wallets
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        var entity = new TransactionHistory
        {
            UserId = request.UserId,
            SellerId = request.SellerId,
            TransactionType = request.ActionType.Trim().ToLowerInvariant(),
            Status = "pending",
            Category = request.Category,
            Quantity = Math.Max(1, request.Quantity),
            UnitPrice = request.UnitPrice,
            Weight = request.Weight,
            Unit = string.IsNullOrWhiteSpace(request.Unit) ? "gram" : request.Unit,
            Purity = request.Purity,
            Amount = request.Amount,
            Currency = wallet?.CurrencyCode ?? "USD",
            Notes = request.Notes ?? "Mobile wallet action request",
            CreatedAtUtc = DateTime.UtcNow
        };

        dbContext.TransactionHistories.Add(entity);
        dbContext.AuditLogs.Add(new AuditLog
        {
            UserId = request.UserId,
            Action = "WalletActionRequested",
            EntityName = "TransactionHistory",
            Details = $"Action={entity.TransactionType}, amount={entity.Amount}, qty={entity.Quantity}, category={entity.Category}",
            CreatedAtUtc = DateTime.UtcNow
        });
        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeEventPublisher.PublishAsync(
            MarketplaceRealtimeEvent.Build(
                MarketplaceRealtimeEntities.Request,
                "created",
                $"r-{entity.Id}",
                userId: entity.UserId,
                sellerId: entity.SellerId),
            cancellationToken);
        await realtimeEventPublisher.PublishAsync(
            MarketplaceRealtimeEvent.Build(MarketplaceRealtimeEntities.Dashboard, "updated", userId: entity.UserId, sellerId: entity.SellerId),
            cancellationToken);

        return Ok(ApiResponse<object>.Ok(new { id = $"r-{entity.Id}", status = entity.Status }, "Request submitted"));
    }

    public sealed class WalletActionRequest
    {
        public int UserId { get; set; }
        public int? SellerId { get; set; }
        public string ActionType { get; set; } = "sell";
        public string Category { get; set; } = "Gold";
        public int Quantity { get; set; } = 1;
        public decimal UnitPrice { get; set; }
        public decimal Weight { get; set; }
        public string Unit { get; set; } = "gram";
        public decimal Purity { get; set; }
        public decimal Amount { get; set; }
        public string? Notes { get; set; }
    }
}
