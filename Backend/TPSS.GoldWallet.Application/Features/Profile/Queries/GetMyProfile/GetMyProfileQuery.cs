using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Profile.Queries.GetMyProfile;

public sealed record GetMyProfileQuery(Guid CustomerId) : IRequest<ProfileDto>;
