namespace GoldWalletSystem.Application.DTOs.Transactions;

public class TransactionHistoryFilterRequestDto
{
    public int UserId { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
    public string? TransactionType { get; set; }
    public DateTime? DateFromUtc { get; set; }
    public DateTime? DateToUtc { get; set; }
}
