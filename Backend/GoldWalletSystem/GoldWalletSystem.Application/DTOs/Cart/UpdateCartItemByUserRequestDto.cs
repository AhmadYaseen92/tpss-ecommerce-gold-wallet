namespace GoldWalletSystem.Application.DTOs.Cart;

public class UpdateCartItemByUserRequestDto
{
    public int UserId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}
