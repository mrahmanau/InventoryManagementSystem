using InventoryManagementSystem.Interfaces;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using System.Net;
using static InventoryManagementSystem.Service.AuthService;

namespace InventoryManagementSystem.Controllers
{
    [Microsoft.AspNetCore.Mvc.Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ITokenService _tokenService;
        private readonly IUserService _userService;
        private readonly IImageService _imageService;

        public AuthController(IAuthService authService, ITokenService tokenService, IUserService userService, IImageService imageService)
        {
            _authService = authService;
            _tokenService = tokenService;
            _userService = userService;
            _imageService = imageService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> RegisterAsync([FromBody] UserRegistrationDTO userRegistrationDTO)
        {
            try
            {
                var result = await _authService.RegisterAsync(userRegistrationDTO);

                // Log the registration action
                var log = new UserActivityLogDTO
                {
                    UserId = result.UserId,
                    Action = "Register",
                    Timestamp = DateTime.UtcNow,
                    Details = "User registered successfully"
                };

                await _userService.AddLogAsync(log);

                return Ok(result);
            }
            catch (UserAlreadyExistsException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("confirm-email")]
        public async Task<IActionResult> ConfirmEmail(string token)
        {
            try
            {
                var decodedToken = WebUtility.UrlDecode(token);
                var result = await _authService.ConfirmEmailAsync(decodedToken);

                if (result == "Invalid or expired token.")
                {
                    return BadRequest(result);
                }

                return Ok(result);
            }
            catch(ApplicationException ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPost("login")]
        public async Task<ActionResult<LoginOutputDTO>> LoginAsync([FromBody] LoginDTO loginDTO)
        {
            try
            {
                var user = await _authService.LoginAsync(loginDTO);

                if(user.TwoFactorCode != null)
                {
                    return Ok(new LoginOutputDTO
                    {
                        UserId = user.UserId,
                        RequiresTwoFactor = true,
                        Message = "2FA code sent to your email."
                    });
                }

                var token = _tokenService.GenerateJwtToken(user);

                // Log the login action
                var log = new UserActivityLogDTO
                {
                    UserId = user.UserId,
                    Action = "Login",
                    Timestamp = DateTime.UtcNow,
                    Details = "User logged in"
                };

                await _userService.AddLogAsync(log);

                return new LoginOutputDTO
                {
                    UserId = user.UserId,
                    Token = token,
                    ExpiresIn = 7 * 24 * 60 * 60,
                    RequiresTwoFactor = false
                };
            }
            catch(Exception ex)
            {
                return Unauthorized(new {message = ex.Message});
            }
        }

        [HttpPost("verify-2fa")]
        public async Task<ActionResult<LoginOutputDTO>> VerifyTwoFactorCode([FromBody] TwoFactorDTO twoFactorDto)
        {
            try
            {
                var userDto = await _authService.VerifyTwoFactorCodeAsync(twoFactorDto);
                var user = _authService.MapUserDTOToUser(userDto); // Ensure this method is public in AuthService
                var token = _tokenService.GenerateJwtToken(user);

                return new LoginOutputDTO
                {
                    UserId = user.UserId,
                    Token = token,
                    ExpiresIn = 7 * 24 * 60 * 60 // Token expiration time in seconds (7 days)
                };
            }
            catch (Exception ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("upload-profile-image")]
        public async Task<IActionResult> UploadProfileImage(IFormFile file)
        {
            try
            {
                var filePath = await _imageService.UploadProfileImageAsync(file);
                return Ok(new { filePath });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (ApplicationException ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An unexpected error occurred. Please try again later." });
            }
        }

        [HttpPost("update-password")]
        public async Task<IActionResult> UpdatePassword([FromBody] EditPasswordDTO editPasswordDTO)
        {
            try
            {
                var result = await _authService.UpdatePasswordAsync(editPasswordDTO);

                if (!result)
                {
                    return BadRequest(new { message = "Password update failed." });
                }

                return Ok(new { message = "Password updated successfully." });
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { errors = ex.Message.Split('.').Where(m => !string.IsNullOrEmpty(m)).Select(m => m.Trim()).ToList() });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("request-password-reset")]
        public async Task<IActionResult> RequestPasswordReset([FromBody] ForgotPasswordDTO forgotPasswordDTO)
        {
            try
            {
                var result = await _authService.RequestPasswordResetAsync(forgotPasswordDTO.Email);

                if (!result)
                {
                    return BadRequest(new { message = "Password reset request failed." });
                }

                return Ok(new { message = "You should soon receive an email allowing you to reset your password. Please make sure to check your spam and trash if you can't find the email." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDTO resetPasswordDTO)
        {
            try
            {
                if (resetPasswordDTO.NewPassword != resetPasswordDTO.ConfirmPassword)
                {
                    return BadRequest(new { message = "Password and Confirm Password do not match." });
                }

                var result = await _authService.ResetPasswordAsync(resetPasswordDTO);

                if (!result)
                {
                    return BadRequest(new { message = "Password reset failed." });
                }

                return Ok(new { message = "Password reset successfully." });
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { errors = ex.Message.Split('.').Where(m => !string.IsNullOrEmpty(m)).Select(m => m.Trim()).ToList() });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }



    }
}
