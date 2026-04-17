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
            var role = principal?.FindFirstValue("role");
            var sellerIdClaim = principal?.FindFirstValue("seller_id");
            if (string.Equals(role, GoldWalletSystem.Domain.Constants.SystemRoles.Seller, StringComparison.OrdinalIgnoreCase)
                && int.TryParse(sellerIdClaim, out _))
            {
                return null;
            }

            var value = principal?.FindFirstValue("sub")
                ?? principal?.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? principal?.FindFirstValue(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub);

            return int.TryParse(value, out var userId) ? userId : null;
        }
    }


    public int? SellerId
    {
        get
        {
            var principal = accessor.HttpContext?.User;
            var value = principal?.FindFirstValue("seller_id");
            return int.TryParse(value, out var sellerId) ? sellerId : null;
        }
    }

    public bool IsInRole(string role)
        => accessor.HttpContext?.User?.IsInRole(role) ?? false;
}
