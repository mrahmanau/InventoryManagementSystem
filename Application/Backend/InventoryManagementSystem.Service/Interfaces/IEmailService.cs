using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{ 
    public interface IEmailService
    {
        Task SendEmailConfirmationAsync(string email, string token);
        Task SendTwoFactorCodeAsync(string email, string twoFactorCode);
    }
}
