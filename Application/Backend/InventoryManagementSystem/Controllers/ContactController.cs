using InventoryManagementSystem.Model;
using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Mvc;

namespace InventoryManagementSystem.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ContactController : ControllerBase
    {
        private readonly IContactService _contactService;

        public ContactController (IContactService contactService)
        {
            _contactService = contactService;
        }

        [HttpPost("contact")]
        public async Task<IActionResult> ContactAsync([FromBody] ContactDTO contactDTO)
        {
            try
            {
                var contact = new Contact
                {
                    Name = contactDTO.Name,
                    Email = contactDTO.Email,
                    Subject = contactDTO.Subject,
                    Message = contactDTO.Message,
                    CreatedAt = DateTime.UtcNow
                };

                var result = await _contactService.AddContactAsync(contact);
                if (result)
                {
                    return Ok(new { Message = "Contact message received successfully." });
                }
                else
                {
                    return BadRequest(new { Message = "Failed to receive contact message." });
                }
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }
    }
}
