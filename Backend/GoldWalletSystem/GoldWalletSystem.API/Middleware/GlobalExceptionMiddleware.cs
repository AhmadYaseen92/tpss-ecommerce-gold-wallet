using GoldWalletSystem.Application.DTOs.Common;
using System.Net;
using System.Text.Json;

namespace GoldWalletSystem.API.Middleware;

public class GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
{
    public async Task Invoke(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (UnauthorizedAccessException ex)
        {
            logger.LogWarning(ex, "Unauthorized request");
            await WriteError(
                context,
                HttpStatusCode.Unauthorized,
                userMessage: string.IsNullOrWhiteSpace(ex.Message) ? "You are not authorized to perform this action." : ex.Message,
                errorCode: "AUTH_UNAUTHORIZED",
                technicalMessage: ex.Message);
        }
        catch (InvalidOperationException ex)
        {
            logger.LogWarning(ex, "Invalid operation");
            await WriteError(
                context,
                HttpStatusCode.BadRequest,
                userMessage: ex.Message,
                errorCode: "INVALID_OPERATION",
                technicalMessage: ex.Message);
        }
        catch (BadHttpRequestException ex)
        {
            logger.LogWarning(ex, "Bad request");
            await WriteError(
                context,
                HttpStatusCode.BadRequest,
                userMessage: "Invalid request. Please review your input and try again.",
                errorCode: "BAD_REQUEST",
                technicalMessage: ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled error");
            await WriteError(
                context,
                HttpStatusCode.InternalServerError,
                userMessage: "Something went wrong on our side. Please try again shortly.",
                errorCode: "UNEXPECTED_ERROR",
                technicalMessage: ex.Message);
        }
    }

    private static Task WriteError(
        HttpContext context,
        HttpStatusCode code,
        string userMessage,
        string errorCode,
        string? technicalMessage = null)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)code;
        var payload = ApiResponse<object>.Fail(
            userMessage,
            (int)code,
            errorCode,
            technicalMessage ?? userMessage);
        return context.Response.WriteAsync(JsonSerializer.Serialize(payload));
    }
}
