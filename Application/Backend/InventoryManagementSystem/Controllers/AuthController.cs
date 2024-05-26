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

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> RegisterAsync([FromBody] UserRegistrationDTO userRegistrationDTO)
        {
            try
            {
                var result = await _authService.RegisterAsync(userRegistrationDTO);
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
    }
}
