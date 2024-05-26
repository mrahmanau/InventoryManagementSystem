using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class AuthService : IAuthService
    {
        public readonly UserRepo repo = new();

        #region Public Methods
        public async Task<string> RegisterAsync(UserRegistrationDTO userRegistrationDTO)
        {
            try
            {
                // Check if user already exists
                var existingUser = await repo.GetUserByUsernameAsync(userRegistrationDTO.Username);
                if (existingUser != null)
                {
                    throw new UserAlreadyExistsException("User already exists.");
                }

                // Create new user

                var user = new User
                {
                    FirstName = userRegistrationDTO.FirstName,
                    LastName = userRegistrationDTO.LastName,
                    Username = userRegistrationDTO.Username,
                    Email = userRegistrationDTO.Email,
                    HashedPassword = HashPassword(userRegistrationDTO.Password),
                    RoleId = userRegistrationDTO.RoleId,
                };

                // Add user to the repository
                await repo.AddUserAsync(user);

                return "User registered successfully";
            }
            catch(UserAlreadyExistsException ex)
            {
                throw ex;
            }
            catch(Exception ex)
            {
                throw new ApplicationException("An error occurred while registering the user to the database.", ex);
            }
        }

        public class UserAlreadyExistsException : Exception
        {
            public UserAlreadyExistsException(string message) : base(message) { }
        }
        #endregion

        #region Private Methods
        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));

                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    builder.Append(hashBytes[i].ToString("x2"));
                }

                return builder.ToString();
            }
        }
        #endregion
    }
}
