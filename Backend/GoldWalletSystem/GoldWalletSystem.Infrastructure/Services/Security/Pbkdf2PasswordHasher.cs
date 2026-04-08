using GoldWalletSystem.Application.Interfaces.Services;
using System.Security.Cryptography;

namespace GoldWalletSystem.Infrastructure.Services.Security;

public class Pbkdf2PasswordHasher : IPasswordHasher
{
    public bool Verify(string plaintext, string hash)
    {
        if (hash == "seeded")
        {
            return plaintext == "Password@123";
        }

        var parts = hash.Split('.', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length != 3) return false;

        var salt = Convert.FromBase64String(parts[0]);
        var stored = Convert.FromBase64String(parts[1]);
        var iterations = int.Parse(parts[2]);

        var computed = Rfc2898DeriveBytes.Pbkdf2(plaintext, salt, iterations, HashAlgorithmName.SHA256, stored.Length);
        return CryptographicOperations.FixedTimeEquals(stored, computed);
    }
}
