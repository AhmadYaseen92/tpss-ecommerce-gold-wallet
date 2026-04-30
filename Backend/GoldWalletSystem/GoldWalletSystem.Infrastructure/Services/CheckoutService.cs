using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Checkout;
using GoldWalletSystem.Application.DTOs.Fees;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Domain.Exceptions;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Services;

public class CheckoutService(AppDbContext dbContext, IOtpService otpService, ICheckoutOtpOrchestrator checkoutOtpOrchestrator, INotificationService notificationService, IFeeCalculationService feeCalculationService , ICurrentUserService currentUser) : ICheckoutService
{
    public Task<OtpDispatchResponseDto> RequestOtpAsync(CheckoutOtpRequestDto request, CancellationToken cancellationToken = default)
        => checkoutOtpOrchestrator.RequestAsync(request.UserId, request.ProductIds, request.ProductId, request.Quantity, request.ForceEmailFallback, cancellationToken);

    public Task<OtpDispatchResponseDto> ResendOtpAsync(ResendCheckoutOtpRequestDto request, CancellationToken cancellationToken = default)
        => otpService.ResendAsync(new ResendOtpRequestDto { UserId = request.UserId, OtpRequestId = request.OtpRequestId, ForceEmailFallback = request.ForceEmailFallback }, cancellationToken);

    public Task<VerifyOtpResponseDto> VerifyOtpAsync(VerifyCheckoutOtpRequestDto request, CancellationToken cancellationToken = default)
        => otpService.VerifyAsync(new VerifyOtpRequestDto { UserId = request.UserId, OtpRequestId = request.OtpRequestId, OtpCode = request.OtpCode }, cancellationToken);

    public async Task<CheckoutConfirmResponseDto> ConfirmAsync(CheckoutConfirmRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!(currentUser.IsInRole("Admin") || currentUser.UserId == request.UserId)) throw new BusinessException("CHECKOUT_FORBIDDEN", "Forbidden", 403);
        await checkoutOtpOrchestrator.EnsureOtpVerifiedAsync(request.UserId, request.ProductIds, request.ProductId, request.Quantity, request.OtpVerificationToken, request.OtpActionReferenceId, request.OtpRequestId, request.OtpCode, cancellationToken);
        var isDirectCheckout = request.ProductId.HasValue && request.Quantity.HasValue && request.Quantity.Value > 0;
        var fromCart = !isDirectCheckout;
        var wallet = await dbContext.Wallets.Include(x => x.Assets).FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);
        if (wallet is null) { wallet = new Wallet { UserId = request.UserId, CurrencyCode = "USD", CashBalance = 0, CreatedAtUtc = DateTime.UtcNow }; dbContext.Wallets.Add(wallet); await dbContext.SaveChangesAsync(cancellationToken); }
        var lines = new List<(Product Product, int Quantity)>(); Cart? cart = null;
        if (fromCart) { cart = await dbContext.Carts.Include(x=>x.Items).ThenInclude(x=>x.Product).ThenInclude(x=>x.Seller).FirstOrDefaultAsync(x=>x.UserId==request.UserId,cancellationToken) ?? throw new BusinessException("CHECKOUT_CART_NOT_FOUND","Cart not found."); if (cart.Items.Count==0) throw new BusinessException("CHECKOUT_CART_EMPTY","Cart is empty."); var selected = cart.Items.AsEnumerable(); if (request.ProductIds is {Count:>0}) { var set=request.ProductIds.ToHashSet(); selected=selected.Where(i=>set.Contains(i.ProductId)); } var list=selected.ToList(); if (list.Count==0) throw new BusinessException("CHECKOUT_NO_SELECTION","No matching cart items were selected for checkout."); lines.AddRange(list.Select(i=>(i.Product,i.Quantity))); }
        else { if (!request.ProductId.HasValue || !request.Quantity.HasValue || request.Quantity.Value<=0) throw new BusinessException("CHECKOUT_INVALID_QUANTITY","ProductId and positive Quantity are required."); var product=await dbContext.Products.Include(x=>x.Seller).FirstOrDefaultAsync(x=>x.Id==request.ProductId.Value&&x.IsActive,cancellationToken) ?? throw new BusinessException("CHECKOUT_PRODUCT_NOT_FOUND","Product not found."); lines.Add((product, request.Quantity.Value)); }
        var createdRequests = new List<TransactionHistory>(); var breakdowns = new List<FeeLineDto>();
        foreach (var (product, quantity) in lines){ if (product.AvailableStock<quantity) throw new BusinessException("CHECKOUT_STOCK_INSUFFICIENT",$"Insufficient stock for {product.Name}. Available {product.AvailableStock}, requested {quantity}."); var unitPrice=product.SellPrice; var subTotal=unitPrice*quantity; var fee=await feeCalculationService.CalculateAsync(new FeeCalculationRequest("buy",product.Id,product.SellerId,subTotal,quantity,unitPrice,0),cancellationToken); var h=new TransactionHistory{UserId=request.UserId,SellerId=product.SellerId,ProductId=product.Id,TransactionType="BUY",Status="pending",Category=product.Category.ToString(),Quantity=quantity,UnitPrice=unitPrice,Weight=ToGrams(product.WeightValue,product.WeightUnit)*quantity,Unit="gram",Purity=ParsePurity(product.Description),Notes=$"Checkout request from {(fromCart?"cart":"direct buy")}. SKU={product.Sku}",Amount=fee.FinalAmount,SubTotalAmount=fee.SubTotalAmount,TotalFeesAmount=fee.TotalFeesAmount,DiscountAmount=fee.DiscountAmount,FinalAmount=fee.FinalAmount,Currency=wallet.CurrencyCode,CreatedAtUtc=DateTime.UtcNow}; dbContext.TransactionHistories.Add(h); createdRequests.Add(h); breakdowns.AddRange(fee.Lines);}        
        if (fromCart && cart is not null){ if (request.ProductIds is {Count:>0}){ var set=request.ProductIds.ToHashSet(); dbContext.CartItems.RemoveRange(cart.Items.Where(x=>set.Contains(x.ProductId)));} else dbContext.CartItems.RemoveRange(cart.Items);}        
        await dbContext.SaveChangesAsync(cancellationToken);
        await notificationService.CreateAsync(new CreateNotificationRequestDto{UserId=request.UserId,Type=NotificationType.RequestUpdated,ReferenceType=NotificationReferenceType.Request,ReferenceId=createdRequests.FirstOrDefault()?.Id,ActionUrl="/wallet/requests",Title="Checkout submitted",Body="Your checkout request is pending approval."},cancellationToken);
        return new CheckoutConfirmResponseDto{UserId=request.UserId,FromCart=fromCart,ItemsCount=lines.Count,SubTotalAmount=createdRequests.Sum(x=>x.SubTotalAmount),TotalFeesAmount=createdRequests.Sum(x=>x.TotalFeesAmount),DiscountAmount=createdRequests.Sum(x=>x.DiscountAmount),FinalAmount=createdRequests.Sum(x=>x.FinalAmount),Currency=wallet.CurrencyCode,FeeBreakdowns=breakdowns};
    }
    private static decimal ToGrams(decimal w, ProductWeightUnit u)=>u switch{ProductWeightUnit.Kilogram=>w*1000m,ProductWeightUnit.Ounce=>w*31.1035m,_=>w};
    private static decimal ParsePurity(string d){ if(d.Contains("24k",StringComparison.OrdinalIgnoreCase))return 24m; if(d.Contains("22k",StringComparison.OrdinalIgnoreCase))return 22m; if(d.Contains("18k",StringComparison.OrdinalIgnoreCase))return 18m; return 0m; }
}
