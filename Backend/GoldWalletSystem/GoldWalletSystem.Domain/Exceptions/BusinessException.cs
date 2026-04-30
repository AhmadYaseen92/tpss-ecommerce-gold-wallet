namespace GoldWalletSystem.Domain.Exceptions;

public class BusinessException : Exception
{
    public BusinessException(string errorCode, string safeMessage, int statusCode = 400, string? technicalMessage = null)
        : base(technicalMessage ?? safeMessage)
    {
        ErrorCode = errorCode;
        SafeMessage = safeMessage;
        StatusCode = statusCode;
    }

    public string ErrorCode { get; }
    public string SafeMessage { get; }
    public int StatusCode { get; }
}
