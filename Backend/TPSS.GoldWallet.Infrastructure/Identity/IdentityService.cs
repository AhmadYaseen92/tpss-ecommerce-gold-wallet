using Microsoft.AspNetCore.Identity;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.Security;

namespace TPSS.GoldWallet.Infrastructure.Identity;

public sealed class IdentityService(
    UserManager<AppIdentityUser> userManager,
    SignInManager<AppIdentityUser> signInManager,
    RoleManager<IdentityRole<Guid>> roleManager) : IIdentityService
{
    public async Task<(bool Succeeded, Guid UserId, string Email, string Role)> ValidateCredentialsAsync(string email, string password, CancellationToken cancellationToken = default)
    {
        var user = await userManager.FindByEmailAsync(email);
        if (user is null)
        {
            return (false, Guid.Empty, string.Empty, string.Empty);
        }

        var signIn = await signInManager.CheckPasswordSignInAsync(user, password, lockoutOnFailure: true);
        if (!signIn.Succeeded)
        {
            return (false, Guid.Empty, string.Empty, string.Empty);
        }

        var roles = await userManager.GetRolesAsync(user);
        return (true, user.Id, user.Email ?? email, roles.FirstOrDefault() ?? RoleNames.Customer);
    }

    public async Task EnsureRolesSeededAsync(CancellationToken cancellationToken = default)
    {
        var roles = new[] { RoleNames.Customer, RoleNames.ComplianceOfficer, RoleNames.Admin };

        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole<Guid>(role));
            }
        }
    }
}
