using TPSS.GoldWallet.Domain.Common;
using TPSS.GoldWallet.Domain.Enums;

namespace TPSS.GoldWallet.Domain.Entities;

public sealed class UserProfile : Entity
{
    private UserProfile() { }

    public UserProfile(Guid id, string email, string firstName, string lastName, string countryCode)
    {
        Id = id;
        Email = email;
        FirstName = firstName;
        LastName = lastName;
        CountryCode = countryCode;
        KycStatus = KycStatus.Pending;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public string Email { get; private set; } = string.Empty;
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;
    public string CountryCode { get; private set; } = string.Empty;
    public KycStatus KycStatus { get; private set; }
    public DateTime CreatedAtUtc { get; private set; }

    public void UpdateNames(string firstName, string lastName)
    {
        FirstName = firstName;
        LastName = lastName;
    }

    public void SetKycStatus(KycStatus status) => KycStatus = status;
}
