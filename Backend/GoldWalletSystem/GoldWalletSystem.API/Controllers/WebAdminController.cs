using GoldWalletSystem.Application.DTOs.Common;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/web-admin")]
public class WebAdminController : ControllerBase
{
    private static readonly object Sync = new();
    private static readonly List<WebInvestorDto> Investors =
    [
        new() { Id = "i-1", FullName = "Ahmad Saleh", RiskLevel = "medium", WalletBalance = 4850, Status = "active" },
        new() { Id = "i-2", FullName = "Sara Odeh", RiskLevel = "low", WalletBalance = 12200, Status = "review" }
    ];

    private static readonly List<WebRequestDto> Requests =
    [
        new() { Id = "r-1", InvestorId = "i-1", Type = "withdrawal", Amount = 1200, Status = "pending", CreatedAt = DateTime.UtcNow.AddDays(-1) },
        new() { Id = "r-2", InvestorId = "i-2", Type = "sell", Amount = 740, Status = "approved", CreatedAt = DateTime.UtcNow.AddDays(-2) }
    ];

    private static readonly List<WebInvoiceDto> Invoices =
    [
        new() { Id = "inv-1", SellerId = "s-100", InvestorName = "Ahmad Saleh", TotalAmount = 980, IssuedAt = DateTime.UtcNow.AddDays(-1), Status = "sent" }
    ];

    private static readonly List<WebNotificationDto> Notifications =
    [
        new() { Id = "n-1", Title = "KYC Pending", Message = "A new seller registration is pending approval", Severity = "warning", IsRead = false, CreatedAt = DateTime.UtcNow }
    ];

    private static WebFeesDto Fees = new() { DeliveryFee = 12, StorageFee = 4, ServiceChargePercent = 2.5m };

    [HttpGet("summary")]
    public IActionResult GetSummary()
    {
        var summary = new WebSummaryDto
        {
            InvestorsCount = Investors.Count,
            PendingRequestsCount = Requests.Count(x => x.Status == "pending"),
            InvoicesCount = Invoices.Count,
            UnreadNotificationsCount = Notifications.Count(x => !x.IsRead)
        };

        return Ok(ApiResponse<WebSummaryDto>.Ok(summary));
    }

    [HttpGet("investors")]
    public IActionResult GetInvestors() => Ok(ApiResponse<List<WebInvestorDto>>.Ok(Investors));

    [HttpPut("investors/{id}/status")]
    public IActionResult UpdateInvestorStatus(string id, [FromBody] UpdateStatusRequest request)
    {
        lock (Sync)
        {
            var investor = Investors.FirstOrDefault(x => x.Id == id);
            if (investor is null) return NotFound(ApiResponse<object>.Fail("Investor not found", 404));
            investor.Status = request.Status;
        }

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("requests")]
    public IActionResult GetRequests() => Ok(ApiResponse<List<WebRequestDto>>.Ok(Requests));

    [HttpPut("requests/{id}/status")]
    public IActionResult UpdateRequestStatus(string id, [FromBody] UpdateStatusRequest request)
    {
        lock (Sync)
        {
            var item = Requests.FirstOrDefault(x => x.Id == id);
            if (item is null) return NotFound(ApiResponse<object>.Fail("Request not found", 404));
            item.Status = request.Status;
        }

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("invoices")]
    public IActionResult GetInvoices() => Ok(ApiResponse<List<WebInvoiceDto>>.Ok(Invoices));

    [HttpPost("invoices")]
    public IActionResult AddInvoice([FromBody] WebInvoiceDto request)
    {
        lock (Sync)
        {
            request.Id = string.IsNullOrWhiteSpace(request.Id) ? $"inv-{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}" : request.Id;
            request.IssuedAt = request.IssuedAt == default ? DateTime.UtcNow : request.IssuedAt;
            Invoices.Add(request);
        }

        return Ok(ApiResponse<WebInvoiceDto>.Ok(request));
    }

    [HttpPut("invoices/{id}")]
    public IActionResult UpdateInvoice(string id, [FromBody] WebInvoiceDto request)
    {
        lock (Sync)
        {
            var invoice = Invoices.FirstOrDefault(x => x.Id == id);
            if (invoice is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));

            invoice.InvestorName = request.InvestorName;
            invoice.TotalAmount = request.TotalAmount;
            invoice.Status = request.Status;
        }

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpDelete("invoices/{id}")]
    public IActionResult DeleteInvoice(string id)
    {
        lock (Sync)
        {
            var removed = Invoices.RemoveAll(x => x.Id == id);
            if (removed == 0) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));
        }

        return Ok(ApiResponse<string>.Ok("deleted"));
    }

    [HttpGet("fees")]
    public IActionResult GetFees() => Ok(ApiResponse<WebFeesDto>.Ok(Fees));

    [HttpPut("fees")]
    public IActionResult UpdateFees([FromBody] WebFeesDto request)
    {
        lock (Sync)
        {
            Fees = request;
        }

        return Ok(ApiResponse<WebFeesDto>.Ok(Fees));
    }

    [HttpGet("notifications")]
    public IActionResult GetNotifications() => Ok(ApiResponse<List<WebNotificationDto>>.Ok(Notifications));

    [HttpPut("notifications/{id}/read")]
    public IActionResult MarkNotificationAsRead(string id)
    {
        lock (Sync)
        {
            var item = Notifications.FirstOrDefault(x => x.Id == id);
            if (item is null) return NotFound(ApiResponse<object>.Fail("Notification not found", 404));
            item.IsRead = true;
        }

        return Ok(ApiResponse<string>.Ok("updated"));
    }

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
        public string InvestorId { get; set; } = string.Empty;
        public string Type { get; set; } = "withdrawal";
        public decimal Amount { get; set; }
        public string Status { get; set; } = "pending";
        public DateTime CreatedAt { get; set; }
    }

    public class WebInvoiceDto
    {
        public string Id { get; set; } = string.Empty;
        public string SellerId { get; set; } = string.Empty;
        public string InvestorName { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public DateTime IssuedAt { get; set; }
        public string Status { get; set; } = "draft";
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
}
