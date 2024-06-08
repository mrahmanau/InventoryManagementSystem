using SendGrid;
using SendGrid.Helpers.Mail;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class EmailService : IEmailService
    {
        private readonly string _sendGridApiKey;

        public EmailService(string sendGridApiKey)
        {
            _sendGridApiKey = sendGridApiKey;
        }
        public async Task SendEmailConfirmationAsync(string email, string token)
        {
            var client = new SendGridClient(_sendGridApiKey);
            var from = new EmailAddress("rahman@mahfuzurr.com", "Inventory Manangement System");
            var subject = "Registration Confirmation";
            var to = new EmailAddress(email);
            var plainTextContent = $"Please confirm your email by clicking the following link: https://yourapp.com/confirm-email?token={token}";
            var htmlContent = $"<p>Please confirm your email by clicking the following link: <a href='https://yourapp.com/confirm-email?token={token}'>Confirm Email</a></p>";
            var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
            var response = await client.SendEmailAsync(msg);
        }
    }
}
