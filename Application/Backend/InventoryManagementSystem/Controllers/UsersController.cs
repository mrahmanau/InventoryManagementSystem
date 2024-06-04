using InventoryManagementSystem.Model;
using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace InventoryManagementSystem.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        // GET: api/user
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserDTO>>> GetUsersAsync()
        {
            try
            {
                var users = await _userService.GetUsersAsync();

                if (users == null || !users.Any())
                {
                    return NotFound("No users found.");
                }

                return Ok(users);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "An error occurred while fetching users.");
            }
        }
    }
}
