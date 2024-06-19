using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Mvc;

namespace InventoryManagementSystem.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost("create-payment-intent")]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request)
        {
            try
            {
                var paymentIntent = await _paymentService.CreatePaymentIntentAsync(request.UserId, request.Amount);
                return Ok(new { paymentIntent.Id, paymentIntent.ClientSecret });
            }
            catch(Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        public class CreatePaymentIntentRequest
        {
            public int UserId { get; set; }
            public long Amount { get; set; }    
        }
    }
}
