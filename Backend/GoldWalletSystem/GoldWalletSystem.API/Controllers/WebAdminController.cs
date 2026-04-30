using System.Text.Json;
using GoldWalletSystem.API.Helpers;
using GoldWalletSystem.API.Services;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Admin;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/web-admin")]
public class WebAdminController(
    AppDbContext dbContext,
    IWebAdminDashboardService dashboardService,
    INotificationService notificationService,
    IPasswordHasher passwordHasher,
    IMarketplaceRealtimeNotifier realtimeNotifier,
    IWebHostEnvironment environment,
    IMobileAppConfigurationService mobileAppConfigurationService) : ControllerBase
{

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(CancellationToken cancellationToken)
    {
        var sellerScope = ResolveSellerScope();
        var investorsCount = await dbContext.Users.CountAsync(x => x.Role == SystemRoles.Investor, cancellationToken);

        var pendingRequestsQuery = dbContext.TransactionHistories.Where(x => x.Status == "pending");
        if (sellerScope.HasValue)
        {
            pendingRequestsQuery = pendingRequestsQuery.Where(x => x.SellerId == sellerScope.Value);
        }
        var pendingRequestsCount = await pendingRequestsQuery.CountAsync(cancellationToken);

        var invoicesQuery = dbContext.Invoices.AsQueryable();
        if (sellerScope.HasValue)
        {
            invoicesQuery = invoicesQuery.Where(x => dbContext.Sellers
                .Any(s => s.UserId == x.SellerUserId && s.Id == sellerScope.Value));
        }
        var invoicesCount = await invoicesQuery.CountAsync(cancellationToken);
        var unreadNotificationsCount = await dbContext.AppNotifications.CountAsync(x => !x.IsRead, cancellationToken);

        var summary = new WebSummaryDto
        {
            InvestorsCount = investorsCount,
            PendingRequestsCount = pendingRequestsCount,
            InvoicesCount = invoicesCount,
            UnreadNotificationsCount = unreadNotificationsCount
        };

        return Ok(ApiResponse<WebSummaryDto>.Ok(summary));
    }

    [HttpGet("sellers")]
    public async Task<IActionResult> GetSellers(CancellationToken cancellationToken)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : 0;

        var query = dbContext.Sellers.AsNoTracking();
        if (!User.IsInRole(SystemRoles.Admin))
        {
            query = query.Where(x => x.Id == currentSellerId);
        }

        var sellers = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new WebSellerDto
            {
                Id = FormatSellerId(x.Id),
                Name = x.CompanyName,
                Email = x.CompanyEmail ?? dbContext.Users.Where(u => u.Id == x.UserId).Select(u => u.Email).FirstOrDefault() ?? string.Empty,
                BusinessName = x.CompanyName,
                CompanyCode = x.CompanyCode,
                ContactPhone = x.CompanyPhone,
                LoginEmail = dbContext.Users.Where(u => u.Id == x.UserId).Select(u => u.Email).FirstOrDefault() ?? string.Empty,
                IsActive = x.IsActive,
                ReviewedAt = x.ReviewedAtUtc,
                KycStatus = x.KycStatus.ToString().ToLowerInvariant(),
                SubmittedAt = x.CreatedAtUtc,
                GoldPrice = x.GoldPrice,
                SilverPrice = x.SilverPrice,
                DiamondPrice = x.DiamondPrice,
                MarketType = x.MarketType
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebSellerDto>>.Ok(sellers));
    }

    [HttpGet("sellers/{id}")]
    public async Task<IActionResult> GetSellerDetails(string id, CancellationToken cancellationToken)
    {
        var sellerId = TryParsePrefixedId(id, "S");
        if (sellerId is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : 0;
        if (!User.IsInRole(SystemRoles.Admin) && currentSellerId != sellerId.Value)
        {
            return Forbid();
        }

        var seller = await dbContext.Sellers
            .AsNoTracking()
            .Include(x => x.Address)
            .Include(x => x.Managers)
            .Include(x => x.Branches)
            .Include(x => x.BankAccounts)
            .Include(x => x.Documents)
            .FirstOrDefaultAsync(x => x.Id == sellerId.Value, cancellationToken);

        if (seller is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        var loginEmail = await dbContext.Users
            .Where(x => x.Id == seller.UserId)
            .Select(x => x.Email)
            .FirstOrDefaultAsync(cancellationToken) ?? string.Empty;

        var details = new WebSellerDetailsDto
        {
            Id = FormatSellerId(seller.Id),
            CompanyName = seller.CompanyName,
            CompanyCode = seller.CompanyCode,
            CommercialRegistrationNumber = seller.CommercialRegistrationNumber,
            VatNumber = seller.VatNumber,
            BusinessActivity = seller.BusinessActivity,
            EstablishedDate = seller.EstablishedDate,
            CompanyPhone = seller.CompanyPhone,
            CompanyEmail = seller.CompanyEmail,
            Website = seller.Website,
            Description = seller.Description,
            LoginEmail = loginEmail,
            LoginPhone = await dbContext.Users.Where(x => x.Id == seller.UserId).Select(x => x.PhoneNumber).FirstOrDefaultAsync(cancellationToken) ?? string.Empty,
            IsActive = seller.IsActive,
            KycStatus = seller.KycStatus.ToString().ToLowerInvariant(),
            ReviewNotes = seller.ReviewNotes,
            SubmittedAt = seller.CreatedAtUtc,
            ReviewedAt = seller.ReviewedAtUtc,
            GoldPrice = seller.GoldPrice,
            SilverPrice = seller.SilverPrice,
            DiamondPrice = seller.DiamondPrice,
            MarketType = seller.MarketType,
            Address = seller.Address is null
                ? null
                : new WebSellerAddressDto
                {
                    Country = seller.Address.Country,
                    City = seller.Address.City,
                    Street = seller.Address.Street,
                    BuildingNumber = seller.Address.BuildingNumber,
                    PostalCode = seller.Address.PostalCode
                },
            Managers = seller.Managers
                .OrderByDescending(x => x.IsPrimary)
                .ThenBy(x => x.Id)
                .Select(x => new WebSellerManagerDto
                {
                    FullName = x.FullName,
                    PositionTitle = x.PositionTitle,
                    Nationality = x.Nationality,
                    MobileNumber = x.MobileNumber,
                    EmailAddress = x.EmailAddress,
                    IdType = x.IdType,
                    IdNumber = x.IdNumber,
                    IdExpiryDate = x.IdExpiryDate,
                    IsPrimary = x.IsPrimary
                })
                .ToList(),
            Branches = seller.Branches
                .OrderByDescending(x => x.IsMainBranch)
                .ThenBy(x => x.Id)
                .Select(x => new WebSellerBranchDto
                {
                    BranchName = x.BranchName,
                    Country = x.Country,
                    City = x.City,
                    FullAddress = x.FullAddress,
                    BuildingNumber = x.BuildingNumber,
                    PostalCode = x.PostalCode,
                    PhoneNumber = x.PhoneNumber,
                    Email = x.Email,
                    IsMainBranch = x.IsMainBranch
                })
                .ToList(),
            BankAccounts = seller.BankAccounts
                .OrderByDescending(x => x.IsMainAccount)
                .ThenBy(x => x.Id)
                .Select(x => new WebSellerBankAccountDto
                {
                    BankName = x.BankName,
                    AccountHolderName = x.AccountHolderName,
                    AccountNumber = x.AccountNumber,
                    Iban = x.IBAN,
                    SwiftCode = x.SwiftCode,
                    BankCountry = x.BankCountry,
                    BankCity = x.BankCity,
                    BranchName = x.BranchName,
                    BranchAddress = x.BranchAddress,
                    Currency = x.Currency,
                    IsMainAccount = x.IsMainAccount
                })
                .ToList(),
            Documents = seller.Documents
                .OrderByDescending(x => x.UploadedAtUtc)
                .ThenBy(x => x.Id)
                .Select(x => new WebSellerDocumentDto
                {
                    Id = x.Id,
                    DocumentType = x.DocumentType,
                    FileName = x.FileName,
                    FilePath = x.FilePath,
                    ContentType = x.ContentType,
                    IsRequired = x.IsRequired,
                    UploadedAtUtc = x.UploadedAtUtc,
                    RelatedEntityType = x.RelatedEntityType
                })
                .ToList()
        };

        return Ok(ApiResponse<WebSellerDetailsDto>.Ok(details));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpGet("market-types")]
    public async Task<IActionResult> GetMarketTypeSettings(CancellationToken cancellationToken)
    {
        var defaults = BuildDefaultMarketSettings();
        var counts = await dbContext.Sellers.AsNoTracking()
            .GroupBy(x => x.MarketType)
            .Select(x => new { MarketType = x.Key, Count = x.Count() })
            .ToListAsync(cancellationToken);

        foreach (var row in counts)
        {
            var key = NormalizeMarketType(row.MarketType);
            var item = defaults.FirstOrDefault(x => string.Equals(x.MarketType, key, StringComparison.OrdinalIgnoreCase));
            if (item is not null) item.SellersCount = row.Count;
        }

        return Ok(ApiResponse<List<MarketTypeSettingsDto>>.Ok(defaults));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpGet("market-types/{marketType}/sellers")]
    public async Task<IActionResult> GetSellersByMarketType(string marketType, CancellationToken cancellationToken)
    {
        var normalized = NormalizeMarketTypeOrThrow(marketType);
        var sellers = await dbContext.Sellers
            .AsNoTracking()
            .Where(x => x.MarketType == normalized)
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new WebSellerDto
            {
                Id = FormatSellerId(x.Id),
                Name = x.CompanyName,
                Email = x.CompanyEmail ?? string.Empty,
                BusinessName = x.CompanyName,
                CompanyCode = x.CompanyCode,
                ContactPhone = x.CompanyPhone,
                LoginEmail = dbContext.Users.Where(u => u.Id == x.UserId).Select(u => u.Email).FirstOrDefault() ?? string.Empty,
                IsActive = x.IsActive,
                ReviewedAt = x.ReviewedAtUtc,
                KycStatus = x.KycStatus.ToString().ToLowerInvariant(),
                SubmittedAt = x.CreatedAtUtc,
                GoldPrice = x.GoldPrice,
                SilverPrice = x.SilverPrice,
                DiamondPrice = x.DiamondPrice,
                MarketType = x.MarketType
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebSellerDto>>.Ok(sellers));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpPut("sellers/{id}/login-credentials")]
    public async Task<IActionResult> UpdateSellerLoginCredentials(string id, [FromBody] UpdateWebUserCredentialsRequest request, CancellationToken cancellationToken)
    {
        var sellerId = TryParsePrefixedId(id, "S");
        if (sellerId is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        var user = await dbContext.Sellers
            .Where(x => x.Id == sellerId.Value)
            .Select(x => x.User)
            .FirstOrDefaultAsync(cancellationToken);

        if (user is null) return NotFound(ApiResponse<object>.Fail("Seller user not found", 404));

        var dto = await UpdateUserCredentialsAsync(FormatSellerId(sellerId.Value), user, request, cancellationToken);
        return Ok(ApiResponse<WebUserCredentialsDto>.Ok(dto));
    }

    [HttpGet("sellers/{id}/documents/{documentId:int}/view")]
    public async Task<IActionResult> ViewSellerDocument(string id, int documentId, CancellationToken cancellationToken)
    {
        var sellerId = TryParsePrefixedId(id, "S");
        if (sellerId is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : 0;
        if (!User.IsInRole(SystemRoles.Admin) && currentSellerId != sellerId.Value)
        {
            return Forbid();
        }

        var document = await dbContext.SellerDocuments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == documentId && x.SellerId == sellerId.Value, cancellationToken);

        if (document is null) return NotFound(ApiResponse<object>.Fail("Document not found", 404));

        if (Uri.TryCreate(document.FilePath, UriKind.Absolute, out var absoluteUri) &&
            (absoluteUri.Scheme == Uri.UriSchemeHttp || absoluteUri.Scheme == Uri.UriSchemeHttps))
        {
            return Redirect(document.FilePath);
        }

        var candidates = new List<string>();
        if (!string.IsNullOrWhiteSpace(document.FilePath))
        {
            var normalized = document.FilePath.Replace('\\', '/');
            var webRelative = normalized.TrimStart('/');
            var webRelativeWithoutUploads = webRelative.StartsWith("uploads/", StringComparison.OrdinalIgnoreCase)
                ? webRelative["uploads/".Length..]
                : webRelative;

            if (Path.IsPathRooted(document.FilePath))
            {
                candidates.Add(document.FilePath);

                if (!string.IsNullOrWhiteSpace(environment.WebRootPath))
                {
                    candidates.Add(Path.Combine(environment.WebRootPath, webRelative));
                    candidates.Add(Path.Combine(environment.WebRootPath, webRelativeWithoutUploads));
                }
                candidates.Add(Path.Combine(environment.ContentRootPath, webRelative));
                candidates.Add(Path.Combine(environment.ContentRootPath, webRelativeWithoutUploads));
            }
            else
            {
                candidates.Add(document.FilePath);
                candidates.Add(Path.Combine(environment.ContentRootPath, document.FilePath));
                candidates.Add(Path.Combine(environment.ContentRootPath, webRelativeWithoutUploads));
                if (!string.IsNullOrWhiteSpace(environment.WebRootPath))
                {
                    candidates.Add(Path.Combine(environment.WebRootPath, document.FilePath));
                    candidates.Add(Path.Combine(environment.WebRootPath, webRelativeWithoutUploads));
                }
            }
        }

        var physicalPath = candidates.FirstOrDefault(System.IO.File.Exists);
        if (physicalPath is null && !string.IsNullOrWhiteSpace(document.FilePath))
        {
            var normalized = document.FilePath.Replace('\\', '/');
            var webRelative = normalized.TrimStart('/');
            var webRelativeWithoutUploads = webRelative.StartsWith("uploads/", StringComparison.OrdinalIgnoreCase)
                ? webRelative["uploads/".Length..]
                : webRelative;
            var fileName = Path.GetFileName(webRelativeWithoutUploads);
            var relativeDir = Path.GetDirectoryName(webRelativeWithoutUploads)?.Replace('\\', '/') ?? string.Empty;

            var searchDirectories = new List<string>();
            if (!string.IsNullOrWhiteSpace(environment.WebRootPath))
            {
                searchDirectories.Add(Path.Combine(environment.WebRootPath, relativeDir));
            }
            searchDirectories.Add(Path.Combine(environment.ContentRootPath, relativeDir));

            foreach (var directory in searchDirectories.Distinct())
            {
                if (string.IsNullOrWhiteSpace(directory) || !Directory.Exists(directory)) continue;

                var matches = Directory.EnumerateFiles(directory, $"{fileName}*", SearchOption.TopDirectoryOnly).ToList();
                if (matches.Count == 0) continue;

                physicalPath = matches.FirstOrDefault(System.IO.File.Exists);
                if (physicalPath is not null) break;
            }
        }

        if (physicalPath is null)
        {
            return NotFound(ApiResponse<object>.Fail("Document file is not available on server.", 404));
        }

        var contentType = string.IsNullOrWhiteSpace(document.ContentType) ? "application/octet-stream" : document.ContentType;
        return PhysicalFile(physicalPath, contentType, enableRangeProcessing: true);
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpPut("sellers/{id}/kyc-status")]
    public async Task<IActionResult> UpdateSellerKycStatus(string id, [FromBody] UpdateSellerKycRequest request, CancellationToken cancellationToken)
    {
        var sellerId = TryParsePrefixedId(id, "S");
        if (sellerId is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        var seller = await dbContext.Sellers.FirstOrDefaultAsync(x => x.Id == sellerId, cancellationToken);
        if (seller is null) return NotFound(ApiResponse<object>.Fail("Seller not found", 404));

        if (!Enum.TryParse<KycStatus>(request.Status, true, out var status))
            return BadRequest(ApiResponse<object>.Fail("Invalid KYC status", 400));

        seller.KycStatus = status;
        seller.ReviewNotes = request.ReviewNotes;
        seller.ReviewedAtUtc = DateTime.UtcNow;
        seller.UpdatedAtUtc = DateTime.UtcNow;
        seller.IsActive = status == KycStatus.Approved;

        var sellerUsers = await dbContext.Users
            .Where(x => x.Id == seller.UserId && x.Role == SystemRoles.Seller)
            .ToListAsync(cancellationToken);

        foreach (var sellerUser in sellerUsers)
        {
            sellerUser.IsActive = status == KycStatus.Approved;
            sellerUser.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        var sellerAccount = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == seller.UserId, cancellationToken);
        if (sellerAccount is not null)
        {
            await SendKycDecisionMessagesAsync(seller, sellerAccount, request.ReviewNotes, cancellationToken);
        }

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    private async Task SendKycDecisionMessagesAsync(Domain.Entities.Seller seller, Domain.Entities.User sellerUser, string? reviewNotes, CancellationToken cancellationToken)
    {
        var isApproved = seller.KycStatus == KycStatus.Approved;
        var emailTemplateKey = isApproved
            ? MobileAppConfigurationKeys.SellerKycApproveEmailTemplate
            : MobileAppConfigurationKeys.SellerKycRejectEmailTemplate;
        var whatsappTemplateKey = isApproved
            ? MobileAppConfigurationKeys.SellerKycApproveWhatsappTemplate
            : MobileAppConfigurationKeys.SellerKycRejectWhatsappTemplate;

        var emailTemplate = await mobileAppConfigurationService.GetStringAsync(emailTemplateKey, cancellationToken)
            ?? (isApproved
                ? "Hello {SellerName}, your KYC request was approved. Thank you for joining Gold Wallet."
                : "Hello {SellerName}, your KYC request was rejected. Note: {ReviewNote}");
        var whatsappTemplate = await mobileAppConfigurationService.GetStringAsync(whatsappTemplateKey, cancellationToken)
            ?? (isApproved
                ? "KYC approved for {SellerName}. You can now access seller services."
                : "KYC rejected for {SellerName}. Note: {ReviewNote}");

        var emailSenderName = await mobileAppConfigurationService.GetStringAsync(MobileAppConfigurationKeys.EmailSenderName, cancellationToken) ?? "Gold Wallet";
        var emailSenderAddress = await mobileAppConfigurationService.GetStringAsync(MobileAppConfigurationKeys.EmailSenderAddress, cancellationToken) ?? "no-reply@goldwallet.local";
        var whatsappSenderNumber = await mobileAppConfigurationService.GetStringAsync(MobileAppConfigurationKeys.WhatsappSenderNumber, cancellationToken) ?? "N/A";
        var whatsappSenderBusinessName = await mobileAppConfigurationService.GetStringAsync(MobileAppConfigurationKeys.WhatsappSenderBusinessName, cancellationToken) ?? "Gold Wallet";

        var placeholders = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["SellerName"] = seller.CompanyName,
            ["CompanyName"] = seller.CompanyName,
            ["SellerCode"] = seller.CompanyCode,
            ["ReviewNote"] = string.IsNullOrWhiteSpace(reviewNotes) ? "-" : reviewNotes.Trim(),
            ["Status"] = seller.KycStatus.ToString()
        };

        var emailBody = ApplyTemplate(emailTemplate, placeholders);
        var whatsappBody = ApplyTemplate(whatsappTemplate, placeholders);

        dbContext.AppNotifications.Add(new Domain.Entities.AppNotification
        {
            UserId = sellerUser.Id,
            Title = isApproved ? "KYC Approved" : "KYC Rejected",
            Body = $"Email via {emailSenderName} <{emailSenderAddress}>: {emailBody}\nWhatsApp via {whatsappSenderBusinessName} ({whatsappSenderNumber}): {whatsappBody}",
            Type = NotificationType.RequestUpdated
        });

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private static string ApplyTemplate(string template, IReadOnlyDictionary<string, string> tokens)
    {
        var result = template;
        foreach (var token in tokens)
        {
            result = result.Replace($"{{{token.Key}}}", token.Value, StringComparison.OrdinalIgnoreCase);
        }

        return result;
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpGet("investors")]
    public async Task<IActionResult> GetInvestors(CancellationToken cancellationToken)
    {
        var investors = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Role == SystemRoles.Investor)
            .Select(x => new WebInvestorDto
            {
                Id = FormatInvestorId(x.Id),
                FullName = x.FullName,
                Email = x.Email,
                PhoneNumber = x.PhoneNumber ?? string.Empty,
                RiskLevel = "medium",
                WalletBalance = dbContext.Wallets.Where(w => w.UserId == x.Id).Select(w => w.CashBalance).FirstOrDefault(),
                TotalTransactions = dbContext.TransactionHistories.Count(th => th.UserId == x.Id),
                CreatedAt = x.CreatedAtUtc,
                Status = x.IsActive ? "active" : "blocked"
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebInvestorDto>>.Ok(investors));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpGet("investors/{id}")]
    public async Task<IActionResult> GetInvestorDetails(string id, CancellationToken cancellationToken)
    {
        var userId = TryParsePrefixedId(id, "I");
        if (!userId.HasValue)
            return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        var investor = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == userId.Value && x.Role == SystemRoles.Investor)
            .Select(x => new
            {
                User = x,
                WalletBalance = dbContext.Wallets.Where(w => w.UserId == x.Id).Select(w => w.CashBalance).FirstOrDefault(),
                TotalTransactions = dbContext.TransactionHistories.Count(th => th.UserId == x.Id)
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (investor is null) return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        var profile = await dbContext.UserProfiles
            .AsNoTracking()
            .Include(x => x.LinkedBankAccounts)
            .Include(x => x.PaymentMethods)
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

        var details = new WebInvestorProfileDto
        {
            Id = FormatInvestorId(investor.User.Id),
            FullName = investor.User.FullName,
            Email = investor.User.Email,
            PhoneNumber = investor.User.PhoneNumber ?? string.Empty,
            WalletBalance = investor.WalletBalance,
            TotalTransactions = investor.TotalTransactions,
            CreatedAt = investor.User.CreatedAtUtc,
            UpdatedAt = investor.User.UpdatedAtUtc,
            Status = investor.User.IsActive ? "active" : "blocked",
            DateOfBirth = profile?.DateOfBirth,
            Nationality = profile?.Nationality ?? string.Empty,
            DocumentType = profile?.DocumentType ?? string.Empty,
            IdNumber = profile?.IdNumber ?? string.Empty,
            ProfilePhotoUrl = profile?.ProfilePhotoUrl ?? string.Empty,
            PreferredLanguage = profile?.PreferredLanguage ?? "en",
            PreferredTheme = profile?.PreferredTheme ?? "light",
            BankAccounts = profile?.LinkedBankAccounts.Select(b => new WebLinkedBankAccountDto
            {
                BankName = b.BankName,
                AccountHolderName = b.AccountHolderName,
                AccountNumber = b.AccountNumber,
                IbanMasked = b.IbanMasked,
                SwiftCode = b.SwiftCode,
                BranchName = b.BranchName,
                BranchAddress = b.BranchAddress,
                Country = b.Country,
                City = b.City,
                Currency = b.Currency,
                IsVerified = b.IsVerified,
                IsDefault = b.IsDefault
            }).ToList() ?? new List<WebLinkedBankAccountDto>(),
            PaymentMethods = profile?.PaymentMethods.Select(pm => new WebPaymentMethodDto
            {
                Type = pm.Type,
                MaskedNumber = pm.MaskedNumber,
                IsDefault = pm.IsDefault
            }).ToList() ?? new List<WebPaymentMethodDto>()
        };

        return Ok(ApiResponse<WebInvestorProfileDto>.Ok(details));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpPut("investors/{id}/login-credentials")]
    public async Task<IActionResult> UpdateInvestorLoginCredentials(string id, [FromBody] UpdateWebUserCredentialsRequest request, CancellationToken cancellationToken)
    {
        var userId = TryParsePrefixedId(id, "I");
        if (userId is null) return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        var user = await dbContext.Users.FirstOrDefaultAsync(
            x => x.Id == userId.Value && x.Role == SystemRoles.Investor,
            cancellationToken);

        if (user is null) return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        var dto = await UpdateUserCredentialsAsync(FormatInvestorId(user.Id), user, request, cancellationToken);
        return Ok(ApiResponse<WebUserCredentialsDto>.Ok(dto));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpPut("investors/{id}/status")]
    public async Task<IActionResult> UpdateInvestorStatus(string id, [FromBody] UpdateStatusRequest request, CancellationToken cancellationToken)
    {
        var userId = TryParsePrefixedId(id, "I");
        if (!userId.HasValue)
            return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        var investor = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId.Value && x.Role == SystemRoles.Investor, cancellationToken);
        if (investor is null) return NotFound(ApiResponse<object>.Fail("Investor not found", 404));

        investor.IsActive = !request.Status.Equals("blocked", StringComparison.OrdinalIgnoreCase);
        investor.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"investor-status:{userId}:{request.Status}", cancellationToken);

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpGet("requests")]
    public async Task<IActionResult> GetRequests(CancellationToken cancellationToken)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : 0;

        var query = dbContext.TransactionHistories.AsNoTracking().AsQueryable();
        if (!User.IsInRole(SystemRoles.Admin))
        {
            query = query.Where(x => x.SellerId == currentSellerId);
        }

        var requests = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Take(100)
            .Join(
                dbContext.Users.AsNoTracking(),
                history => history.UserId,
                user => user.Id,
                (history, user) => new { history, user })
            .GroupJoin(
                dbContext.Sellers.AsNoTracking(),
                x => x.history.SellerId,
                seller => (int?)seller.Id,
                (x, sellers) => new { x.history, x.user, seller = sellers.FirstOrDefault() })
            .Select(x => new WebRequestDto
                {
                    Id = $"r-{x.history.Id}",
                    SellerId = x.history.SellerId.HasValue ? FormatSellerId(x.history.SellerId.Value) : string.Empty,
                    SellerName = x.seller != null ? x.seller.CompanyName : string.Empty,
                    InvestorId = FormatInvestorId(x.history.UserId),
                    InvestorName = x.user.FullName,
                    Type = x.history.TransactionType,
                    ProductName = x.history.Category,
                    Category = x.history.Category,
                    Quantity = x.history.Quantity,
                    UnitPrice = x.history.UnitPrice,
                    Weight = x.history.Weight,
                    Unit = x.history.Unit,
                    Purity = x.history.Purity,
                    Amount = x.history.Amount,
                    Status = MapRequestStatusForView(x.history.TransactionType, x.history.Status),
                    Currency = x.history.Currency,
                    Notes = x.history.Notes,
                    CreatedAt = x.history.CreatedAtUtc,
                    UpdatedAt = x.history.UpdatedAtUtc
                })
            .ToListAsync(cancellationToken);

        await PopulateRequestProductNamesAsync(requests, cancellationToken);
        return Ok(ApiResponse<List<WebRequestDto>>.Ok(requests));
    }

    [HttpPut("requests/{id}/status")]
    public async Task<IActionResult> UpdateRequestStatus(string id, [FromBody] UpdateStatusRequest request, CancellationToken cancellationToken)
    {
        if (!int.TryParse(id.Replace("r-", string.Empty), out var requestId))
            return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        var item = await dbContext.TransactionHistories.FirstOrDefaultAsync(x => x.Id == requestId, cancellationToken);
        if (item is null) return NotFound(ApiResponse<object>.Fail("Request not found", 404));
        if (!CanAccessSellerData(item.SellerId)) return Forbid();

        var nextStatus = request.Status.Trim().ToLowerInvariant();
        if (nextStatus == "canceled")
            nextStatus = "cancelled";

        if (nextStatus != "approved" && nextStatus != "rejected" && nextStatus != "delivered" && nextStatus != "cancelled")
            return BadRequest(ApiResponse<object>.Fail("Invalid status", 400));

        var action = item.TransactionType.Trim().ToLowerInvariant();
        var canTransitionFromPending = string.Equals(item.Status, "pending", StringComparison.OrdinalIgnoreCase)
                                       && nextStatus is "approved" or "rejected" or "cancelled";
        var canTransitionPickupToFinal =
            action == "pickup"
            && string.Equals(item.Status, "pending_delivered", StringComparison.OrdinalIgnoreCase)
            && nextStatus is "delivered" or "cancelled";

        if (!canTransitionFromPending && !canTransitionPickupToFinal)
            return BadRequest(ApiResponse<object>.Fail("Invalid status transition for this request.", 400));

        var previousStatus = item.Status;
        item.Status = action == "pickup" && nextStatus == "approved"
            ? "pending_delivered"
            : nextStatus;
        item.UpdatedAtUtc = DateTime.UtcNow;

        if (canTransitionFromPending)
        {
            await ApplyRequestStockSideEffectsAsync(item, item.Status, cancellationToken);

            if (nextStatus == "approved")
            {
                await ApplyApprovedRequestSideEffectsAsync(item, cancellationToken);
                await CreateInvoiceForApprovedRequestAsync(item, cancellationToken);
            }
        }

        if (canTransitionPickupToFinal && nextStatus == "delivered")
        {
            await ApplyPickupDeliveredSideEffectsAsync(item, cancellationToken);

            dbContext.TransactionHistories.Add(new Domain.Entities.TransactionHistory
            {
                UserId = item.UserId,
                SellerId = item.SellerId,
                TransactionType = "delivered_completed",
                Status = "approved",
                Category = item.Category,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice,
                Weight = item.Weight,
                Unit = item.Unit,
                Purity = item.Purity,
                Amount = item.Amount,
                Currency = item.Currency,
                Notes = item.Notes,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        dbContext.AuditLogs.Add(new Domain.Entities.AuditLog
        {
            UserId = item.UserId,
            Action = "RequestStatusUpdated",
            EntityName = "TransactionHistory",
            EntityId = item.Id,
            Details = $"Request {item.Id}: {previousStatus} -> {item.Status}, type={item.TransactionType}, amount={item.Amount} {item.Currency}",
            CreatedAtUtc = DateTime.UtcNow
        });
        await dbContext.SaveChangesAsync(cancellationToken);
        await notificationService.CreateAsync(new CreateNotificationRequestDto
        {
            UserId = item.UserId,
            Type = nextStatus == "approved" ? NotificationType.OrderApproved : NotificationType.RequestUpdated,
            ReferenceType = NotificationReferenceType.Request,
            ReferenceId = item.Id,
            ActionUrl = "/wallet/requests",
            Title = "Request Status Updated",
            Body = $"Your {item.TransactionType} request was {item.Status}. Request: r-{item.Id}."
        }, cancellationToken);
        await realtimeNotifier.BroadcastRefreshHintAsync($"request-status:{requestId}:{item.Status}", cancellationToken);
        await realtimeNotifier.NotifyWalletRefreshSignalAsync(
            item.UserId,
            scope: "actions",
            reason: $"request-status:{item.Status}",
            walletAssetId: TryExtractWalletAssetId(item.Notes),
            transactionId: item.Id,
            cancellationToken: cancellationToken);
        await realtimeNotifier.NotifyWalletRefreshSignalAsync(
            item.UserId,
            scope: "review-transaction",
            reason: $"request-status:{item.Status}",
            walletAssetId: TryExtractWalletAssetId(item.Notes),
            transactionId: item.Id,
            cancellationToken: cancellationToken);
        if (nextStatus == "approved" && item.TransactionType is not null)
        {
            var recipientAction = item.TransactionType.Trim().ToLowerInvariant();
            if (recipientAction is "transfer" or "gift")
            {
                var recipientInvestorId = TryExtractRecipientInvestorUserId(item.Notes);
                if (recipientInvestorId.HasValue)
                {
                    await realtimeNotifier.BroadcastRefreshHintAsync(
                        $"wallet-action:{recipientAction}:{recipientInvestorId.Value}",
                        cancellationToken);
                    await realtimeNotifier.NotifyWalletRefreshSignalAsync(
                        recipientInvestorId.Value,
                        scope: "wallet-items",
                        reason: $"wallet-action:{recipientAction}:approved",
                        walletAssetId: TryExtractWalletAssetId(item.Notes),
                        transactionId: item.Id,
                        cancellationToken: cancellationToken);
                    await realtimeNotifier.NotifyWalletRefreshSignalAsync(
                        recipientInvestorId.Value,
                        scope: "actions",
                        reason: $"wallet-action:{recipientAction}:approved",
                        walletAssetId: TryExtractWalletAssetId(item.Notes),
                        transactionId: item.Id,
                        cancellationToken: cancellationToken);
                    await realtimeNotifier.NotifyWalletRefreshSignalAsync(
                        recipientInvestorId.Value,
                        scope: "review-transaction",
                        reason: $"wallet-action:{recipientAction}:approved",
                        walletAssetId: TryExtractWalletAssetId(item.Notes),
                        transactionId: item.Id,
                        cancellationToken: cancellationToken);
                }
            }
        }

        return Ok(ApiResponse<object>.Ok(new { status = item.Status }, "updated"));
    }

    private async Task ApplyPickupDeliveredSideEffectsAsync(
        Domain.Entities.TransactionHistory request,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(request.TransactionType, "pickup", StringComparison.OrdinalIgnoreCase)) return;

        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);
        if (wallet is null) return;

        var walletAssetId = TryExtractWalletAssetId(request.Notes);
        var asset = walletAssetId.HasValue
            ? wallet.Assets.FirstOrDefault(x => x.Id == walletAssetId.Value)
            : wallet.Assets.FirstOrDefault(x =>
                x.SellerId == request.SellerId &&
                x.Category.ToString().Equals(request.Category, StringComparison.OrdinalIgnoreCase));
        if (asset is null) return;

        var qtyToRemove = Math.Max(1, request.Quantity);
        var perUnitWeight = asset.Quantity == 0 ? 0 : asset.Weight / asset.Quantity;
        var maxWeightForRequestedQty = perUnitWeight > 0 ? perUnitWeight * qtyToRemove : request.Weight;
        var weightToRemove = request.Weight > 0 ? request.Weight : maxWeightForRequestedQty;

        if (maxWeightForRequestedQty > 0)
        {
            weightToRemove = Math.Min(weightToRemove, maxWeightForRequestedQty);
        }
        weightToRemove = Math.Min(weightToRemove, asset.Weight);

        asset.Quantity = Math.Max(asset.Quantity - qtyToRemove, 0);
        asset.Weight = Math.Max(asset.Weight - weightToRemove, 0);
        asset.UpdatedAtUtc = DateTime.UtcNow;

        if (asset.Quantity == 0 || asset.Weight <= 0)
        {
            dbContext.WalletAssets.Remove(asset);
        }

        wallet.UpdatedAtUtc = DateTime.UtcNow;
    }

    [HttpGet("requests/{id}")]
    public async Task<IActionResult> GetRequestDetails(string id, CancellationToken cancellationToken)
    {
        if (!int.TryParse(id.Replace("r-", string.Empty), out var requestId))
            return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        var details = await dbContext.TransactionHistories
            .AsNoTracking()
            .Where(x => x.Id == requestId)
            .Join(
                dbContext.Users.AsNoTracking(),
                history => history.UserId,
                user => user.Id,
                (history, user) => new WebRequestDto
                {
                    Id = $"r-{history.Id}",
                    InvestorId = FormatInvestorId(history.UserId),
                    InvestorName = user.FullName,
                    Type = history.TransactionType,
                    ProductName = history.Category,
                    Category = history.Category,
                    Quantity = history.Quantity,
                    UnitPrice = history.UnitPrice,
                    Weight = history.Weight,
                    Unit = history.Unit,
                    Purity = history.Purity,
                    Amount = history.Amount,
                    Status = MapRequestStatusForView(history.TransactionType, history.Status),
                    Currency = history.Currency,
                    Notes = history.Notes,
                    CreatedAt = history.CreatedAtUtc,
                    UpdatedAt = history.UpdatedAtUtc
                })
            .FirstOrDefaultAsync(cancellationToken);

        if (details is null) return NotFound(ApiResponse<object>.Fail("Request not found", 404));

        var sellerId = await dbContext.TransactionHistories
            .AsNoTracking()
            .Where(x => x.Id == requestId)
            .Select(x => x.SellerId)
            .FirstOrDefaultAsync(cancellationToken);
        if (!CanAccessSellerData(sellerId)) return Forbid();

        await PopulateRequestProductNamesAsync([details], cancellationToken);
        return Ok(ApiResponse<WebRequestDto>.Ok(details));
    }

    [HttpGet("invoices")]
    public async Task<IActionResult> GetInvoices(CancellationToken cancellationToken)
    {
        var sellerScope = ResolveSellerScope();
        var invoicesQuery = dbContext.Invoices
            .AsNoTracking()
            .AsQueryable();

        if (sellerScope.HasValue)
        {
            invoicesQuery = invoicesQuery.Where(x => dbContext.Sellers
                .Any(s => s.UserId == x.SellerUserId && s.Id == sellerScope.Value));
        }

        var invoices = await invoicesQuery
            .OrderByDescending(x => x.IssuedOnUtc)
            .Select(x => new WebInvoiceDto
            {
                Id = $"inv-{x.Id}",
                SellerId = FormatSellerId(dbContext.Sellers.Where(s => s.UserId == x.SellerUserId).Select(s => (int?)s.Id).FirstOrDefault() ?? 0),
                InvestorName = dbContext.Users.Where(u => u.Id == x.InvestorUserId).Select(u => u.FullName).FirstOrDefault() ?? $"User {x.InvestorUserId}",
                TotalAmount = x.TotalAmount,
                IssuedAt = x.IssuedOnUtc,
                Status = x.Status,
                PdfUrl = x.PdfUrl,
                PaymentStatus = x.PaymentStatus
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebInvoiceDto>>.Ok(invoices));
    }

    [HttpPost("invoices")]
    public async Task<IActionResult> AddInvoice([FromBody] WebInvoiceDto request, CancellationToken cancellationToken)
    {
        var investorUserId = TryParsePrefixedId(request.InvestorName, "I") ??
                             await dbContext.Users.Where(x => x.FullName == request.InvestorName).Select(x => (int?)x.Id).FirstOrDefaultAsync(cancellationToken) ??
                             await dbContext.Users.Where(x => x.Role == SystemRoles.Investor).Select(x => x.Id).FirstOrDefaultAsync(cancellationToken);

        var requestSellerId = TryParsePrefixedId(request.SellerId, "S");
        var sellerUserId = requestSellerId.HasValue
            ? await dbContext.Sellers.Where(x => x.Id == requestSellerId.Value).Select(x => (int?)x.UserId).FirstOrDefaultAsync(cancellationToken) ?? 0
            : await dbContext.Sellers.Select(x => (int?)x.UserId).FirstOrDefaultAsync(cancellationToken) ?? 0;
        var sellerUserSellerId = await dbContext.Sellers
            .Where(x => x.UserId == sellerUserId)
            .Select(x => (int?)x.Id)
            .FirstOrDefaultAsync(cancellationToken);
        if (!CanAccessSellerData(sellerUserSellerId)) return Forbid();

        var entity = new Domain.Entities.Invoice
        {
            InvestorUserId = investorUserId,
            SellerUserId = sellerUserId,
            InvoiceNumber = string.IsNullOrWhiteSpace(request.Id) ? $"INV-{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}" : request.Id,
            InvoiceCategory = "Buy",
            SourceChannel = "WebAdmin",
            ExternalReference = request.Id,
            SubTotal = request.TotalAmount,
            FeesAmount = 0,
            DiscountAmount = 0,
            TaxAmount = 0,
            TotalAmount = request.TotalAmount,
            Currency = "USD",
            PaymentMethod = "Manual",
            PaymentStatus = request.PaymentStatus,
            ProductName = "Wallet Item",
            Quantity = 1,
            UnitPrice = request.TotalAmount,
            Weight = 0,
            Purity = 0,
            FromPartyType = "Seller",
            ToPartyType = "Investor",
            FromPartyUserId = sellerUserId,
            ToPartyUserId = investorUserId,
            OwnershipEffectiveOnUtc = request.IssuedAt == default ? DateTime.UtcNow : request.IssuedAt,
            InvoiceQrCode = string.Empty,
            PdfUrl = request.PdfUrl,
            IssuedOnUtc = request.IssuedAt == default ? DateTime.UtcNow : request.IssuedAt,
            Status = request.Status,
            CreatedAtUtc = DateTime.UtcNow
        };

        dbContext.Invoices.Add(entity);
        await dbContext.SaveChangesAsync(cancellationToken);

        request.Id = $"inv-{entity.Id}";
        return Ok(ApiResponse<WebInvoiceDto>.Ok(request));
    }

    [HttpPut("invoices/{id}")]
    public async Task<IActionResult> UpdateInvoice(string id, [FromBody] WebInvoiceDto request, CancellationToken cancellationToken)
    {
        var invoiceId = TryParsePrefixedId(id, "inv-");
        if (invoiceId is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));

        var invoice = await dbContext.Invoices.FirstOrDefaultAsync(x => x.Id == invoiceId, cancellationToken);
        if (invoice is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));
        var sellerUserSellerId = await dbContext.Sellers
            .Where(x => x.UserId == invoice.SellerUserId)
            .Select(x => (int?)x.Id)
            .FirstOrDefaultAsync(cancellationToken);
        if (!CanAccessSellerData(sellerUserSellerId)) return Forbid();

        invoice.TotalAmount = request.TotalAmount;
        invoice.SubTotal = request.TotalAmount;
        invoice.Status = request.Status;
        invoice.PaymentStatus = request.PaymentStatus;
        invoice.PdfUrl = request.PdfUrl;
        invoice.UpdatedAtUtc = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpDelete("invoices/{id}")]
    public async Task<IActionResult> DeleteInvoice(string id, CancellationToken cancellationToken)
    {
        var invoiceId = TryParsePrefixedId(id, "inv-");
        if (invoiceId is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));

        var invoice = await dbContext.Invoices.FirstOrDefaultAsync(x => x.Id == invoiceId, cancellationToken);
        if (invoice is null) return NotFound(ApiResponse<object>.Fail("Invoice not found", 404));
        var sellerUserSellerId = await dbContext.Sellers
            .Where(x => x.UserId == invoice.SellerUserId)
            .Select(x => (int?)x.Id)
            .FirstOrDefaultAsync(cancellationToken);
        if (!CanAccessSellerData(sellerUserSellerId)) return Forbid();

        dbContext.Invoices.Remove(invoice);
        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("deleted"));
    }

    [HttpGet("fees")]
    public async Task<IActionResult> GetFees(CancellationToken cancellationToken)
    {
        var fees = await ReadFeesAsync(cancellationToken);
        return Ok(ApiResponse<WebFeesDto>.Ok(fees));
    }

    [HttpGet("reports/fee-breakdowns")]
    public async Task<IActionResult> GetFeeBreakdownReport(
        [FromQuery] string feeGroup = "all",
        [FromQuery] DateTime? from = null,
        [FromQuery] DateTime? to = null,
        CancellationToken cancellationToken = default)
    {
        var sellerScope = ResolveSellerScope();
        var normalizedGroup = (feeGroup ?? "all").Trim().ToLowerInvariant();
        var fromUtc = from?.Date;
        var toUtc = to?.Date.AddDays(1).AddTicks(-1);

        var query = dbContext.TransactionFeeBreakdowns
            .AsNoTracking()
            .Where(x => x.TransactionHistoryId.HasValue)
            .Join(
                dbContext.TransactionHistories.AsNoTracking(),
                fee => fee.TransactionHistoryId!.Value,
                history => history.Id,
                (fee, history) => new { Fee = fee, History = history });

        if (sellerScope.HasValue)
        {
            query = query.Where(x => x.Fee.SellerId == sellerScope.Value);
        }

        if (fromUtc.HasValue || toUtc.HasValue)
        {
            if (fromUtc.HasValue) query = query.Where(x => x.History.CreatedAtUtc >= fromUtc.Value);
            if (toUtc.HasValue) query = query.Where(x => x.History.CreatedAtUtc <= toUtc.Value);
        }

        if (normalizedGroup != "all")
        {
            var tokens = normalizedGroup switch
            {
                "commission" => new[] { "commission_per_transaction", "commission" },
                "premium" => new[] { "premium", "discount" },
                "storage" => new[] { "storage", "custody" },
                "delivery" => new[] { "delivery" },
                "service" => new[] { "service" },
                _ => Array.Empty<string>()
            };

            if (tokens.Length > 0)
            {
                query = query.Where(x => tokens.Any(token =>
                    x.Fee.FeeCode.ToLower().Contains(token) || x.Fee.FeeName.ToLower().Contains(token)));
            }
        }

        var sellers = await dbContext.Sellers
            .AsNoTracking()
            .Select(x => new { x.Id, Name = string.IsNullOrWhiteSpace(x.CompanyName) ? $"Seller {x.Id}" : x.CompanyName })
            .ToListAsync(cancellationToken);
        var sellerLookup = sellers.ToDictionary(x => x.Id, x => x.Name);

        var rawRows = await query
            .Select(x => new
            {
                SellerId = x.Fee.SellerId ?? 0,
                x.Fee.FeeCode,
                x.Fee.FeeName,
                x.Fee.CalculationMode,
                x.Fee.Currency,
                x.Fee.AppliedRate,
                x.Fee.AppliedValue,
                x.History.TransactionType,
                x.History.CreatedAtUtc,
                TransactionHistoryId = x.History.Id
            })
            .ToListAsync(cancellationToken);

        var rows = rawRows
            .GroupBy(x => new { x.SellerId, x.FeeCode, x.FeeName, x.CalculationMode, x.Currency })
            .Select(g => new WebFeeBreakdownReportRowDto
            {
                SellerId = FormatSellerId(g.Key.SellerId),
                SellerName = string.Empty,
                FeeCode = g.Key.FeeCode,
                FeeName = g.Key.FeeName,
                CalculationMode = g.Key.CalculationMode,
                AppliedRate = g.Any(x => x.AppliedRate.HasValue) ? g.Where(x => x.AppliedRate.HasValue).Average(x => x.AppliedRate) : null,
                TransactionsCount = g.Select(x => x.TransactionHistoryId).Distinct().Count(),
                CollectedAmount = g.Sum(x => x.AppliedValue),
                Currency = g.Key.Currency,
                TransactionTypes = string.Join(", ", g.Select(x => x.TransactionType).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct(StringComparer.OrdinalIgnoreCase)),
                LatestTransactionAt = g.Max(x => (DateTime?)x.CreatedAtUtc)
            })
            .OrderByDescending(x => x.CollectedAmount)
            .ToList();

        foreach (var row in rows)
        {
            var sellerId = TryParsePrefixedId(row.SellerId, "S") ?? 0;
            row.SellerName = sellerLookup.TryGetValue(sellerId, out var name) ? name : $"Seller {sellerId}";
        }

        return Ok(ApiResponse<List<WebFeeBreakdownReportRowDto>>.Ok(rows));
    }

    [HttpPut("fees")]
    public async Task<IActionResult> UpdateFees([FromBody] WebFeesDto request, CancellationToken cancellationToken)
    {
        await UpsertDecimalConfigurationAsync(MobileAppConfigurationKeys.FeesDelivery, "Fees Delivery", request.DeliveryFee, "Web admin delivery fee", cancellationToken);
        await UpsertDecimalConfigurationAsync(MobileAppConfigurationKeys.FeesStorage, "Fees Storage", request.StorageFee, "Web admin storage fee", cancellationToken);
        await UpsertDecimalConfigurationAsync(MobileAppConfigurationKeys.FeesServiceChargePercent, "Fees Service Charge", request.ServiceChargePercent, "Web admin service charge percent", cancellationToken);
        return Ok(ApiResponse<WebFeesDto>.Ok(request));
    }


    [HttpGet("wallet/sell-configuration")]
    public async Task<IActionResult> GetWalletSellConfiguration(CancellationToken cancellationToken)
    {
        var mode = await ReadConfigStringAsync(MobileAppConfigurationKeys.WalletSellMode, "locked_30_seconds", cancellationToken);
        var lockSeconds = await ReadConfigIntAsync(MobileAppConfigurationKeys.WalletSellLockSeconds, 30, cancellationToken);
        var payload = JsonSerializer.Serialize(new { mode, lockSeconds });
        return Ok(ApiResponse<string>.Ok(payload));
    }

    [Authorize(Roles = SystemRoles.Admin)]
    [HttpPut("wallet/sell-configuration")]
    public async Task<IActionResult> UpdateWalletSellConfiguration([FromBody] JsonElement request, CancellationToken cancellationToken)
    {
        var mode = request.TryGetProperty("mode", out var modeElement)
            ? (modeElement.GetString() ?? string.Empty).Trim().ToLowerInvariant()
            : string.Empty;

        if (mode is not ("locked_30_seconds" or "live_price"))
        {
            return BadRequest(ApiResponse<object>.Fail("mode must be locked_30_seconds or live_price", 400));
        }

        var lockSeconds = request.TryGetProperty("lockSeconds", out var lockElement)
            ? Math.Clamp(lockElement.GetInt32(), 5, 300)
            : 30;

        await UpsertStringConfigurationAsync(MobileAppConfigurationKeys.WalletSellMode, "Wallet Sell Mode", mode, "Wallet sell execution behavior", cancellationToken);
        await UpsertIntConfigurationAsync(MobileAppConfigurationKeys.WalletSellLockSeconds, "Wallet Sell Lock Seconds", lockSeconds, "Wallet sell lock duration seconds", cancellationToken);

        var payload = JsonSerializer.Serialize(new { mode, lockSeconds });
        return Ok(ApiResponse<string>.Ok(payload));
    }

    [HttpGet("notifications")]
    public async Task<IActionResult> GetNotifications(CancellationToken cancellationToken)
    {
        var currentUserId = GetCurrentUserId();
        if (currentUserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));

        var notifications = await dbContext.AppNotifications
            .AsNoTracking()
            .Where(x => x.UserId == currentUserId.Value)
            .OrderByDescending(x => x.CreatedAtUtc)
            .Take(50)
            .Select(x => new WebNotificationDto
            {
                Id = $"n-{x.Id}",
                Title = x.Title,
                Message = x.Body,
                Severity = "info",
                IsRead = x.IsRead,
                CreatedAt = x.CreatedAtUtc
            })
            .ToListAsync(cancellationToken);

        return Ok(ApiResponse<List<WebNotificationDto>>.Ok(notifications));
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard([FromQuery] string period = "today", CancellationToken cancellationToken = default)
    {
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        var currentSellerId = int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : (int?)null;
        var scopedSellerId = User.IsInRole(SystemRoles.Admin) ? null : currentSellerId;
        var dashboard = await dashboardService.BuildAsync(period, scopedSellerId, cancellationToken);
        return Ok(ApiResponse<WebDashboardDto>.Ok(dashboard));
    }

    [HttpPut("notifications/{id}/read")]
    public async Task<IActionResult> MarkNotificationAsRead(string id, CancellationToken cancellationToken)
    {
        var currentUserId = GetCurrentUserId();
        if (currentUserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));

        var notificationId = TryParsePrefixedId(id, "n-");
        if (notificationId is null) return NotFound(ApiResponse<object>.Fail("Notification not found", 404));

        var item = await dbContext.AppNotifications.FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == currentUserId.Value, cancellationToken);
        if (item is null) return NotFound(ApiResponse<object>.Fail("Notification not found", 404));

        item.IsRead = true;
        item.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
        return Ok(ApiResponse<string>.Ok("updated"));
    }

    [HttpPut("notifications/read-all")]
    public async Task<IActionResult> MarkAllNotificationsAsRead(CancellationToken cancellationToken)
    {
        var currentUserId = GetCurrentUserId();
        if (currentUserId is null) return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));

        var unread = await dbContext.AppNotifications
            .Where(x => x.UserId == currentUserId.Value && !x.IsRead)
            .ToListAsync(cancellationToken);

        var utcNow = DateTime.UtcNow;
        foreach (var item in unread)
        {
            item.IsRead = true;
            item.ReadAtUtc = utcNow;
            item.UpdatedAtUtc = utcNow;
        }

        if (unread.Count > 0)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        return Ok(ApiResponse<string>.Ok("updated"));
    }

    private int? GetCurrentUserId()
    {
        var claimValue = User.FindFirst("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier")?.Value
            ?? User.FindFirst("sub")?.Value
            ?? User.FindFirst("user_id")?.Value;
        return int.TryParse(claimValue, out var parsed) ? parsed : null;
    }

    private async Task PopulateRequestProductNamesAsync(List<WebRequestDto> requests, CancellationToken cancellationToken)
    {
        if (requests.Count == 0) return;

        var requestIds = requests
            .Select(x => TryParsePrefixedId(x.Id, "r-"))
            .Where(x => x.HasValue)
            .Select(x => x!.Value)
            .ToList();
        if (requestIds.Count == 0) return;

        var histories = await dbContext.TransactionHistories
            .AsNoTracking()
            .Where(x => requestIds.Contains(x.Id))
            .Select(x => new { x.Id, x.SellerId, x.Notes, x.Category })
            .ToListAsync(cancellationToken);

        var skuByRequestId = histories
            .Select(x => new { x.Id, x.SellerId, Sku = TryExtractSku(x.Notes) })
            .Where(x => x.SellerId.HasValue && !string.IsNullOrWhiteSpace(x.Sku))
            .ToList();

        var sellerIds = skuByRequestId.Select(x => x.SellerId!.Value).Distinct().ToList();
        var skuValues = skuByRequestId.Select(x => x.Sku!).Distinct(StringComparer.OrdinalIgnoreCase).ToList();

        var products = await dbContext.Products
            .AsNoTracking()
            .Where(x => sellerIds.Contains(x.SellerId) && skuValues.Contains(x.Sku))
            .Select(x => new { x.SellerId, x.Sku, x.Name, x.ImageUrl })
            .ToListAsync(cancellationToken);

        var productLookup = products.ToDictionary(
            x => (x.SellerId, x.Sku),
            x => (x.Name, x.ImageUrl));

        foreach (var request in requests)
        {
            var requestId = TryParsePrefixedId(request.Id, "r-");
            if (!requestId.HasValue) continue;

            var history = histories.FirstOrDefault(x => x.Id == requestId.Value);
            if (history is null)
            {
                request.ProductName = request.Category;
                request.ProductImageUrl = string.Empty;
                continue;
            }

            var sku = TryExtractSku(history.Notes);
            if (history.SellerId.HasValue &&
                !string.IsNullOrWhiteSpace(sku) &&
                productLookup.TryGetValue((history.SellerId.Value, sku), out var product))
            {
                request.ProductName = product.Name;
                request.ProductImageUrl = ToAbsoluteAssetUrl(product.ImageUrl);
            }
            else
            {
                request.ProductName = history.Category;
                request.ProductImageUrl = string.Empty;
            }
        }
    }

    private string ToAbsoluteAssetUrl(string? imageUrl)
    {
        if (string.IsNullOrWhiteSpace(imageUrl)) return string.Empty;
        if (Uri.TryCreate(imageUrl, UriKind.Absolute, out _)) return imageUrl;

        var request = HttpContext.Request;
        var normalized = imageUrl.StartsWith('/') ? imageUrl : $"/{imageUrl}";
        return $"{request.Scheme}://{request.Host}{normalized}";
    }

    private async Task<WebFeesDto> ReadFeesAsync(CancellationToken cancellationToken)
    {
        return new WebFeesDto
        {
            DeliveryFee = await ReadConfigDecimalAsync(MobileAppConfigurationKeys.FeesDelivery, 12m, cancellationToken),
            StorageFee = await ReadConfigDecimalAsync(MobileAppConfigurationKeys.FeesStorage, 4m, cancellationToken),
            ServiceChargePercent = await ReadConfigDecimalAsync(MobileAppConfigurationKeys.FeesServiceChargePercent, 2.5m, cancellationToken)
        };
    }

    private async Task<string> ReadConfigStringAsync(string key, string fallback, CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.AsNoTracking().FirstOrDefaultAsync(x => x.ConfigKey == key, cancellationToken);
        return string.IsNullOrWhiteSpace(config?.ValueString) ? fallback : config.ValueString;
    }

    private async Task<int> ReadConfigIntAsync(string key, int fallback, CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.AsNoTracking().FirstOrDefaultAsync(x => x.ConfigKey == key, cancellationToken);
        return config?.ValueInt ?? fallback;
    }

    private async Task<decimal> ReadConfigDecimalAsync(string key, decimal fallback, CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.AsNoTracking().FirstOrDefaultAsync(x => x.ConfigKey == key, cancellationToken);
        return config?.ValueDecimal ?? fallback;
    }

    private async Task UpsertStringConfigurationAsync(string key, string name, string value, string description, CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.FirstOrDefaultAsync(x => x.ConfigKey == key, cancellationToken);
        if (config is null)
        {
            dbContext.MobileAppConfigurations.Add(new Domain.Entities.MobileAppConfiguration
            {
                ConfigKey = key,
                Name = name,
                ValueType = ConfigurationValueType.String,
                ValueString = value,
                Description = description,
                SellerAccess = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }
        else
        {
            config.Name = name;
            config.ValueType = ConfigurationValueType.String;
            config.ValueString = value;
            config.ValueBool = null;
            config.ValueInt = null;
            config.ValueDecimal = null;
            config.Description = description;
            config.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task UpsertIntConfigurationAsync(string key, string name, int value, string description, CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.FirstOrDefaultAsync(x => x.ConfigKey == key, cancellationToken);
        if (config is null)
        {
            dbContext.MobileAppConfigurations.Add(new Domain.Entities.MobileAppConfiguration
            {
                ConfigKey = key,
                Name = name,
                ValueType = ConfigurationValueType.Int,
                ValueInt = value,
                Description = description,
                SellerAccess = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }
        else
        {
            config.Name = name;
            config.ValueType = ConfigurationValueType.Int;
            config.ValueString = null;
            config.ValueBool = null;
            config.ValueInt = value;
            config.ValueDecimal = null;
            config.Description = description;
            config.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task UpsertDecimalConfigurationAsync(string key, string name, decimal value, string description, CancellationToken cancellationToken)
    {
        var config = await dbContext.MobileAppConfigurations.FirstOrDefaultAsync(x => x.ConfigKey == key, cancellationToken);
        if (config is null)
        {
            dbContext.MobileAppConfigurations.Add(new Domain.Entities.MobileAppConfiguration
            {
                ConfigKey = key,
                Name = name,
                ValueType = ConfigurationValueType.Decimal,
                ValueDecimal = value,
                Description = description,
                SellerAccess = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }
        else
        {
            config.Name = name;
            config.ValueType = ConfigurationValueType.Decimal;
            config.ValueString = null;
            config.ValueBool = null;
            config.ValueInt = null;
            config.ValueDecimal = value;
            config.Description = description;
            config.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private static string FormatSellerId(int id) => $"S{id:D3}";
    private static List<MarketTypeSettingsDto> BuildDefaultMarketSettings() =>
    [
        new() { MarketType = "UAE", Currency = "AED", FeesPercent = 2.5m, PaymentGateway = "PayTabs" },
        new() { MarketType = "KSA", Currency = "SAR", FeesPercent = 2.5m, PaymentGateway = "HyperPay" },
        new() { MarketType = "Jordan", Currency = "JOD", FeesPercent = 2.0m, PaymentGateway = "MyFatoorah" },
        new() { MarketType = "Egypt", Currency = "EGP", FeesPercent = 2.0m, PaymentGateway = "Paymob" },
        new() { MarketType = "India", Currency = "INR", FeesPercent = 1.8m, PaymentGateway = "Razorpay" }
    ];

    private static string NormalizeMarketType(string? input)
    {
        return input?.Trim().ToUpperInvariant() switch
        {
            "UAE" => "UAE",
            "KSA" => "KSA",
            "JORDAN" => "Jordan",
            "EGYPT" => "Egypt",
            "INDIA" => "India",
            _ => "UAE"
        };
    }

    private static string NormalizeMarketTypeOrThrow(string? input)
    {
        var normalized = NormalizeMarketType(input);
        if (string.IsNullOrWhiteSpace(input))
            throw new InvalidOperationException("Market type is required.");
        return normalized;
    }

    private static string FormatInvestorId(int id) => $"{id:D3}";

    private static int? TryParsePrefixedId(string value, string prefix)
    {
        if (string.IsNullOrWhiteSpace(value)) return null;
        var clean = value.Trim();
        if (!string.IsNullOrWhiteSpace(prefix) && clean.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
        {
            clean = clean[prefix.Length..];
        }

        clean = clean.TrimStart('-', '_');
        if (int.TryParse(clean, out var parsed))
        {
            return parsed;
        }

        var digits = new string(clean.Where(char.IsDigit).ToArray());
        return int.TryParse(digits, out parsed) ? parsed : null;
    }

    private int? ResolveSellerScope()
    {
        if (User.IsInRole(SystemRoles.Admin)) return null;
        var sellerIdClaim = User.FindFirst("seller_id")?.Value;
        return int.TryParse(sellerIdClaim, out var parsedSellerId) ? parsedSellerId : (int?)null;
    }

    private bool CanAccessSellerData(int? resourceSellerId)
    {
        var sellerScope = ResolveSellerScope();
        return !sellerScope.HasValue || (resourceSellerId.HasValue && resourceSellerId.Value == sellerScope.Value);
    }

    private static string MapRequestStatusForView(string? transactionType, string? status)
    {
        var type = (transactionType ?? string.Empty).Trim().ToLowerInvariant();
        var normalizedStatus = (status ?? string.Empty).Trim().ToLowerInvariant();

        if (type == "pickup" && normalizedStatus == "approved")
        {
            return "pending_delivered";
        }

        if (normalizedStatus is "cancelled" or "canceled")
        {
            return "cancelled";
        }

        return normalizedStatus;
    }

    private async Task ApplyApprovedRequestSideEffectsAsync(Domain.Entities.TransactionHistory request, CancellationToken cancellationToken)
    {
        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        if (wallet is null)
        {
            wallet = new Domain.Entities.Wallet
            {
                UserId = request.UserId,
                CurrencyCode = request.Currency,
                CashBalance = 0,
                CreatedAtUtc = DateTime.UtcNow
            };
            dbContext.Wallets.Add(wallet);
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        var action = request.TransactionType.Trim().ToLowerInvariant();
        if (action == "buy")
        {
            var quantity = Math.Max(1, request.Quantity);
            var feeAwareUnitCost = request.FinalAmount > 0
                ? request.FinalAmount / quantity
                : request.UnitPrice;
            var sourceProduct = request.ProductId.HasValue
                ? await dbContext.Products.AsNoTracking().FirstOrDefaultAsync(x => x.Id == request.ProductId.Value, cancellationToken)
                : null;
            var (purityKarat, purityDisplayName) = ResolvePurityMetadata(sourceProduct);

            var createdAsset = new Domain.Entities.WalletAsset
            {
                WalletId = wallet.Id,
                ProductId = sourceProduct?.Id ?? request.ProductId,
                ProductName = sourceProduct?.Name ?? request.Category,
                ProductSku = sourceProduct?.Sku,
                ProductImageUrl = sourceProduct?.ImageUrl,
                MaterialType = sourceProduct?.MaterialType.ToString() ?? request.Category,
                FormType = sourceProduct?.FormType.ToString() ?? "Jewelry",
                PurityKarat = purityKarat,
                PurityDisplayName = purityDisplayName,
                WeightValue = sourceProduct?.WeightValue ?? request.Weight,
                WeightUnit = sourceProduct?.WeightUnit.ToString() ?? request.Unit,
                SellerId = request.SellerId,
                SellerName = await dbContext.Sellers.Where(s => s.Id == request.SellerId).Select(s => s.CompanyName).FirstOrDefaultAsync(cancellationToken) ?? string.Empty,
                Category = Enum.TryParse<ProductCategory>(request.Category, true, out var cat) ? cat : ProductCategory.Gold,
                AssetType = AssetType.GoldBar,
                Quantity = quantity,
                AverageBuyPrice = feeAwareUnitCost,
                CurrentMarketPrice = request.UnitPrice,
                Weight = request.Weight,
                Unit = request.Unit,
                Purity = request.Purity,
                AcquisitionSubTotalAmount = request.SubTotalAmount,
                AcquisitionFeesAmount = request.TotalFeesAmount,
                AcquisitionDiscountAmount = request.DiscountAmount,
                AcquisitionFinalAmount = request.FinalAmount,
                LastTransactionHistoryId = request.Id,
                SourceInvoiceId = request.InvoiceId,
                CreatedAtUtc = DateTime.UtcNow
            };

            wallet.Assets.Add(createdAsset);
        }
        else if (action is "sell" or "pickup" or "transfer" or "gift")
        {
            var walletAssetId = TryExtractWalletAssetId(request.Notes);
            var asset = walletAssetId.HasValue
                ? wallet.Assets.FirstOrDefault(x => x.Id == walletAssetId.Value)
                : wallet.Assets.FirstOrDefault(x => x.SellerId == request.SellerId && x.Category.ToString().Equals(request.Category, StringComparison.OrdinalIgnoreCase));
            var weightToRemove = 0m;
            if (asset is not null)
            {
                var qtyToRemove = Math.Max(1, request.Quantity);
                var perUnitWeight = asset.Quantity == 0 ? 0 : asset.Weight / asset.Quantity;
                var maxWeightForRequestedQty = perUnitWeight > 0 ? perUnitWeight * qtyToRemove : request.Weight;
                weightToRemove = request.Weight > 0 ? request.Weight : maxWeightForRequestedQty;
                if (maxWeightForRequestedQty > 0)
                {
                    weightToRemove = Math.Min(weightToRemove, maxWeightForRequestedQty);
                }
                weightToRemove = Math.Min(weightToRemove, asset.Weight);

                if (action != "pickup")
                {
                    asset.Quantity = Math.Max(asset.Quantity - qtyToRemove, 0);
                    asset.Weight = Math.Max(asset.Weight - weightToRemove, 0);
                    asset.UpdatedAtUtc = DateTime.UtcNow;
                    if (asset.Quantity == 0 && asset.Weight <= 0)
                    {
                        dbContext.WalletAssets.Remove(asset);
                    }
                }
            }

            if (action is "transfer" or "gift")
            {
                var recipientInvestorId = TryExtractRecipientInvestorUserId(request.Notes);
                if (recipientInvestorId.HasValue && recipientInvestorId.Value > 0)
                {
                    var recipientWallet = await GetOrCreateWalletForUserAsync(recipientInvestorId.Value, wallet.CurrencyCode, cancellationToken);
                    if (asset is not null)
                    {
                        AddOrUpdateRecipientAsset(recipientWallet, asset, request.Quantity, weightToRemove, request.UnitPrice);
                    }

                    var senderName = await dbContext.Users
                        .Where(x => x.Id == request.UserId)
                        .Select(x => x.FullName)
                        .FirstOrDefaultAsync(cancellationToken) ?? $"Investor {request.UserId}";

                    dbContext.TransactionHistories.Add(new Domain.Entities.TransactionHistory
                    {
                        UserId = recipientInvestorId.Value,
                        SellerId = request.SellerId,
                        TransactionType = action,
                        Status = "approved",
                        Category = request.Category,
                        Quantity = request.Quantity,
                        UnitPrice = request.UnitPrice,
                        Weight = weightToRemove > 0 ? weightToRemove : request.Weight,
                        Unit = request.Unit,
                        Purity = request.Purity,
                        Amount = weightToRemove > 0 && request.UnitPrice > 0
                            ? request.UnitPrice * weightToRemove
                            : request.Amount,
                        Currency = recipientWallet.CurrencyCode,
                        Notes = $"direction=received|from_investor_user_id={request.UserId}|from_investor_name={senderName}|source_request_id={request.Id}",
                        CreatedAtUtc = DateTime.UtcNow
                    });

                    dbContext.AppNotifications.Add(new Domain.Entities.AppNotification
                    {
                        UserId = recipientInvestorId.Value,
                        Title = action == "gift" ? "Gift received" : "Transfer received",
                        Body = $"{request.Quantity} unit(s) received from {senderName}.",
                        IsRead = false,
                        CreatedAtUtc = DateTime.UtcNow
                    });
                }
            }

            if (action is "sell")
            {
                wallet.CashBalance += request.Amount;
                wallet.UpdatedAtUtc = DateTime.UtcNow;
            }

        }
    }

    private static (string? PurityKarat, string? PurityDisplayName) ResolvePurityMetadata(Domain.Entities.Product? product)
    {
        if (product is null) return (null, null);

        var karatLabel = product.PurityKarat switch
        {
            ProductPurityKarat.K24 => "24K",
            ProductPurityKarat.K22 => "22K",
            ProductPurityKarat.K21 => "21K",
            ProductPurityKarat.K18 => "18K",
            ProductPurityKarat.K14 => "14K",
            _ => null
        };

        return product.MaterialType switch
        {
            ProductMaterialType.Gold => (karatLabel, karatLabel),
            ProductMaterialType.Silver => (karatLabel, karatLabel switch
            {
                "24K" => ".999",
                "22K" => ".925",
                _ => ".999"
            }),
            ProductMaterialType.Diamond => (null, null),
            _ => (karatLabel, karatLabel)
        };
    }

    private async Task ApplyRequestStockSideEffectsAsync(
        Domain.Entities.TransactionHistory request,
        string nextStatus,
        CancellationToken cancellationToken)
    {
        if (request.SellerId is null || request.Quantity <= 0) return;

        var action = request.TransactionType.Trim().ToLowerInvariant();
        var categoryValue = request.Category.Trim();

        var productsQuery = dbContext.Products
            .Where(x => x.SellerId == request.SellerId && x.IsActive);

        var skuFromNotes = TryExtractSku(request.Notes);
        if (!string.IsNullOrWhiteSpace(skuFromNotes))
        {
            productsQuery = productsQuery.Where(x => x.Sku == skuFromNotes);
        }
        else if (Enum.TryParse<ProductCategory>(categoryValue, true, out var parsedCategory))
        {
            productsQuery = productsQuery.Where(x => x.Category == parsedCategory);
        }
        else
        {
            var categoryLower = categoryValue.ToLowerInvariant();
            productsQuery = productsQuery.Where(x => x.Category.ToString().ToLower().Contains(categoryLower));
        }

        var product = await productsQuery.OrderBy(x => x.Id).FirstOrDefaultAsync(cancellationToken);
        if (product is null) return;

        var quantity = Math.Max(1, request.Quantity);

        if (action == "buy")
        {
            if (nextStatus == "approved")
            {
                if (product.AvailableStock < quantity)
                {
                    throw new InvalidOperationException($"Insufficient stock for {product.Name}. Available {product.AvailableStock}, requested {quantity}.");
                }

                product.AvailableStock -= quantity;
            }
        }
        else if (action is "sell" or "pickup")
        {
            if (nextStatus == "approved")
            {
                product.AvailableStock += quantity;
            }
        }

        product.UpdatedAtUtc = DateTime.UtcNow;
    }

    private static string? TryExtractSku(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;

        const string marker = "SKU=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;

        var tail = notes[valueStart..].Trim();
        if (tail.Length == 0) return null;

        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        return stopAt > 0 ? tail[..stopAt].Trim() : tail;
    }


    private static int? TryExtractWalletAssetId(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;

        const string marker = "wallet_asset_id=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;

        var tail = notes[valueStart..].Trim();
        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        var rawValue = stopAt > 0 ? tail[..stopAt].Trim() : tail;
        return int.TryParse(rawValue, out var id) ? id : null;
    }

    private static int? TryExtractRecipientInvestorUserId(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;

        const string marker = "recipient_investor_user_id=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;

        var tail = notes[valueStart..].Trim();
        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        var rawValue = stopAt > 0 ? tail[..stopAt].Trim() : tail;
        return int.TryParse(rawValue, out var id) ? id : null;
    }

    private async Task<Domain.Entities.Wallet> GetOrCreateWalletForUserAsync(int userId, string currencyCode, CancellationToken cancellationToken)
    {
        var wallet = await dbContext.Wallets
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

        if (wallet is not null) return wallet;

        wallet = new Domain.Entities.Wallet
        {
            UserId = userId,
            CurrencyCode = string.IsNullOrWhiteSpace(currencyCode) ? "USD" : currencyCode,
            CashBalance = 0,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        dbContext.Wallets.Add(wallet);
        return wallet;
    }

    private static void AddOrUpdateRecipientAsset(
        Domain.Entities.Wallet recipientWallet,
        Domain.Entities.WalletAsset sourceAsset,
        int quantity,
        decimal weight,
        decimal unitPrice)
    {
        var qtyToAdd = Math.Max(1, quantity);
        var weightToAdd = Math.Max(0.001m, weight);

        var existing = recipientWallet.Assets.FirstOrDefault(x =>
            x.SellerId == sourceAsset.SellerId &&
            x.Category == sourceAsset.Category &&
            x.Unit == sourceAsset.Unit &&
            x.Purity == sourceAsset.Purity);

        if (existing is null)
        {
            recipientWallet.Assets.Add(new Domain.Entities.WalletAsset
            {
                ProductId = sourceAsset.ProductId,
                ProductName = sourceAsset.ProductName,
                ProductSku = sourceAsset.ProductSku,
                ProductImageUrl = sourceAsset.ProductImageUrl,
                MaterialType = sourceAsset.MaterialType,
                FormType = sourceAsset.FormType,
                PurityKarat = sourceAsset.PurityKarat,
                PurityDisplayName = sourceAsset.PurityDisplayName,
                WeightValue = sourceAsset.WeightValue,
                WeightUnit = sourceAsset.WeightUnit,
                SellerId = sourceAsset.SellerId,
                SellerName = sourceAsset.SellerName,
                Category = sourceAsset.Category,
                AssetType = sourceAsset.AssetType,
                Quantity = qtyToAdd,
                Weight = weightToAdd,
                Unit = sourceAsset.Unit,
                Purity = sourceAsset.Purity,
                AverageBuyPrice = unitPrice,
                CurrentMarketPrice = sourceAsset.CurrentMarketPrice > 0 ? sourceAsset.CurrentMarketPrice : unitPrice,
                AcquisitionSubTotalAmount = sourceAsset.AcquisitionSubTotalAmount,
                AcquisitionFeesAmount = sourceAsset.AcquisitionFeesAmount,
                AcquisitionDiscountAmount = sourceAsset.AcquisitionDiscountAmount,
                AcquisitionFinalAmount = sourceAsset.AcquisitionFinalAmount,
                LastTransactionHistoryId = sourceAsset.LastTransactionHistoryId,
                SourceInvoiceId = sourceAsset.SourceInvoiceId,
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            });
            return;
        }

        var newTotalQty = existing.Quantity + qtyToAdd;
        existing.AverageBuyPrice = newTotalQty <= 0
            ? existing.AverageBuyPrice
            : ((existing.AverageBuyPrice * existing.Quantity) + (unitPrice * qtyToAdd)) / newTotalQty;
        existing.Quantity = newTotalQty;
        existing.Weight += weightToAdd;
        existing.CurrentMarketPrice = sourceAsset.CurrentMarketPrice > 0 ? sourceAsset.CurrentMarketPrice : unitPrice;
        existing.LastTransactionHistoryId = sourceAsset.LastTransactionHistoryId;
        existing.SourceInvoiceId = sourceAsset.SourceInvoiceId;
        existing.UpdatedAtUtc = DateTime.UtcNow;
    }

    private async Task CreateInvoiceForApprovedRequestAsync(Domain.Entities.TransactionHistory request, CancellationToken cancellationToken)
    {
        var sellerUserId = await dbContext.Sellers
            .Where(x => x.Id == request.SellerId)
            .Select(x => (int?)x.UserId)
            .FirstOrDefaultAsync(cancellationToken) ?? 0;

        var pdfUrl = await SaveInvoiceDocumentAsync(request, cancellationToken);

        dbContext.Invoices.Add(new Domain.Entities.Invoice
        {
            InvestorUserId = request.UserId,
            SellerUserId = sellerUserId,
            InvoiceNumber = $"INV-REQ-{request.Id}-{DateTime.UtcNow:yyyyMMddHHmmss}",
            InvoiceCategory = NormalizeInvoiceCategory(request.TransactionType),
            SourceChannel = "RequestApproval",
            ExternalReference = $"REQ-{request.Id}",
            SubTotal = request.Amount,
            FeesAmount = 0,
            DiscountAmount = 0,
            TaxAmount = 0,
            TotalAmount = request.Amount,
            Currency = request.Currency,
            PaymentMethod = "Manual",
            PaymentStatus = "Pending",
            ProductName = request.Category,
            Quantity = request.Quantity,
            UnitPrice = request.UnitPrice,
            Weight = request.Weight,
            Purity = request.Purity,
            FromPartyType = "Investor",
            ToPartyType = "Seller",
            FromPartyUserId = request.UserId,
            ToPartyUserId = sellerUserId,
            OwnershipEffectiveOnUtc = DateTime.UtcNow,
            RelatedTransactionId = request.Id,
            InvoiceQrCode = pdfUrl ?? string.Empty,
            PdfUrl = pdfUrl,
            WalletItemId = ExtractWalletAssetId(request.Notes),
            IssuedOnUtc = DateTime.UtcNow,
            Status = "Issued",
            CreatedAtUtc = DateTime.UtcNow
        });
    }

    private static string NormalizeInvoiceCategory(string? type)
    {
        var value = type?.Trim().ToLowerInvariant();
        return value switch
        {
            "sell" => "Sell",
            "transfer" => "Transfer",
            "gift" => "Gift",
            "pickup" => "Pickup",
            _ => "Buy"
        };
    }

    private static int? ExtractWalletAssetId(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;
        const string marker = "wallet_asset_id=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;
        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;
        var tail = notes[valueStart..];
        var stop = tail.IndexOfAny(['|', ',', ';', ' ']);
        var raw = stop > 0 ? tail[..stop] : tail;
        return int.TryParse(raw, out var id) ? id : null;
    }

    private async Task<string?> SaveInvoiceDocumentAsync(Domain.Entities.TransactionHistory request, CancellationToken cancellationToken)
    {
        var root = environment.WebRootPath;
        if (string.IsNullOrWhiteSpace(root))
        {
            root = Path.Combine(environment.ContentRootPath, "wwwroot");
        }

        var folder = Path.Combine(root, "Certificats", request.UserId.ToString());
        Directory.CreateDirectory(folder);

        var fileName = $"invoice-{Guid.NewGuid():N}.pdf";
        var filePath = Path.Combine(folder, fileName);
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
        var pdfBytes = InvoicePdfTemplateBuilder.Build("Gold Wallet Invoice", lines);
        await System.IO.File.WriteAllBytesAsync(filePath, pdfBytes, cancellationToken);
        return $"/Certificats/{request.UserId}/{fileName}";
    }

    private async Task<WebUserCredentialsDto> UpdateUserCredentialsAsync(
        string formattedUserId,
        Domain.Entities.User user,
        UpdateWebUserCredentialsRequest request,
        CancellationToken cancellationToken)
    {
        var hasEmailUpdate = !string.IsNullOrWhiteSpace(request.LoginEmail);
        var hasPhoneUpdate = !string.IsNullOrWhiteSpace(request.LoginPhone);
        var hasPasswordUpdate = !string.IsNullOrWhiteSpace(request.NewPassword);

        if (!hasEmailUpdate && !hasPhoneUpdate && !hasPasswordUpdate)
        {
            throw new InvalidOperationException("At least one credential field must be provided.");
        }

        if (hasEmailUpdate)
        {
            var email = request.LoginEmail!.Trim();
            var exists = await dbContext.Users.AnyAsync(x => x.Id != user.Id && x.Email == email, cancellationToken);
            if (exists) throw new InvalidOperationException("Login email is already used by another user.");
            user.Email = email;
        }

        if (hasPhoneUpdate)
        {
            var phone = request.LoginPhone!.Trim();
            var exists = await dbContext.Users.AnyAsync(x => x.Id != user.Id && x.PhoneNumber == phone, cancellationToken);
            if (exists) throw new InvalidOperationException("Login phone is already used by another user.");
            user.PhoneNumber = phone;
        }

        if (hasPasswordUpdate)
        {
            user.PasswordHash = passwordHasher.Hash(request.NewPassword!.Trim());
        }

        user.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);

        return new WebUserCredentialsDto
        {
            UserId = formattedUserId,
            LoginEmail = user.Email,
            LoginPhone = user.PhoneNumber ?? string.Empty,
            UpdatedAt = user.UpdatedAtUtc
        };
    }
}
