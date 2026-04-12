namespace GoldWalletSystem.Application.DTOs.Common;

public class ApiResponse<T>
{
    public bool Success { get; init; }
    public int StatusCode { get; init; }
    public string Message { get; init; } = string.Empty;
    public string? ErrorCode { get; init; }
    public T? Data { get; init; }
    public IReadOnlyList<string> Errors { get; init; } = [];

    public static ApiResponse<T> Ok(T data, string message = "Success", int statusCode = 200)
        => new() { Success = true, StatusCode = statusCode, Message = message, Data = data };

    public static ApiResponse<T> Fail(string message, int statusCode, string? errorCode = null, params string[] errors)
        => new() { Success = false, StatusCode = statusCode, Message = message, ErrorCode = errorCode, Errors = errors };
}
