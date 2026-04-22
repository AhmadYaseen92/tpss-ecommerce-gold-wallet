namespace GoldWalletSystem.Domain.Constants;

public static class FeeCodes
{
    public const string CommissionPerTransaction = "commission_per_transaction";
    public const string PremiumDiscount = "premium_discount";
    public const string StorageCustodyFee = "storage_custody_fee";
    public const string DeliveryFee = "delivery_fee";
    public const string ServiceCharge = "service_charge";
    public const string ServiceFee = "service_fee";

    public static readonly string[] SellerManaged =
    [
        CommissionPerTransaction,
        PremiumDiscount,
        StorageCustodyFee,
        DeliveryFee,
        ServiceCharge
    ];
}
