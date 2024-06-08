using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using InventoryManagementSystem.Types;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InventoryManagementSystem.Service
{
    public class AuthService : IAuthService
    {
        public readonly UserRepo _repo;
        private readonly IEmailService _emailService;

        public AuthService(UserRepo repo, IEmailService emailService)
        {
            _repo = repo;
            _emailService = emailService;
        }



        #region Public Methods
        public async Task<RegisterResultDTO> RegisterAsync(UserRegistrationDTO userRegistrationDTO)
        {
            try
            {
                // Validate the user registration DTO
                var validationErrors = ValidateUserRegistration(userRegistrationDTO);

                if (validationErrors.Any())
                {
                    // If there are validation errors, return the errors as a string
                    //return string.Join(", ", validationErrors.Select(error => error.Description));
                   throw new ValidationException(string.Join(", ", validationErrors.Select(error => error.Description)));
                }

                // Check if user already exists
                var existingUser = await _repo.GetUserByUsernameAsync(userRegistrationDTO.Username);
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
                    EmailConfirmed = false,
                    EmailConfirmationToken = GenerateEmailConfirmationToken()
                };

                // Add user to the repository and get the new user's ID
                var userId = await _repo.AddUserAsync(user);

                await _emailService.SendEmailConfirmationAsync(user.Email, user.EmailConfirmationToken);

                return new RegisterResultDTO
                {
                    UserId = userId,
                    Message = "User registered successfully",
                };
            }
            catch(UserAlreadyExistsException ex)
            {
                throw ex;
            }
            catch(ValidationException ex)
            {
                throw ex;
            }
            catch(Exception ex)
            {
                throw new ApplicationException("An error occurred while registering the user to the database.", ex);
            }
        }

        public async Task<User> LoginAsync(LoginDTO loginDTO)
        {
            var hashedPassword = HashPassword(loginDTO.Password);

            var user = await _repo.GetUserByUsernameAndPasswordAsync(loginDTO.Username, hashedPassword);
            if (user == null)
            {
                throw new Exception("Invalid username or password.");
            }

            return user;
        }

        public class UserAlreadyExistsException : Exception
        {
            public UserAlreadyExistsException(string message) : base(message)
            {
            }
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

        private string GenerateEmailConfirmationToken()
        {
            using(var rng = new RNGCryptoServiceProvider())
            {
                var tokenData = new byte[32];
                rng.GetBytes(tokenData);
                return Convert.ToBase64String(tokenData);
            }
        }

        private List<ValidationError> ValidateUserRegistration(UserRegistrationDTO userRegistrationDTO)
        {
            var errors = new List<ValidationError>();

            // Validate first name
            if(string.IsNullOrWhiteSpace(userRegistrationDTO.FirstName))
            {
                errors.Add(new ValidationError("First name is required.", ErrorType.Model));
            }
            else if(userRegistrationDTO.FirstName.Length < 2)
            {
                errors.Add(new ValidationError("First name cannot be less than 2 characters.", ErrorType.Model));
            }

            // Validate last name
            if(string.IsNullOrEmpty(userRegistrationDTO.LastName))
            {
                errors.Add(new ValidationError("Last name is required.", ErrorType.Model));
            }
            else if(userRegistrationDTO.LastName.Length < 3)
            {
                errors.Add(new ValidationError("Last name cannot be less than 3 characters.", ErrorType.Model));
            }

            // Validate username
            if(string.IsNullOrEmpty(userRegistrationDTO.Username))
            {
                errors.Add(new ValidationError("User name is required", ErrorType.Model));
            }
            else if(userRegistrationDTO.Username.Length < 4)
            {
                errors.Add(new ValidationError("Username cannot be less than 4 characters", ErrorType.Model));
            }

            return errors;
        }

        #endregion
    }
}
