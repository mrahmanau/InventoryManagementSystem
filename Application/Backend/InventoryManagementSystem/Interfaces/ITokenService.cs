using InventoryManagementSystem.Model;

namespace InventoryManagementSystem.Interfaces
{
    public interface ITokenService
    {
        string GenerateJwtToken(User user);
    }
}
