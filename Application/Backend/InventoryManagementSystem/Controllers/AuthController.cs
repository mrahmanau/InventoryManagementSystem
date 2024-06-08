using InventoryManagementSystem.Interfaces;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Mvc;
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

        public AuthController(IAuthService authService, ITokenService tokenService, IUserService userService)
        {
            _authService = authService;
            _tokenService = tokenService;
            _userService = userService;
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

                return Ok(new { message = result });
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

        [HttpPost("login")]
        public async Task<ActionResult<LoginOutputDTO>> LoginAsync([FromBody] LoginDTO loginDTO)
        {
            try
            {
                var user = await _authService.LoginAsync(loginDTO);
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
                    ExpiresIn = 7 * 24 * 60 * 60 // Token expiration time in seconds (7 days)
                };
            }
            catch(Exception ex)
            {
                return Unauthorized(new {message = ex.Message});
            }
        }
    }
}
