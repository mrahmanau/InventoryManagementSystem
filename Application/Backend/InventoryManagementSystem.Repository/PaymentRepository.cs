using DAL;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Repository
{
    public class PaymentRepository : IPaymentRepository
    {
        public readonly DataAccess _db;

        public PaymentRepository(DataAccess db)
        {
            _db = db;
        }

        #region Public Methods
        public async Task<int> AddPaymentAsync(Payment payment)
        {
            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, payment.UserId),
                new Parm("@PaymentIntentId", SqlDbType.NVarChar, payment.PaymentIntentId, 50),
                new Parm("@Amount", SqlDbType.BigInt, payment.Amount),
                new Parm("@Currency", SqlDbType.NVarChar, payment.Currency, 10),
                new Parm("@Status", SqlDbType.NVarChar, payment.Status, 20),
                new Parm("@CreatedAt", SqlDbType.DateTime, payment.CreatedAt),
            };

            var paymentId = await _db.ExecuteScalarAsync<int>("spAddPayment", parms);
            return paymentId;
        }

        public async Task<Payment> GetPaymentByIntentIdAsync(string paymentIntentId)
        {
            var parms = new List<Parm>
            {
                new Parm("@PaymentIntentId", SqlDbType.NVarChar, paymentIntentId, 50),
            };

            var dt = await _db.ExecuteAsync("spGetPaymentByIntentId", parms);

            if (dt.Rows.Count == 0)
            {
                return null;
            }

            var row = dt.Rows[0];

            return new Payment
            {
                PaymentId = (int)row["PaymentId"],
                UserId = (int)row["UserId"],
                PaymentIntentId = row["PaymentIntentId"].ToString(),
                Amount = (long)row["Amount"],
                Currency = row["Currency"].ToString(),
                Status = row["Status"].ToString(),
                CreatedAt = (DateTime)row["CreatedAt"]
            };
        }

        public async Task UpdatePaymentAsync(Payment payment)
        {
            var parms = new List<Parm>
            {
                new Parm("@PaymentIntentId", SqlDbType.NVarChar, payment.PaymentIntentId, 50),
                new Parm("@Status", SqlDbType.NVarChar, payment.Status, 20),
            };

            await _db.ExecuteNonQueryAsync("spUpdatePayment", parms);
        }

        #endregion
    }
}
