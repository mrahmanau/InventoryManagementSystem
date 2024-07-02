using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using InventoryManagementSystem.Types;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InventoryManagementSystem.Service
{
    public class AuthService : IAuthService
    {
        public readonly IUserRepository _repo;
        private readonly IEmailService _emailService;

        public AuthService(IUserRepository repo, IEmailService emailService)
        {
            _repo = repo;
            _emailService = emailService;
        }



        #region Public Methods
        public async Task<RegisterResultDTO> RegisterAsync(UserRegistrationDTO userRegistrationDTO)
        {
            try
            {
                var validationErrors = ValidateUserRegistration(userRegistrationDTO);

                if (validationErrors.Any())
                {
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
                    EmailConfirmationToken = GenerateEmailConfirmationToken(),
                    ProfileImagePath = userRegistrationDTO.ProfileImagePath,
                };

                // Add user to the repository and get the new user's ID
                var userId = await _repo.AddUserAsync(user);

                await _emailService.SendEmailConfirmationAsync(user.Email, user.EmailConfirmationToken);

                return new RegisterResultDTO
                {
                    UserId = userId,
                    Message = "A confirmation link has been sent to your email. Please confirm your account by clicking the link.",
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

        public async Task<string> ConfirmEmailAsync(string token)
        {
            try
            {
                var user = await _repo.GetUserByTokenAsync(token);

                if (user == null || user.EmailConfirmed)
                {
                    return "Invalid or expired token.";
                }

                user.EmailConfirmed = true;
                user.EmailConfirmationToken = null;

                await _repo.UpdateEmailConfirmationStatusAsync(user);

                return "Email confirmed successfully.";
            }
            catch(Exception ex)
            {
                throw new ApplicationException("An error occurred while confirming the email.", ex);

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

            if(!user.EmailConfirmed)
            {
                throw new Exception("Email not confirmed. Please check your email for a confirmation link.");
            }

            // Generate 2FA code
            var twoFactorCode = GenerateTwoFactorCode();
            user.TwoFactorCode = twoFactorCode;
            user.TwoFactorCodeExpiration = DateTime.UtcNow.AddMinutes(30);

            // Convert User to UserDTO
            var userDto = MapUserToUserDTO(user);

            // Save 2FA code to the database
            await _repo.UpdateTwoFactorCodeAsync(userDto);

            // Send 2FA code to user's email
            await _emailService.SendTwoFactorCodeAsync(user.Email, twoFactorCode);

            return user;
        }

        public async Task<UserDTO> VerifyTwoFactorCodeAsync(TwoFactorDTO twoFactorDto)
        {
            var user = await _repo.GetUserByIdAsync(twoFactorDto.UserId);

            if (user == null)
            {
                throw new Exception("Invalid or expired 2FA code.");
            }

            // Log the retrieved values
            Console.WriteLine($"Retrieved TwoFactorCode: {user.TwoFactorCode}");
            Console.WriteLine($"Provided TwoFactorCode: {twoFactorDto.TwoFactorCode}");
            Console.WriteLine($"TwoFactorCodeExpiration: {user.TwoFactorCodeExpiration}");
            Console.WriteLine($"Current UTC Time: {DateTime.UtcNow}");

            if (user.TwoFactorCode != twoFactorDto.TwoFactorCode || user.TwoFactorCodeExpiration < DateTime.UtcNow)
            {
                throw new Exception("Invalid or expired 2FA code.");
            }
            await _repo.ClearTwoFactorCodeAsync(user.UserId);

            return user;
        }

        public async Task<bool> UpdatePasswordAsync(EditPasswordDTO editPasswordDTO)
        {
            var user = await _repo.GetUserByIdAsync(editPasswordDTO.UserId);

            if (user == null)
            {
                throw new Exception("User not found.");
            }

            var hashedCurrentPassword = HashPassword(editPasswordDTO.CurrentPassword);
            var currentHashedPassword = await _repo.GetHashedPasswordAsync(editPasswordDTO.UserId);

            if (currentHashedPassword != hashedCurrentPassword)
            {
                throw new Exception("Current password is incorrect.");
            }

            var passwordErrors = GetPasswordComplexityErrors(editPasswordDTO.NewPassword);
            if (passwordErrors.Any())
            {
                throw new ValidationException(string.Join(" ", passwordErrors));
            }

            var hashedNewPassword = HashPassword(editPasswordDTO.NewPassword);
            return await _repo.UpdatePasswordAsync(editPasswordDTO.UserId, hashedNewPassword);
        }

        public async Task<bool> RequestPasswordResetAsync(string email)
        {
            var user = await _repo.GetUserByEmailAsync(email);

            if (user == null)
            {
                throw new Exception("User not found.");
            }

            var resetToken = await _repo.GeneratePasswordResetTokenAsync(user.UserId);

            await _emailService.RequestPasswordResetAsync(user.Email, resetToken, user.FirstName);

            return true;
        }

        public async Task<bool> ResetPasswordAsync(ResetPasswordDTO resetPasswordDTO)
        {
            var user = await _repo.GetUserByResetTokenAsync(resetPasswordDTO.Token);

            if (user == null)
            {
                throw new Exception("Invalid or expired password reset token.");
            }

            var passwordErrors = GetPasswordComplexityErrors(resetPasswordDTO.NewPassword);
            if (passwordErrors.Any())
            {
                throw new ValidationException(string.Join(" ", passwordErrors));
            }

            var hashedNewPassword = HashPassword(resetPasswordDTO.NewPassword);
            return await _repo.UpdatePasswordAsync(user.UserId, hashedNewPassword);
        }


        public class UserAlreadyExistsException : Exception
        {
            public UserAlreadyExistsException(string message) : base(message)
            {
            }
        }

        #endregion

        #region Private Methods

        private List<string> GetPasswordComplexityErrors(string password)
        {
            var errors = new List<string>();

            if (password.Length < 8)
            {
                errors.Add("Password must be at least 8 characters long.");
            }

            if (!Regex.IsMatch(password, @"[A-Z]"))
            {
                errors.Add("At least one uppercase letter is required.");
            }

            if (!Regex.IsMatch(password, @"[a-z]"))
            {
                errors.Add("At least one lowercase letter is required.");
            }

            if (!Regex.IsMatch(password, @"[0-9]"))
            {
                errors.Add("At least one number is required.");
            }

            if (!Regex.IsMatch(password, @"[\W]"))
            {
                errors.Add("At least one special character is required.");
            }

            return errors;
        }


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

        private string GenerateTwoFactorCode()
        {
            var random = new Random();
            return random.Next(100000, 999999).ToString();
        }

        public User MapUserDTOToUser(UserDTO userDto)
        {
            return new User
            {
                UserId = userDto.UserId,
                FirstName = userDto.FirstName,
                LastName = userDto.LastName,
                Username = userDto.UserName,
                Email = userDto.Email,
                RoleId = userDto.RoleId,
                TwoFactorCode = userDto.TwoFactorCode,
                TwoFactorCodeExpiration = userDto.TwoFactorCodeExpiration,
                Role = new Role
                {
                    RoleId = userDto.RoleId,
                    RoleName = userDto.RoleName
                }
            };
        }

        public UserDTO MapUserToUserDTO(User user)
        {
            return new UserDTO
            {
                UserId = user.UserId,
                FirstName = user.FirstName,
                LastName = user.LastName,
                UserName = user.Username,
                Email = user.Email,
                RoleId = user.RoleId,
                RoleName = user.Role?.RoleName,
                TwoFactorCode = user.TwoFactorCode,
                TwoFactorCodeExpiration = user.TwoFactorCodeExpiration
            };
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
