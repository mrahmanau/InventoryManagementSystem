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
        Task<string> ConfirmEmailAsync(string token);
        Task<UserDTO> VerifyTwoFactorCodeAsync(TwoFactorDTO twoFactorDTO);
        User MapUserDTOToUser(UserDTO userDto);
        UserDTO MapUserToUserDTO(User user);
        Task<bool> UpdatePasswordAsync(EditPasswordDTO editPasswordDTO);
        Task<bool> RequestPasswordResetAsync(string email);
        Task<bool> ResetPasswordAsync(ResetPasswordDTO resetPasswordDTO);


    }
}
