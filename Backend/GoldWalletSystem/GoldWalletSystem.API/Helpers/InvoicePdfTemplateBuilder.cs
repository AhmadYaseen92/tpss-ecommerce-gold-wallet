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

        string actionType = Get("Action", Get("Action Type", "Bought"));
        string quantity = Get("Quantity", "1");
        string unitPrice = Get("Unit Price", Get("Price", "-"));
        string amount = Get("Amount", Get("Grand Total", "-"));
        string currency = Get("Currency", "USD");

        var content = new StringBuilder();

        // Background + card
        content.AppendLine("0.97 0.97 0.97 rg");
        content.AppendLine("0 0 595 842 re f");
        content.AppendLine("1 1 1 rg");
        content.AppendLine("28 24 539 792 re f");
        content.AppendLine("0.86 0.86 0.86 RG");
        content.AppendLine("1 w");
        content.AppendLine("28 24 539 792 re S");

        WriteText(content, 205, 776, 18, "TAX INVOICE", 0.10, 0.10, 0.10);
        WriteText(content, 120, 742, 17, Get("Product Name", Get("Category", "Gold Wallet Item")), 0.12, 0.12, 0.12);
        WriteText(content, 440, 744, 11, $"Type: {actionType}", 0.18, 0.18, 0.18);
        WriteText(content, 120, 720, 10, $"Ref: {Get("External Reference", Get("Invoice Number", "-"))}", 0.30, 0.30, 0.30);

        content.AppendLine("0.90 0.90 0.90 rg");
        content.AppendLine("42 704 68 48 re f");
        content.AppendLine("0.80 0.80 0.80 RG");
        content.AppendLine("42 704 68 48 re S");
        WriteText(content, 62, 726, 10, "IMAGE", 0.45, 0.45, 0.45);

        content.AppendLine("0.86 0.86 0.86 RG");
        content.AppendLine("42 694 m 551 694 l S");

        // Meta
        WriteText(content, 44, 670, 12, "Tax Invoice #:", 0.12, 0.12, 0.12);
        WriteText(content, 188, 670, 12, Get("Invoice Number", Get("Ref", "-")), 0.12, 0.12, 0.12);
        WriteText(content, 44, 646, 12, "Action Type:", 0.12, 0.12, 0.12);
        WriteText(content, 188, 646, 12, actionType, 0.12, 0.12, 0.12);
        WriteText(content, 44, 622, 12, "Issue Date:", 0.12, 0.12, 0.12);
        WriteText(content, 188, 622, 12, Get("Date (UTC)").Split(' ').FirstOrDefault() ?? "-", 0.12, 0.12, 0.12);
        WriteText(content, 44, 598, 12, "Status:", 0.12, 0.12, 0.12);
        WriteText(content, 188, 598, 12, Get("Status", actionType), 0.12, 0.12, 0.12);

        // Seller / Buyer
        content.AppendLine("0.96 0.96 0.96 rg");
        content.AppendLine("44 505 248 80 re f");
        content.AppendLine("302 505 248 80 re f");
        content.AppendLine("0.80 0.80 0.80 RG");
        content.AppendLine("44 505 248 80 re S");
        content.AppendLine("302 505 248 80 re S");
        WriteText(content, 58, 560, 13, "Seller", 0.12, 0.12, 0.12);
        WriteText(content, 58, 538, 12, Get("Seller Name", "Imseeh Precious Metals LLC"), 0.12, 0.12, 0.12);
        WriteText(content, 58, 518, 11, Get("Seller Note", "Linked wallet party"), 0.28, 0.28, 0.28);
        WriteText(content, 316, 560, 13, "Buyer", 0.12, 0.12, 0.12);
        WriteText(content, 316, 538, 12, Get("Buyer Name", "Wallet User"), 0.12, 0.12, 0.12);
        WriteText(content, 316, 518, 11, Get("Buyer Note", "Linked wallet owner"), 0.28, 0.28, 0.28);

        // Items table
        content.AppendLine("0.80 0.80 0.80 RG");
        content.AppendLine("44 410 506 88 re S");
        content.AppendLine("44 464 m 550 464 l S");
        content.AppendLine("84 410 m 84 498 l S");
        content.AppendLine("286 410 m 286 498 l S");
        content.AppendLine("382 410 m 382 498 l S");
        content.AppendLine("458 410 m 458 498 l S");
        WriteText(content, 52, 474, 12, "#", 0.12, 0.12, 0.12);
        WriteText(content, 92, 474, 12, "Item", 0.12, 0.12, 0.12);
        WriteText(content, 294, 474, 12, "Price", 0.12, 0.12, 0.12);
        WriteText(content, 390, 474, 12, "Qty", 0.12, 0.12, 0.12);
        WriteText(content, 466, 474, 12, "Total", 0.12, 0.12, 0.12);
        WriteText(content, 52, 438, 12, "1", 0.12, 0.12, 0.12);
        WriteText(content, 92, 446, 12, Get("Product Name", "Gold Item"), 0.12, 0.12, 0.12);
        WriteText(content, 294, 446, 12, $"{currency} {unitPrice}", 0.12, 0.12, 0.12);
        WriteText(content, 390, 446, 12, quantity, 0.12, 0.12, 0.12);
        WriteText(content, 466, 446, 12, $"{currency} {amount}", 0.12, 0.12, 0.12);

        // Item details section
        content.AppendLine("0.96 0.96 0.96 rg");
        content.AppendLine("44 186 507 212 re f");
        content.AppendLine("0.80 0.80 0.80 RG");
        content.AppendLine("44 186 507 212 re S");
        WriteText(content, 58, 372, 15, "Item Details", 0.12, 0.12, 0.12);
        WriteText(content, 58, 348, 12, $"Product SKU: {Get("SKU", Get("Product SKU", "-"))}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 326, 12, $"Wallet Item Id: {Get("Wallet Item Id", Get("Asset Id", "-"))}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 304, 12, $"Product Name: {Get("Product Name", "Gold Item")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 282, 12, $"Category / Material: {Get("Category", "GOLD")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 260, 12, $"Weight: {Get("Weight", "-")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 238, 12, $"Purity / Karat: {Get("Purity", "N/A")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 216, 12, $"Quantity: {quantity}", 0.12, 0.12, 0.12);

        // Amount summary
        content.AppendLine("0.93 0.93 0.93 rg");
        content.AppendLine("44 66 507 110 re f");
        content.AppendLine("0.80 0.80 0.80 RG");
        content.AppendLine("44 66 507 110 re S");
        WriteText(content, 58, 152, 16, "Amount Summary", 0.12, 0.12, 0.12);
        WriteText(content, 58, 130, 13, $"Sub Total: {currency} {Get("SubTotal", amount)}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 110, 13, $"Fees: {currency} {Get("Fees", "0.00")}", 0.12, 0.12, 0.12);
        var feeDetailLines = Wrap(Get("Fee Details", "-"), 72);
        for (var i = 0; i < Math.Min(2, feeDetailLines.Count); i++)
        {
            WriteText(content, 170, 110 - (i * 12), 10, feeDetailLines[i], 0.28, 0.28, 0.28);
        }
        WriteText(content, 58, 90, 13, $"VAT / Tax: {currency} {Get("Tax", "0.00")}", 0.12, 0.12, 0.12);
        WriteText(content, 300, 90, 13, $"Discount: {currency} {Get("Discount", "0.00")}", 0.12, 0.12, 0.12);
        WriteText(content, 58, 70, 14, $"Grand Total: {currency} {amount}", 0.10, 0.10, 0.10);

        WriteText(content, 52, 40, 10, "This document serves as ownership and transaction proof. Electronically generated document.", 0.35, 0.35, 0.35);

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
