using GoldWalletSystem.Application.Interfaces.Services;
using System.Security.Cryptography;

namespace GoldWalletSystem.Infrastructure.Services.Security;

public class Pbkdf2PasswordHasher : IPasswordHasher
{
    private const int SaltSize = 16;
    private const int HashSize = 32;
    private const int Iterations = 100_000;

    public string Hash(string plaintext)
    {
        var salt = RandomNumberGenerator.GetBytes(SaltSize);
        var hash = Rfc2898DeriveBytes.Pbkdf2(
            plaintext,
            salt,
            Iterations,
            HashAlgorithmName.SHA256,
            HashSize
        );

        return $"{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}.{Iterations}";
    }

    public bool Verify(string plaintext, string hash)
    {
        var parts = hash.Split('.', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length != 3) return false;

        var salt = Convert.FromBase64String(parts[0]);
        var stored = Convert.FromBase64String(parts[1]);
        var iterations = int.Parse(parts[2]);

        var computed = Rfc2898DeriveBytes.Pbkdf2(plaintext, salt, iterations, HashAlgorithmName.SHA256, stored.Length);
        return CryptographicOperations.FixedTimeEquals(stored, computed);
    }
}
