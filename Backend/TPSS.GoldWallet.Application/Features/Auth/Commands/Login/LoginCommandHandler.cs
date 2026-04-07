using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Application.Features.Auth.Commands.Login;

public sealed class LoginCommandHandler(IIdentityService identityService, ITokenService tokenService)
    : IRequestHandler<LoginCommand, AuthTokenDto>
{
    public async Task<AuthTokenDto> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var result = await identityService.ValidateCredentialsAsync(request.Email, request.Password, cancellationToken);
        if (!result.Succeeded)
        {
            throw new UnauthorizedAccessException("Invalid credentials.");
        }

        var permissions = result.Role switch
        {
            RoleNames.Admin => new[]
            {
                PermissionNames.CatalogRead, PermissionNames.CartRead, PermissionNames.CartWrite,
                PermissionNames.WalletRead, PermissionNames.WalletWrite, PermissionNames.ProfileRead,
                PermissionNames.ProfileWrite, PermissionNames.KycSubmit, PermissionNames.DashboardRead,
                PermissionNames.HistoryRead, PermissionNames.AuditRead
            },
            RoleNames.ComplianceOfficer => new[]
            {
                PermissionNames.ProfileRead, PermissionNames.KycSubmit, PermissionNames.AuditRead
            },
            _ => new[]
            {
                PermissionNames.CatalogRead, PermissionNames.CartRead, PermissionNames.CartWrite,
                PermissionNames.WalletRead, PermissionNames.WalletWrite, PermissionNames.ProfileRead,
                PermissionNames.ProfileWrite, PermissionNames.KycSubmit, PermissionNames.DashboardRead,
                PermissionNames.HistoryRead
            }
        };

        var token = tokenService.CreateToken(result.UserId, result.Email, result.Role, permissions);
        return new AuthTokenDto(token, DateTime.UtcNow.AddHours(2), result.Role);
    }
}
