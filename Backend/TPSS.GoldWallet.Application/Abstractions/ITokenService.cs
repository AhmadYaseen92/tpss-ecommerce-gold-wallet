namespace TPSS.GoldWallet.Application.Abstractions;

public interface ITokenService
{
    string CreateToken(Guid userId, string email, string role, IReadOnlyList<string> permissions);
}
