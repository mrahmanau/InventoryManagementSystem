using InventoryManagementSystem.Model;
using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

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

        //GET: api/user/5
        [HttpGet("{userId}")]
        public async Task<ActionResult<UserDTO>> GetUserByIdAsync(int userId)
        {
            try
            {
                var user = await _userService.GetUserByIdAsync(userId);

                if(user == null)
                {
                    return NotFound($"User with ID {userId} not found.");
                }

                return Ok(user);
            }
            catch(Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "Error retrieving data from the database");
            }
        }

        // DELETE: api/user/5
        [HttpDelete("{userId}")]
        public async Task<IActionResult> DeleteUserAsync(int userId)
        {
            try
            {
                await _userService.DeleteUserAsync(userId);
                return Ok("User deleted successfully");

            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "Error deleting the user from the database");
            }
        }

        // PUT: api/user/5
        [HttpPut("{userId}")]
        public async Task<IActionResult> UpdateUserAsync(int userId, [FromBody] UserDTO user)
        {
            if(userId != user.UserId)
            {
                return BadRequest("User Id mismatch");
            }

            var userToUpdate = new UserDTO
            {
                UserId = user.UserId,
                FirstName = user.FirstName,
                LastName = user.LastName,
                UserName = user.UserName,
                Email = user.Email,
                RoleId = user.RoleId
            };

            try
            {
                await _userService.UpdateUserAsync(userToUpdate);
                return Ok("User updated successfully");
            }
            catch (ArgumentException ex)
            {
                // Return a bad request response with the specific error message
                return BadRequest(ex.Message);
            }
            catch (SqlException ex) when (ex.Number == 2601)
            {
                // Log the exception details for debugging
                Console.WriteLine(ex.ToString());

                // Return a bad request response with the specific error message
                return BadRequest("The username is already taken.");
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "Error updating the user");
            }
        }

    }
}
