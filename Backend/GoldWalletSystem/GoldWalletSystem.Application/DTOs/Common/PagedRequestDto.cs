namespace GoldWalletSystem.Application.DTOs.Common;

public class PagedRequestDto
{
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}

public class UserPagedRequestDto : PagedRequestDto
{
    public int UserId { get; set; }
}

public class UserRequestDto
{
    public int UserId { get; set; }
}
