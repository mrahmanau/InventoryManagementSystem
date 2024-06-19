using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Mvc;
using Stripe;

namespace InventoryManagementSystem.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WebhookController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        private readonly ILogger<WebhookController> _logger;
        private readonly string _stripeWebhookSecret;

        public WebhookController(IPaymentService paymentService, ILogger<WebhookController> logger, IConfiguration configuration)
        {
            _paymentService = paymentService;
            _logger = logger;
            _stripeWebhookSecret = configuration["Stripe:WebhookSecret"];
        }

        [HttpPost]
        public async Task<IActionResult> Handle()
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
            _logger.LogInformation("Received webhook event: {Json}", json);


            try
            {
                var stripeSignature = Request.Headers["Stripe-Signature"];
                _logger.LogInformation("Stripe-Signature: {StripeSignature}", stripeSignature);

                var stripeEvent = EventUtility.ConstructEvent(
                    json,
                    stripeSignature,
                    _stripeWebhookSecret
                );

                if (stripeEvent.Type == Events.PaymentIntentSucceeded)
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    _logger.LogInformation($"PaymentIntent succeeded: {paymentIntent.Id}");

                    // Update payment status in the database
                    await _paymentService.UpdatePaymentStatusAsync(paymentIntent.Id, paymentIntent.Status);
                }
                else if (stripeEvent.Type == Events.PaymentIntentPaymentFailed)
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    _logger.LogInformation($"PaymentIntent failed: {paymentIntent.Id}");

                    // Update payment status in the database
                    await _paymentService.UpdatePaymentStatusAsync(paymentIntent.Id, paymentIntent.Status);
                }

                return Ok();
            }
            catch (StripeException e)
            {
                _logger.LogError(e, "Stripe webhook error");
                return BadRequest();
            }
        }
    }
}
