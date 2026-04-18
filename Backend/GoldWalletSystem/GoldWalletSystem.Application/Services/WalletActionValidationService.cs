using System.Globalization;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public sealed class WalletActionValidationService : IWalletActionValidationService
{
    private static readonly string[] PickupScheduleFormats =
    {
        "ddd, dd MMM yyyy h:mm tt",
        "ddd, d MMM yyyy h:mm tt",
        "dd MMM yyyy h:mm tt",
        "d MMM yyyy h:mm tt"
    };

    public string? ValidateExecuteActionRequest(string actionType, string? notes)
    {
        if (!string.Equals(actionType, "pickup", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        var scheduleText = ExtractPickupSchedule(notes);
        if (string.IsNullOrWhiteSpace(scheduleText))
        {
            return "Pickup schedule is required for pickup requests.";
        }

        if (!TryParsePickupSchedule(scheduleText, out var pickupDateTime))
        {
            return "Pickup schedule is invalid. Please select a valid pickup date and time.";
        }

        if (pickupDateTime <= DateTime.UtcNow)
        {
            return "Pickup schedule must be in the future.";
        }

        return null;
    }

    private static string? ExtractPickupSchedule(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes))
        {
            return null;
        }

        const string marker = "pickup_schedule=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0)
        {
            return null;
        }

        var start = markerIndex + marker.Length;
        if (start >= notes.Length)
        {
            return null;
        }

        var end = notes.IndexOf('|', start);
        var value = end < 0 ? notes[start..] : notes[start..end];
        return value.Trim();
    }

    private static bool TryParsePickupSchedule(string scheduleText, out DateTime pickupDateTime)
    {
        if (DateTime.TryParseExact(
                scheduleText,
                PickupScheduleFormats,
                CultureInfo.InvariantCulture,
                DateTimeStyles.AllowWhiteSpaces | DateTimeStyles.AssumeLocal,
                out pickupDateTime))
        {
            pickupDateTime = pickupDateTime.ToUniversalTime();
            return true;
        }

        if (DateTime.TryParse(
                scheduleText,
                CultureInfo.InvariantCulture,
                DateTimeStyles.AllowWhiteSpaces | DateTimeStyles.AssumeLocal,
                out pickupDateTime))
        {
            pickupDateTime = pickupDateTime.ToUniversalTime();
            return true;
        }

        return false;
    }
}
