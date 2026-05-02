using System.Globalization;
using System.Text;

namespace GoldWalletSystem.API.Helpers;

internal static class InvoicePdfTemplateBuilder
{
    public static byte[] Build(string title, IReadOnlyList<(string Label, string Value)> fields)
    {
        var map = fields
            .GroupBy(x => x.Label?.Trim() ?? string.Empty, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.Last().Value?.Trim() ?? "-", StringComparer.OrdinalIgnoreCase);

        string Get(string key, string fallback = "-") => map.TryGetValue(key, out var value) && !string.IsNullOrWhiteSpace(value) ? value : fallback;

        var content = new StringBuilder();

        // Background + card
        content.AppendLine("0.97 0.97 0.97 rg");
        content.AppendLine("0 0 595 842 re f");
        content.AppendLine("1 1 1 rg");
        content.AppendLine("28 42 539 760 re f");
        content.AppendLine("0.86 0.86 0.86 RG");
        content.AppendLine("1 w");
        content.AppendLine("28 42 539 760 re S");

        WriteText(content, 220, 772, 18, "TAX INVOICE", 0.10, 0.10, 0.10);
        WriteText(content, 48, 744, 12, Get("Product Name", Get("Category", "Gold Wallet Item")), 0.12, 0.12, 0.12);
        WriteText(content, 420, 744, 11, $"Type: {Get("Action", Get("Action Type", "Bought"))}", 0.18, 0.18, 0.18);
        WriteText(content, 48, 726, 10, $"Ref: {Get("Invoice Number", Get("External Reference", "-"))}", 0.30, 0.30, 0.30);

        content.AppendLine("0.86 0.86 0.86 RG");
        content.AppendLine("48 712 m 545 712 l S");

        // Meta
        WriteText(content, 48, 688, 12, "Tax Invoice #:", 0.12, 0.12, 0.12);
        WriteText(content, 190, 688, 12, Get("Invoice Number", Get("Ref", "-")), 0.12, 0.12, 0.12);
        WriteText(content, 48, 665, 12, "Action Type:", 0.12, 0.12, 0.12);
        WriteText(content, 190, 665, 12, Get("Action", Get("Action Type", "Bought")), 0.12, 0.12, 0.12);
        WriteText(content, 48, 642, 12, "Issue Date:", 0.12, 0.12, 0.12);
        WriteText(content, 190, 642, 12, Get("Date (UTC)").Split(' ').FirstOrDefault() ?? "-", 0.12, 0.12, 0.12);
        WriteText(content, 48, 619, 12, "Status:", 0.12, 0.12, 0.12);
        WriteText(content, 190, 619, 12, Get("Status", "Issued"), 0.12, 0.12, 0.12);

        // Amount summary
        content.AppendLine("0.93 0.93 0.93 rg");
        content.AppendLine("44 220 507 150 re f");
        content.AppendLine("0.80 0.80 0.80 RG");
        content.AppendLine("44 220 507 150 re S");
        WriteText(content, 58, 346, 16, "Amount Summary", 0.12, 0.12, 0.12);
        WriteText(content, 58, 320, 13, $"Sub Total: {Get("Amount", Get("SubTotal", "-"))}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 296, 13, $"Fees: {Get("Fees", "0.00")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 272, 13, $"VAT / Tax: {Get("Tax", "0.00")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 248, 13, $"Discount: {Get("Discount", "0.00")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 228, 14, $"Grand Total: {Get("Amount", Get("Grand Total", "-"))}", 0.10, 0.10, 0.10);

        // Item details section
        content.AppendLine("0.96 0.96 0.96 rg");
        content.AppendLine("44 382 507 220 re f");
        content.AppendLine("0.80 0.80 0.80 RG");
        content.AppendLine("44 382 507 220 re S");
        WriteText(content, 58, 578, 15, "Item Details", 0.12, 0.12, 0.12);
        WriteText(content, 58, 552, 12, $"Product Name: {Get("Product Name", "Gold Item")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 530, 12, $"Category / Material: {Get("Category", "GOLD")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 508, 12, $"Weight: {Get("Weight", "-")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 486, 12, $"Purity / Karat: {Get("Purity", "N/A")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 464, 12, $"Quantity: {Get("Quantity", "1")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 442, 12, $"Asset Id: {Get("Asset Id", "-")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 420, 12, $"Investor User Id: {Get("Investor User Id", "-")}", 0.12, 0.12, 0.12);

        WriteText(content, 52, 92, 10, "This document serves as ownership and transaction proof. Electronically generated document.", 0.35, 0.35, 0.35);

        return BuildPdf(content.ToString());
    }

    private static List<string> Wrap(string text, int maxCharsPerLine)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return ["-"];
        }

        var words = text.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        var lines = new List<string>();
        var current = new StringBuilder();

        foreach (var word in words)
        {
            var nextLength = current.Length == 0 ? word.Length : current.Length + 1 + word.Length;
            if (nextLength > maxCharsPerLine && current.Length > 0)
            {
                lines.Add(current.ToString());
                current.Clear();
            }

            if (current.Length > 0)
            {
                current.Append(' ');
            }

            current.Append(word);
        }

        if (current.Length > 0)
        {
            lines.Add(current.ToString());
        }

        return lines.Count == 0 ? ["-"] : lines;
    }

    private static void WriteText(
        StringBuilder content,
        double x,
        double y,
        int fontSize,
        string text,
        double r,
        double g,
        double b)
    {
        content.AppendLine("BT");
        content.AppendLine($"/F1 {fontSize} Tf");
        content.AppendLine($"{FormatNumber(r)} {FormatNumber(g)} {FormatNumber(b)} rg");
        content.AppendLine($"1 0 0 1 {FormatNumber(x)} {FormatNumber(y)} Tm");
        content.AppendLine($"({EscapePdf(text)}) Tj");
        content.AppendLine("ET");
    }

    private static string EscapePdf(string value) => value
        .Replace("\\", "\\\\")
        .Replace("(", "\\(")
        .Replace(")", "\\)");

    private static string FormatNumber(double value) => value.ToString("0.###", CultureInfo.InvariantCulture);

    private static byte[] BuildPdf(string streamContent)
    {
        var objects = new List<string>
        {
            "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n",
            "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n",
            "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\nendobj\n",
            $"4 0 obj\n<< /Length {Encoding.ASCII.GetByteCount(streamContent)} >>\nstream\n{streamContent}endstream\nendobj\n",
            "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n"
        };

        var pdf = new StringBuilder();
        pdf.Append("%PDF-1.4\n");
        var offsets = new List<int> { 0 };
        foreach (var obj in objects)
        {
            offsets.Add(Encoding.ASCII.GetByteCount(pdf.ToString()));
            pdf.Append(obj);
        }

        var xrefStart = Encoding.ASCII.GetByteCount(pdf.ToString());
        pdf.Append($"xref\n0 {objects.Count + 1}\n");
        pdf.Append("0000000000 65535 f \n");
        foreach (var offset in offsets.Skip(1))
        {
            pdf.Append($"{offset:D10} 00000 n \n");
        }
        pdf.Append($"trailer\n<< /Size {objects.Count + 1} /Root 1 0 R >>\nstartxref\n{xrefStart}\n%%EOF");

        return Encoding.ASCII.GetBytes(pdf.ToString());
    }
}
