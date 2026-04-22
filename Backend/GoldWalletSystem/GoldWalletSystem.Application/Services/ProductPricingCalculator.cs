using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Services;

public static class ProductPricingCalculator
{
    private const decimal GramsPerOunce = 31.1035m;

    public static decimal CalculateAutoPrice(
        ProductMaterialType materialType,
        decimal baseMarketPrice,
        decimal weightInGrams,
        decimal purityFactor)
    {
        var basePrice = materialType switch
        {
            ProductMaterialType.Gold or ProductMaterialType.Silver => (weightInGrams / GramsPerOunce) * baseMarketPrice,
            ProductMaterialType.Diamond => (weightInGrams / 0.2m) * baseMarketPrice,
            _ => weightInGrams * baseMarketPrice
        };

        var purityAdjusted = purityFactor > 0 ? basePrice * purityFactor : basePrice;
        return decimal.Round(purityAdjusted, 2, MidpointRounding.AwayFromZero);
    }

    public static decimal ApplyOffer(decimal sellPrice, ProductOfferType offerType, decimal offerPercent, decimal offerNewPrice)
    {
        var finalPrice = offerType switch
        {
            ProductOfferType.PercentBased when offerPercent > 0 => sellPrice * (1 - (offerPercent / 100m)),
            ProductOfferType.FixedPriceBased when offerNewPrice > 0 => offerNewPrice,
            _ => sellPrice
        };

        return decimal.Round(finalPrice, 2, MidpointRounding.AwayFromZero);
    }
}
