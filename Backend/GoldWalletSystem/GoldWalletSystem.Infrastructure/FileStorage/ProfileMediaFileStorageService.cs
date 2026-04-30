using GoldWalletSystem.Application.Interfaces.Services;
using System.Text.RegularExpressions;

namespace GoldWalletSystem.Infrastructure.FileStorage;

public partial class ProfileMediaFileStorageService(IWebHostEnvironment environment) : IProfileMediaService
{
    private const string ProfilePhotosFolder = "images/profile";

    public async Task<string> ResolveProfilePhotoUrlAsync(int userId, string profilePhotoUrl, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(profilePhotoUrl)) return string.Empty;

        var trimmed = profilePhotoUrl.Trim();
        var match = DataUrlRegex().Match(trimmed);
        if (!match.Success) return trimmed;

        var contentType = match.Groups["type"].Value;
        var base64Payload = match.Groups["payload"].Value;

        byte[] bytes;
        try { bytes = Convert.FromBase64String(base64Payload); }
        catch (FormatException) { return trimmed; }

        var extension = contentType.ToLowerInvariant() switch
        {
            "image/jpeg" => ".jpg",
            "image/jpg" => ".jpg",
            "image/png" => ".png",
            "image/webp" => ".webp",
            _ => ".bin"
        };

        var root = string.IsNullOrWhiteSpace(environment.WebRootPath)
            ? Path.Combine(environment.ContentRootPath, "wwwroot")
            : environment.WebRootPath;

        var targetDirectory = Path.Combine(root, ProfilePhotosFolder, userId.ToString());
        Directory.CreateDirectory(targetDirectory);

        var fileName = $"profile-{Guid.NewGuid():N}{extension}";
        var filePath = Path.Combine(targetDirectory, fileName);
        await File.WriteAllBytesAsync(filePath, bytes, cancellationToken);

        return $"/{ProfilePhotosFolder}/{userId}/{fileName}";
    }

    [GeneratedRegex("^data:(?<type>image\\/[a-zA-Z0-9.+-]+);base64,(?<payload>.+)$", RegexOptions.Compiled)]
    private static partial Regex DataUrlRegex();
}
