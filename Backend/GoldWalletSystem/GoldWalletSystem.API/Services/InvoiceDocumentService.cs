using GoldWalletSystem.API.Helpers;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.API.Services;

public interface IInvoiceDocumentService
{
    Task<string> SaveWalletInvoiceAsync(int userId, string actionType, WalletAsset asset, int quantity, decimal amount, CancellationToken cancellationToken = default);
    Task<string> SaveTransactionInvoiceAsync(TransactionHistory request, CancellationToken cancellationToken = default);
    bool Exists(string? fileUrl);
    string? ToAbsoluteUrl(HttpRequest request, string? fileUrl);
}

public class InvoiceDocumentService(IWebHostEnvironment environment) : IInvoiceDocumentService
{
    public async Task<string> SaveWalletInvoiceAsync(int userId, string actionType, WalletAsset asset, int quantity, decimal amount, CancellationToken cancellationToken = default)
    {
        var path = BuildPath(userId);
        var lines = new (string Label, string Value)[]
        {
            ("Date (UTC)", DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss")),
            ("Action", actionType),
            ("Investor User Id", userId.ToString()),
            ("Asset Id", asset.Id.ToString()),
            ("Asset Type", asset.AssetType.ToString()),
            ("Category", asset.Category.ToString()),
            ("Quantity", quantity.ToString()),
            ("Weight", $"{asset.Weight} {asset.Unit}"),
            ("Purity", asset.Purity.ToString()),
            ("Amount", amount.ToString())
        };
        await WritePdf(path.PhysicalPath, lines, cancellationToken);
        return path.RelativeUrl;
    }

    public async Task<string> SaveTransactionInvoiceAsync(TransactionHistory request, CancellationToken cancellationToken = default)
    {
        var path = BuildPath(request.UserId);
        var lines = new (string Label, string Value)[]
        {
            ("Date (UTC)", DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss")),
            ("Action", request.TransactionType),
            ("Investor User Id", request.UserId.ToString()),
            ("Quantity", request.Quantity.ToString()),
            ("Weight", $"{request.Weight} {request.Unit}"),
            ("Purity", request.Purity.ToString()),
            ("Amount", request.Amount.ToString())
        };
        await WritePdf(path.PhysicalPath, lines, cancellationToken);
        return path.RelativeUrl;
    }

    public bool Exists(string? fileUrl)
    {
        if (string.IsNullOrWhiteSpace(fileUrl)) return false;
        var root = ResolveRoot();
        var relative = fileUrl.Trim().TrimStart('/');
        var physicalPath = Path.Combine(root, relative.Replace('/', Path.DirectorySeparatorChar));
        return File.Exists(physicalPath);
    }

    public string? ToAbsoluteUrl(HttpRequest request, string? fileUrl)
    {
        if (string.IsNullOrWhiteSpace(fileUrl)) return null;
        if (Uri.TryCreate(fileUrl, UriKind.Absolute, out _)) return fileUrl;
        var normalized = fileUrl.StartsWith('/') ? fileUrl : $"/{fileUrl}";
        return $"{request.Scheme}://{request.Host}{normalized}";
    }

    private (string PhysicalPath, string RelativeUrl) BuildPath(int userId)
    {
        var root = ResolveRoot();
        var folder = Path.Combine(root, "Certificats", userId.ToString());
        Directory.CreateDirectory(folder);
        var fileName = $"invoice-{Guid.NewGuid():N}.pdf";
        return (Path.Combine(folder, fileName), $"/Certificats/{userId}/{fileName}");
    }

    private async Task WritePdf(string filePath, (string Label, string Value)[] lines, CancellationToken cancellationToken)
    {
        var pdfBytes = InvoicePdfTemplateBuilder.Build("Gold Wallet Invoice", lines);
        await File.WriteAllBytesAsync(filePath, pdfBytes, cancellationToken);
    }

    private string ResolveRoot()
        => string.IsNullOrWhiteSpace(environment.WebRootPath)
            ? Path.Combine(environment.ContentRootPath, "wwwroot")
            : environment.WebRootPath;
}
