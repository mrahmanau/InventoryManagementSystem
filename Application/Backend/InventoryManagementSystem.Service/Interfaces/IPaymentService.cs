using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public interface IPaymentService
    {
        Task<PaymentIntent> CreatePaymentIntentAsync(int userId, long amount);
        Task UpdatePaymentStatusAsync(string paymentIntentId, string status);
    }
}
