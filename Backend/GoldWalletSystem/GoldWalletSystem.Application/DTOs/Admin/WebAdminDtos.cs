namespace GoldWalletSystem.Application.DTOs.Admin;

public class UpdateStatusRequest
{
    public string Status { get; set; } = "pending";
}

public class WebSummaryDto
{
    public int InvestorsCount { get; set; }
    public int PendingRequestsCount { get; set; }
    public int InvoicesCount { get; set; }
    public int UnreadNotificationsCount { get; set; }
}

public class WebSellerDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string BusinessName { get; set; } = string.Empty;
    public string KycStatus { get; set; } = "pending";
    public DateTime SubmittedAt { get; set; }
    public decimal? GoldPrice { get; set; }
    public decimal? SilverPrice { get; set; }
    public decimal? DiamondPrice { get; set; }
}

public class UpdateSellerKycRequest
{
    public string Status { get; set; } = "pending";
    public string? ReviewNotes { get; set; }
}

public class WebInvestorDto
{
    public string Id { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string RiskLevel { get; set; } = "medium";
    public decimal WalletBalance { get; set; }
    public string Status { get; set; } = "active";
}

public class WebRequestDto
{
    public string Id { get; set; } = string.Empty;
    public string SellerId { get; set; } = string.Empty;
    public string SellerName { get; set; } = string.Empty;
    public string InvestorId { get; set; } = string.Empty;
    public string InvestorName { get; set; } = string.Empty;
    public string Type { get; set; } = "withdrawal";
    public string ProductName { get; set; } = string.Empty;
    public string ProductImageUrl { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal Weight { get; set; }
    public string Unit { get; set; } = "gram";
    public decimal Purity { get; set; }
    public decimal Amount { get; set; }
    public string Status { get; set; } = "pending";
    public string Currency { get; set; } = "USD";
    public string Notes { get; set; } = string.Empty;
    public DateTime? UpdatedAt { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class WebInvoiceDto
{
    public string Id { get; set; } = string.Empty;
    public string SellerId { get; set; } = string.Empty;
    public string InvestorName { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public DateTime IssuedAt { get; set; }
    public string Status { get; set; } = "Draft";
    public string PaymentStatus { get; set; } = "Pending";
    public string? PdfUrl { get; set; }
}

public class WebFeesDto
{
    public decimal DeliveryFee { get; set; }
    public decimal StorageFee { get; set; }
    public decimal ServiceChargePercent { get; set; }
}

public class WebNotificationDto
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Severity { get; set; } = "info";
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class WebDashboardDto
{
    public List<WebDashboardCardDto> Cards { get; set; } = [];
    public List<WebDashboardSegmentDto> StatusSegments { get; set; } = [];
    public List<WebDashboardSegmentDto> CategorySegments { get; set; } = [];
    public List<WebDashboardPointDto> CategoryTransactionSeries { get; set; } = [];
    public List<WebDashboardPointDto> CategoryCartSeries { get; set; } = [];
    public List<WebRecentTransactionDto> RecentTransactions { get; set; } = [];
}

public class WebDashboardCardDto
{
    public string Title { get; set; } = string.Empty;
    public string Value { get; set; } = "0";
    public string Trend { get; set; } = string.Empty;
}

public class WebDashboardSegmentDto
{
    public string Key { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public int Value { get; set; }
    public int Percent { get; set; }
}

public class WebRecentTransactionDto
{
    public string Id { get; set; } = string.Empty;
    public string InvestorName { get; set; } = string.Empty;
    public string ProductName { get; set; } = "N/A";
    public string Type { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class WebDashboardPointDto
{
    public string Label { get; set; } = string.Empty;
    public int Value { get; set; }
}

public class AdminWorkspaceDto
{
    public int SellersCount { get; set; }
    public int InvestorsCount { get; set; }
    public int ProductsCount { get; set; }
    public int RequestsCount { get; set; }
    public int SystemSettingsCount { get; set; }
}

public class SellerWorkspaceDto
{
    public int SellerId { get; set; }
    public int ProductsCount { get; set; }
    public int InvestorsCount { get; set; }
    public int RequestsCount { get; set; }
    public int ActiveOffersCount { get; set; }
}
