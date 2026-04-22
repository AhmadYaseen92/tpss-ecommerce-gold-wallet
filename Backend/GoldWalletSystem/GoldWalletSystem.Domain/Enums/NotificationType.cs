namespace GoldWalletSystem.Domain.Enums;

public enum NotificationType
{
    General = 0,
    KycPending = 1,
    InvoiceIssued = 2,
    RequestUpdated = 3,
    OrderApproved = 4,
    OrderRejected = 5,
    SellApproved = 6,
    SellRejected = 7,
    PickupApproved = 8,
    PickupRejected = 9,
    TransferReceived = 10,
    GiftReceived = 11,
    CertificateIssued = 12,
    Announcement = 13,
    StockWarning = 14
}
