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
    public string CompanyCode { get; set; } = string.Empty;
    public string LoginEmail { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public string KycStatus { get; set; } = "pending";
    public DateTime SubmittedAt { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public decimal? GoldPrice { get; set; }
    public decimal? SilverPrice { get; set; }
    public decimal? DiamondPrice { get; set; }
}

public class WebSellerDetailsDto
{
    public string Id { get; set; } = string.Empty;
    public string CompanyName { get; set; } = string.Empty;
    public string CompanyCode { get; set; } = string.Empty;
    public string CommercialRegistrationNumber { get; set; } = string.Empty;
    public string VatNumber { get; set; } = string.Empty;
    public string BusinessActivity { get; set; } = string.Empty;
    public DateOnly? EstablishedDate { get; set; }
    public string CompanyPhone { get; set; } = string.Empty;
    public string CompanyEmail { get; set; } = string.Empty;
    public string? Website { get; set; }
    public string? Description { get; set; }
    public string LoginEmail { get; set; } = string.Empty;
    public string LoginPhone { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public string KycStatus { get; set; } = "pending";
    public string? ReviewNotes { get; set; }
    public DateTime SubmittedAt { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public decimal? GoldPrice { get; set; }
    public decimal? SilverPrice { get; set; }
    public decimal? DiamondPrice { get; set; }
    public WebSellerAddressDto? Address { get; set; }
    public List<WebSellerManagerDto> Managers { get; set; } = [];
    public List<WebSellerBranchDto> Branches { get; set; } = [];
    public List<WebSellerBankAccountDto> BankAccounts { get; set; } = [];
    public List<WebSellerDocumentDto> Documents { get; set; } = [];
}

public class UpdateWebUserCredentialsRequest
{
    public string? LoginEmail { get; set; }
    public string? LoginPhone { get; set; }
    public string? NewPassword { get; set; }
}

public class WebUserCredentialsDto
{
    public string UserId { get; set; } = string.Empty;
    public string LoginEmail { get; set; } = string.Empty;
    public string LoginPhone { get; set; } = string.Empty;
    public DateTime? UpdatedAt { get; set; }
}

public class WebSellerAddressDto
{
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Street { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
}

public class WebSellerManagerDto
{
    public string FullName { get; set; } = string.Empty;
    public string PositionTitle { get; set; } = string.Empty;
    public string Nationality { get; set; } = string.Empty;
    public string MobileNumber { get; set; } = string.Empty;
    public string EmailAddress { get; set; } = string.Empty;
    public string IdType { get; set; } = string.Empty;
    public string IdNumber { get; set; } = string.Empty;
    public DateOnly? IdExpiryDate { get; set; }
    public bool IsPrimary { get; set; }
}

public class WebSellerBranchDto
{
    public string BranchName { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string FullAddress { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool IsMainBranch { get; set; }
}

public class WebSellerBankAccountDto
{
    public string BankName { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string Iban { get; set; } = string.Empty;
    public string SwiftCode { get; set; } = string.Empty;
    public string BankCountry { get; set; } = string.Empty;
    public string BankCity { get; set; } = string.Empty;
    public string BranchName { get; set; } = string.Empty;
    public string BranchAddress { get; set; } = string.Empty;
    public string Currency { get; set; } = string.Empty;
    public bool IsMainAccount { get; set; }
}

public class WebSellerDocumentDto
{
    public int Id { get; set; }
    public string DocumentType { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public bool IsRequired { get; set; }
    public DateTime UploadedAtUtc { get; set; }
    public string? RelatedEntityType { get; set; }
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
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string RiskLevel { get; set; } = "medium";
    public decimal WalletBalance { get; set; }
    public int TotalTransactions { get; set; }
    public DateTime CreatedAt { get; set; }
    public string Status { get; set; } = "active";
}

public class WebInvestorProfileDto
{
    public string Id { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public decimal WalletBalance { get; set; }
    public int TotalTransactions { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public string Status { get; set; } = "active";
    public DateOnly? DateOfBirth { get; set; }
    public string Nationality { get; set; } = string.Empty;
    public string DocumentType { get; set; } = string.Empty;
    public string IdNumber { get; set; } = string.Empty;
    public string ProfilePhotoUrl { get; set; } = string.Empty;
    public string PreferredLanguage { get; set; } = "en";
    public string PreferredTheme { get; set; } = "light";
    public List<WebLinkedBankAccountDto> BankAccounts { get; set; } = new();
    public List<WebPaymentMethodDto> PaymentMethods { get; set; } = new();
}

public class WebLinkedBankAccountDto
{
    public string BankName { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string IbanMasked { get; set; } = string.Empty;
    public string SwiftCode { get; set; } = string.Empty;
    public string BranchName { get; set; } = string.Empty;
    public string BranchAddress { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Currency { get; set; } = string.Empty;
    public bool IsVerified { get; set; }
    public bool IsDefault { get; set; }
}

public class WebPaymentMethodDto
{
    public string Type { get; set; } = string.Empty;
    public string MaskedNumber { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
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

public class WebFeeBreakdownReportRowDto
{
    public string SellerId { get; set; } = string.Empty;
    public string SellerName { get; set; } = string.Empty;
    public string FeeCode { get; set; } = string.Empty;
    public string FeeName { get; set; } = string.Empty;
    public string CalculationMode { get; set; } = string.Empty;
    public decimal? AppliedRate { get; set; }
    public int TransactionsCount { get; set; }
    public decimal CollectedAmount { get; set; }
    public string Currency { get; set; } = "USD";
    public string TransactionTypes { get; set; } = string.Empty;
    public DateTime? LatestTransactionAt { get; set; }
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
    public string SellerName { get; set; } = string.Empty;
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
