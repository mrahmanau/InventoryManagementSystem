using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using Microsoft.Extensions.Options;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class PaymentService : IPaymentService
    {
        private readonly StripeSettings _stripeSettings;
        private readonly IPaymentRepository _paymentRepository;

        public PaymentService(IOptions<StripeSettings> stripeOptions, IPaymentRepository paymentRepository)
        {
            _stripeSettings = stripeOptions.Value;
            StripeConfiguration.ApiKey = _stripeSettings.SecretKey;
            _paymentRepository = paymentRepository;
        }

        public async Task<PaymentIntent> CreatePaymentIntentAsync(int userId, long amount)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = amount,
                Currency = "usd",
                PaymentMethodTypes = new List<string> { "card"},
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            // Save the payment intent to the database
            var payment = new Payment
            {
                UserId = userId,
                PaymentIntentId = paymentIntent.Id,
                Amount = amount,
                Currency = "usd",
                Status = paymentIntent.Status,
                CreatedAt = DateTime.UtcNow,
            };

            await _paymentRepository.AddPaymentAsync(payment);

            return paymentIntent;
        }

        public async Task UpdatePaymentStatusAsync(string paymentIntentId, string status)
        {
            var payment = await _paymentRepository.GetPaymentByIntentIdAsync(paymentIntentId);
            if (payment != null)
            {
                payment.Status = status;
                await _paymentRepository.UpdatePaymentAsync(payment);
            }
        }

    }
}
