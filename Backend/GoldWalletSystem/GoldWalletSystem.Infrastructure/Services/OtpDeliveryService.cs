using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Net.Mail;

namespace GoldWalletSystem.Infrastructure.Services;

public class OtpDeliveryService(
    ILogger<OtpDeliveryService> logger,
    AppDbContext dbContext,
    IConfiguration configuration) : IOtpDeliveryService
{
    private readonly OtpDeliveryOptions options = BuildOptions(configuration);

    public async Task SendOtpAsync(User user, string otpCode, IReadOnlyCollection<OtpDeliveryChannel> channels, CancellationToken cancellationToken = default)
    {
        if (channels.Count == 0)
            throw new InvalidOperationException("At least one OTP channel is required.");

        var deliveredChannels = new List<OtpDeliveryChannel>();
        var failures = new List<string>();

        foreach (var channel in channels)
        {
            try
            {
                switch (channel)
                {
                    case OtpDeliveryChannel.WhatsApp:
                        await SendViaWhatsAppAsync(user, otpCode, cancellationToken);
                        deliveredChannels.Add(channel);
                        break;
                    case OtpDeliveryChannel.Email:
                        await SendViaEmailAsync(user, otpCode, cancellationToken);
                        deliveredChannels.Add(channel);
                        break;
                    default:
                        failures.Add($"Unsupported channel: {channel}");
                        break;
                }
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Failed sending OTP for user {UserId} via {Channel}.", user.Id, channel);
                failures.Add($"{channel}: {ex.Message}");
            }
        }

        foreach (var channel in deliveredChannels)
        {
            dbContext.AppNotifications.Add(new AppNotification
            {
                UserId = user.Id,
                Title = $"OTP sent via {channel}",
                Body = $"A verification OTP was sent to your {channel} destination.",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        if (deliveredChannels.Count == 0)
        {
            throw new InvalidOperationException($"OTP delivery failed for all channels. {string.Join(" | ", failures)}");
        }
    }

    private async Task SendViaWhatsAppAsync(User user, string otpCode, CancellationToken cancellationToken)
    {
        if (!options.WhatsApp.Enabled)
            throw new InvalidOperationException("WhatsApp delivery is disabled.");
        if (string.IsNullOrWhiteSpace(options.WhatsApp.AccessToken) || string.IsNullOrWhiteSpace(options.WhatsApp.PhoneNumberId))
            throw new InvalidOperationException("WhatsApp credentials are missing.");
        if (string.IsNullOrWhiteSpace(user.PhoneNumber))
            throw new InvalidOperationException("User phone number is missing.");

        var endpoint = $"https://graph.facebook.com/{options.WhatsApp.ApiVersion}/{options.WhatsApp.PhoneNumberId}/messages";
        var payload = new
        {
            messaging_product = "whatsapp",
            to = NormalizeWhatsAppTarget(user.PhoneNumber),
            type = "text",
            text = new
            {
                body = $"Your GoldWallet OTP code is {otpCode}. It expires in a few minutes."
            }
        };

        using var request = new HttpRequestMessage(HttpMethod.Post, endpoint)
        {
            Content = JsonContent.Create(payload)
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", options.WhatsApp.AccessToken);

        using var client = new HttpClient();
        using var response = await client.SendAsync(request, cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            var responseBody = await response.Content.ReadAsStringAsync(cancellationToken);
            throw new InvalidOperationException($"WhatsApp API failed ({(int)response.StatusCode}): {responseBody}");
        }

        logger.LogInformation(
            "OTP delivered via WhatsApp sender {SenderNumber} to user {UserId} ({PhoneNumber}).",
            options.WhatsApp.SenderNumber,
            user.Id,
            user.PhoneNumber);
    }

    private async Task SendViaEmailAsync(User user, string otpCode, CancellationToken cancellationToken)
    {
        if (!options.Email.Enabled)
            throw new InvalidOperationException("Email delivery is disabled.");
        if (string.IsNullOrWhiteSpace(options.Email.FromAddress) || string.IsNullOrWhiteSpace(options.Email.SmtpHost))
            throw new InvalidOperationException("Email SMTP configuration is incomplete.");
        if (string.IsNullOrWhiteSpace(user.Email))
            throw new InvalidOperationException("User email is missing.");

        using var message = new MailMessage
        {
            From = new MailAddress(options.Email.FromAddress, options.Email.FromName),
            Subject = "Your GoldWallet OTP code",
            Body = $"Your OTP code is: {otpCode}\nThis code will expire shortly.",
            IsBodyHtml = false,
            BodyEncoding = System.Text.Encoding.UTF8,
            SubjectEncoding = System.Text.Encoding.UTF8
        };
        message.To.Add(new MailAddress(user.Email));

        using var smtp = new SmtpClient(options.Email.SmtpHost, options.Email.SmtpPort)
        {
            EnableSsl = options.Email.UseSsl,
            DeliveryMethod = SmtpDeliveryMethod.Network,
            UseDefaultCredentials = false,
            Credentials = string.IsNullOrWhiteSpace(options.Email.Username)
                ? CredentialCache.DefaultNetworkCredentials
                : new NetworkCredential(options.Email.Username, options.Email.Password)
        };

        cancellationToken.ThrowIfCancellationRequested();
        await smtp.SendMailAsync(message, cancellationToken);

        logger.LogInformation(
            "OTP delivered via Email sender {FromName} <{FromAddress}> to user {UserId} ({Email}).",
            options.Email.FromName,
            options.Email.FromAddress,
            user.Id,
            user.Email);
    }

    private static string NormalizeWhatsAppTarget(string phone)
        => new string(phone.Where(char.IsDigit).ToArray());

    private static OtpDeliveryOptions BuildOptions(IConfiguration configuration)
    {
        return new OtpDeliveryOptions
        {
            WhatsApp = new WhatsAppDeliveryOptions
            {
                Enabled = bool.TryParse(configuration["OtpDelivery:WhatsApp:Enabled"], out var enabledWhatsApp) && enabledWhatsApp,
                SenderNumber = configuration["OtpDelivery:WhatsApp:SenderNumber"] ?? string.Empty,
                AccessToken = configuration["OtpDelivery:WhatsApp:AccessToken"] ?? string.Empty,
                PhoneNumberId = configuration["OtpDelivery:WhatsApp:PhoneNumberId"] ?? string.Empty,
                ApiVersion = configuration["OtpDelivery:WhatsApp:ApiVersion"] ?? "v22.0"
            },
            Email = new EmailDeliveryOptions
            {
                Enabled = bool.TryParse(configuration["OtpDelivery:Email:Enabled"], out var enabledEmail) && enabledEmail,
                FromAddress = configuration["OtpDelivery:Email:FromAddress"] ?? string.Empty,
                FromName = configuration["OtpDelivery:Email:FromName"] ?? "GoldWallet OTP",
                SmtpHost = configuration["OtpDelivery:Email:SmtpHost"] ?? string.Empty,
                SmtpPort = int.TryParse(configuration["OtpDelivery:Email:SmtpPort"], out var smtpPort) ? smtpPort : 587,
                UseSsl = !bool.TryParse(configuration["OtpDelivery:Email:UseSsl"], out var useSsl) || useSsl,
                Username = configuration["OtpDelivery:Email:Username"] ?? string.Empty,
                Password = configuration["OtpDelivery:Email:Password"] ?? string.Empty
            }
        };
    }
}
