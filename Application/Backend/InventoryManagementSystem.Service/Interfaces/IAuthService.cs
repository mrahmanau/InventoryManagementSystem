using InventoryManagementSystem.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public interface IAuthService
    {
        Task<RegisterResultDTO> RegisterAsync(UserRegistrationDTO userRegistrationDto);
        Task<User> LoginAsync(LoginDTO loginDTO);
    }
}
