using GoldWalletSystem.API.Models;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Services;

public interface IProductWriteService
{
    Task<string> CreateAsync(ProductUpsertRequest request, CancellationToken cancellationToken = default);
    Task<string> UpdateAsync(int id, ProductUpsertRequest request, CancellationToken cancellationToken = default);
    Task<string> DeleteAsync(int id, CancellationToken cancellationToken = default);
}

public class ProductWriteService(AppDbContext dbContext, IWebHostEnvironment environment, ICurrentUserService currentUser, IMarketplaceRealtimeNotifier realtimeNotifier) : IProductWriteService
{
    public async Task<string> CreateAsync(ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
        EnsureSellerOrAdmin();
        if (await dbContext.Products.AnyAsync(x => x.Sku == request.Sku, cancellationToken)) throw new InvalidOperationException("SKU already exists");
        var sellerId = ResolveSellerId(request.SellerId);
        var product = new Product { Name=request.Name,Sku=request.Sku,Description=request.Description,ImageUrl=await SaveImageAsync(request.Image,request.ExistingImageUrl,cancellationToken),VideoUrl=await SaveVideoAsync(request.Video,request.ExistingVideoUrl,cancellationToken),Category=ToLegacyCategory(request.MaterialType),MaterialType=request.MaterialType,FormType=request.FormType,PricingMode=request.PricingMode,PurityKarat=request.PurityKarat,PurityFactor=request.PurityFactor,WeightValue=request.WeightValue,WeightUnit=ProductWeightUnit.Gram,BaseMarketPrice=0,FixedPrice=request.FixedPrice,OfferPercent=request.OfferPercent,OfferNewPrice=request.OfferNewPrice,OfferType=request.OfferType,IsHasOffer=request.OfferType!=ProductOfferType.None,AvailableStock=request.AvailableStock,IsActive=request.IsActive,SellerId=sellerId};
        RecalculateComputedPrices(product); dbContext.Products.Add(product); await dbContext.SaveChangesAsync(cancellationToken); await realtimeNotifier.BroadcastRefreshHintAsync($"product:create:{product.Id}", cancellationToken); return "Created";
    }
    public async Task<string> UpdateAsync(int id, ProductUpsertRequest request, CancellationToken cancellationToken = default)
    {
        EnsureSellerOrAdmin(); var product=await dbContext.Products.FirstOrDefaultAsync(x=>x.Id==id,cancellationToken) ?? throw new InvalidOperationException("Product not found");
        if (!currentUser.IsInRole(SystemRoles.Admin) && product.SellerId!=currentUser.SellerId) throw new UnauthorizedAccessException("Forbidden");
        if (!string.Equals(product.Sku, request.Sku, StringComparison.OrdinalIgnoreCase) && await dbContext.Products.AnyAsync(x=>x.Sku==request.Sku&&x.Id!=id,cancellationToken)) throw new InvalidOperationException("SKU already exists");
        var sellerId=ResolveSellerId(request.SellerId, product.SellerId);
        product.Name=request.Name; product.Sku=request.Sku; product.Description=request.Description; product.ImageUrl=await SaveImageAsync(request.Image,request.ExistingImageUrl??product.ImageUrl,cancellationToken); product.VideoUrl=await SaveVideoAsync(request.Video,request.ExistingVideoUrl??product.VideoUrl,cancellationToken); product.Category=ToLegacyCategory(request.MaterialType); product.MaterialType=request.MaterialType; product.FormType=request.FormType; product.PricingMode=request.PricingMode; product.PurityKarat=request.PurityKarat; product.PurityFactor=request.PurityFactor; product.WeightValue=request.WeightValue; product.WeightUnit=ProductWeightUnit.Gram; product.FixedPrice=request.FixedPrice; product.OfferPercent=request.OfferPercent; product.OfferNewPrice=request.OfferNewPrice; product.OfferType=request.OfferType; product.IsHasOffer=request.OfferType!=ProductOfferType.None; product.AvailableStock=request.AvailableStock; product.IsActive=request.IsActive; product.SellerId=sellerId; RecalculateComputedPrices(product); await dbContext.SaveChangesAsync(cancellationToken); await realtimeNotifier.BroadcastRefreshHintAsync($"product:update:{product.Id}", cancellationToken); return "Updated";
    }
    public async Task<string> DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        EnsureSellerOrAdmin(); var product=await dbContext.Products.FirstOrDefaultAsync(x=>x.Id==id,cancellationToken) ?? throw new InvalidOperationException("Product not found");
        if (!currentUser.IsInRole(SystemRoles.Admin) && product.SellerId!=currentUser.SellerId) throw new UnauthorizedAccessException("Forbidden");
        dbContext.Products.Remove(product); await dbContext.SaveChangesAsync(cancellationToken); await realtimeNotifier.BroadcastRefreshHintAsync($"product:delete:{id}", cancellationToken); return "Deleted";
    }
    private void EnsureSellerOrAdmin(){ if(!currentUser.IsInRole(SystemRoles.Admin)&&!currentUser.IsInRole(SystemRoles.Seller)) throw new UnauthorizedAccessException("Forbidden"); }
    private int ResolveSellerId(int? requested, int fallback=0){ if(currentUser.IsInRole(SystemRoles.Admin)){ var r=requested??fallback; if(r<=0) throw new InvalidOperationException("SellerId is required for admin operations."); return r;} if(currentUser.SellerId.HasValue&&currentUser.SellerId>0) return currentUser.SellerId.Value; throw new UnauthorizedAccessException("Seller scope is required."); }
    private static ProductCategory ToLegacyCategory(ProductMaterialType m)=>m switch{ProductMaterialType.Gold=>ProductCategory.Gold,ProductMaterialType.Silver=>ProductCategory.Silver,ProductMaterialType.Diamond=>ProductCategory.Diamond,_=>ProductCategory.Gold};
    private static void RecalculateComputedPrices(Product p){ var auto=ProductPricingCalculator.CalculateAutoPrice(p.MaterialType,p.BaseMarketPrice,p.WeightValue,p.PurityFactor); p.AutoPrice=auto; var src=p.PricingMode==ProductPricingMode.Manual?p.FixedPrice:p.AutoPrice; p.SellPrice=ProductPricingCalculator.ApplyOffer(src,p.OfferType,p.OfferPercent,p.OfferNewPrice); }
    private async Task<string> SaveImageAsync(IFormFile? image,string? existing,CancellationToken ct){ if(image is null||image.Length==0) return existing??string.Empty; var root=string.IsNullOrWhiteSpace(environment.WebRootPath)?Path.Combine(environment.ContentRootPath,"wwwroot"):environment.WebRootPath; var dir=Path.Combine(root,"images","products"); Directory.CreateDirectory(dir); var file=$"product-{Guid.NewGuid():N}{Path.GetExtension(image.FileName)}"; var full=Path.Combine(dir,file); await using var s=File.Create(full); await image.CopyToAsync(s,ct); return $"/images/products/{file}"; }
    private async Task<string> SaveVideoAsync(IFormFile? video,string? existing,CancellationToken ct){ if(video is null||video.Length==0) return existing??string.Empty; var root=string.IsNullOrWhiteSpace(environment.WebRootPath)?Path.Combine(environment.ContentRootPath,"wwwroot"):environment.WebRootPath; var dir=Path.Combine(root,"videos","products"); Directory.CreateDirectory(dir); var file=$"product-video-{Guid.NewGuid():N}{Path.GetExtension(video.FileName)}"; var full=Path.Combine(dir,file); await using var s=File.Create(full); await video.CopyToAsync(s,ct); return $"/videos/products/{file}"; }
}
