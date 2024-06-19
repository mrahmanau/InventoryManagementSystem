using InventoryManagementSystem.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Repository
{
    public interface IPaymentRepository
    {
        Task<int> AddPaymentAsync(Payment payment);
        Task UpdatePaymentAsync(Payment payment);
        Task<Payment> GetPaymentByIntentIdAsync(string paymentIntentId);
    }
}
