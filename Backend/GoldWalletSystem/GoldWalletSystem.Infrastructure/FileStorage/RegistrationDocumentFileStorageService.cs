using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.StaticFiles;
using System.Text.RegularExpressions;

namespace GoldWalletSystem.Infrastructure.FileStorage;

public partial class RegistrationDocumentFileStorageService(IWebHostEnvironment environment) : IRegistrationDocumentService
{
    private static readonly FileExtensionContentTypeProvider ContentTypeProvider = new();

    public async Task PersistSellerDocumentsAsync(RegisterRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!string.Equals(request.Role, SystemRoles.Seller, StringComparison.OrdinalIgnoreCase))
            return;

        var segment = BuildStorageSegment(request);
        var webRoot = string.IsNullOrWhiteSpace(environment.WebRootPath)
            ? Path.Combine(environment.ContentRootPath, "wwwroot")
            : environment.WebRootPath;
        var baseDir = Path.Combine(webRoot, "kyc", segment);
        Directory.CreateDirectory(baseDir);

        foreach (var doc in request.Documents)
        {
            if (string.IsNullOrWhiteSpace(doc.FilePath) || !doc.FilePath.StartsWith("data:", StringComparison.OrdinalIgnoreCase))
                continue;

            var commaIndex = doc.FilePath.IndexOf(',');
            if (commaIndex <= 0) continue;

            var meta = doc.FilePath[..commaIndex];
            var base64 = doc.FilePath[(commaIndex + 1)..];
            if (!meta.Contains(";base64", StringComparison.OrdinalIgnoreCase)) continue;

            byte[] bytes;
            try { bytes = Convert.FromBase64String(base64); }
            catch { continue; }

            var safeFileName = SanitizeFileName(doc.FileName);
            if (string.IsNullOrWhiteSpace(safeFileName))
                safeFileName = $"{doc.DocumentType}_{DateTime.UtcNow:yyyyMMddHHmmssfff}.bin";

            var physicalPath = Path.Combine(baseDir, safeFileName);
            await File.WriteAllBytesAsync(physicalPath, bytes, cancellationToken);

            doc.FilePath = $"/kyc/{segment}/{safeFileName}".Replace("\\", "/");

            if (string.IsNullOrWhiteSpace(doc.ContentType) || doc.ContentType == "application/octet-stream")
            {
                var contentTypeMatch = ContentTypeRegex().Match(meta);
                if (contentTypeMatch.Success)
                    doc.ContentType = contentTypeMatch.Groups["type"].Value;
            }

            if ((string.IsNullOrWhiteSpace(doc.ContentType) || doc.ContentType == "application/octet-stream") &&
                ContentTypeProvider.TryGetContentType(safeFileName, out var inferredContentType))
            {
                doc.ContentType = inferredContentType;
            }
        }
    }

    private static string BuildStorageSegment(RegisterRequestDto request)
    {
        var raw = !string.IsNullOrWhiteSpace(request.CompanyInfo.CompanyCode)
            ? request.CompanyInfo.CompanyCode
            : request.CompanyInfo.CompanyName;

        if (string.IsNullOrWhiteSpace(raw)) raw = "seller";
        var cleaned = Regex.Replace(raw.ToLowerInvariant(), @"[^a-z0-9\-]+", "-").Trim('-');
        return string.IsNullOrWhiteSpace(cleaned) ? "seller" : cleaned;
    }

    private static string SanitizeFileName(string? name)
    {
        if (string.IsNullOrWhiteSpace(name)) return string.Empty;
        var fileName = Path.GetFileName(name);
        foreach (var c in Path.GetInvalidFileNameChars()) fileName = fileName.Replace(c, '_');
        return fileName;
    }

    [GeneratedRegex(@"^data:(?<type>[^;]+);base64$", RegexOptions.IgnoreCase)]
    private static partial Regex ContentTypeRegex();
}
