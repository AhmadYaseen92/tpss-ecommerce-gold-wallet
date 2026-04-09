using TPSS.GoldWallet.Domain.Common;
using TPSS.GoldWallet.Domain.Enums;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class KycVerification : Entity
{
    private KycVerification() { }

    public KycVerification(Guid customerId, string documentType, string documentNumber, string provider)
    {
        CustomerId = customerId;
        DocumentType = documentType;
        DocumentNumber = documentNumber;
        Provider = provider;
        Status = KycStatus.Pending;
        SubmittedAtUtc = DateTime.UtcNow;
    }

    public Guid CustomerId { get; private set; }
    public string DocumentType { get; private set; } = string.Empty;
    public string DocumentNumber { get; private set; } = string.Empty;
    public string Provider { get; private set; } = string.Empty;
    public KycStatus Status { get; private set; }
    public DateTime SubmittedAtUtc { get; private set; }
    public DateTime? ReviewedAtUtc { get; private set; }
}
