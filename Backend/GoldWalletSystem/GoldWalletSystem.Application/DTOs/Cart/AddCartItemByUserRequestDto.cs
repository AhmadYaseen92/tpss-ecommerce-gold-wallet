namespace GoldWalletSystem.Application.DTOs.Cart;

public class AddCartItemByUserRequestDto
{
    public int UserId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}
