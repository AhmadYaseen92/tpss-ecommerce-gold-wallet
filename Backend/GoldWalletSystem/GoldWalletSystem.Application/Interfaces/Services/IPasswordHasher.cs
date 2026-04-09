namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IPasswordHasher
{
    bool Verify(string plaintext, string hash);
}
