using GoldWalletSystem.Application.Interfaces.Services;
using System.Security.Claims;

namespace GoldWalletSystem.API.Services;

public class CurrentUserService(IHttpContextAccessor accessor) : ICurrentUserService
{
    public int? UserId
    {
        get
        {
            var principal = accessor.HttpContext?.User;
            var value = principal?.FindFirstValue("sub")
                ?? principal?.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? principal?.FindFirstValue(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub);

            return int.TryParse(value, out var userId) ? userId : null;
        }
    }

    public bool IsInRole(string role)
        => accessor.HttpContext?.User?.IsInRole(role) ?? false;
}
