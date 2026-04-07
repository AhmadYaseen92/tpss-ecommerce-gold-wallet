using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Profile.Queries.GetMyProfile;

public sealed class GetMyProfileQueryHandler(IUserProfileRepository userProfileRepository)
    : IRequestHandler<GetMyProfileQuery, ProfileDto>
{
    public async Task<ProfileDto> Handle(GetMyProfileQuery request, CancellationToken cancellationToken)
    {
        var profile = await userProfileRepository.GetByIdAsync(request.CustomerId, cancellationToken)
                      ?? throw new InvalidOperationException("Profile not found.");

        return new ProfileDto(profile.Id, profile.Email, profile.FirstName, profile.LastName, profile.CountryCode, profile.KycStatus);
    }
}
