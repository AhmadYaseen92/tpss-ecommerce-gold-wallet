namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IWalletActionValidationService
{
    string? ValidateExecuteActionRequest(string actionType, string? notes);
}
