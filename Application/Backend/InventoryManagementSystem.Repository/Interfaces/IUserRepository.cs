using InventoryManagementSystem.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Repository
{
    public interface IUserRepository
    {
        Task<User> GetUserByUsernameAsync(string username);
        Task<int> AddUserAsync(User user);
        Task<UserDTO> GetUserByIdAsync(int userId);
        Task<User> GetUserByUsernameAndPasswordAsync(string username, string hashedPassword);
        Task<IEnumerable<User>> GetUsersAsync();
        Task DeleteUserAsync(int userId);
        Task UpdateUserAsync(UserDTO user);
        Task AddLogAsync(UserActivityLogDTO log);
        Task<User> GetUserByTokenAsync(string token);
        Task UpdateEmailConfirmationStatusAsync(User user);
        Task UpdateTwoFactorCodeAsync(UserDTO user);
        Task ClearTwoFactorCodeAsync(int userId);
    }
}
