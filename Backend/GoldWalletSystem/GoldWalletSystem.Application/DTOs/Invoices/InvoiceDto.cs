namespace GoldWalletSystem.Application.DTOs.Invoices;

public sealed record InvoiceDto(int Id, int UserId, string InvoiceNumber, decimal SubTotal, decimal TaxAmount, decimal TotalAmount, string Status, DateTime IssuedOnUtc);
