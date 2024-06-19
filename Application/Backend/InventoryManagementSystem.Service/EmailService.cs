using Microsoft.Extensions.Logging;
using SendGrid;
using SendGrid.Helpers.Mail;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class EmailService : IEmailService
    {
        private readonly string _sendGridApiKey;
        private readonly string _baseUrl;
        private readonly ILogger<EmailService> _logger;

        public EmailService(string sendGridApiKey, string baseUrl, ILogger<EmailService> logger)
        {
            _sendGridApiKey = sendGridApiKey;
            _baseUrl = baseUrl;
            _logger = logger;
        }
        public async Task SendEmailConfirmationAsync(string email, string token)
        {
            var client = new SendGridClient(_sendGridApiKey);
            var from = new EmailAddress("admin@mahfuzurr.com", "Inventory Manangement System");
            var subject = "Registration Confirmation";
            var to = new EmailAddress(email);
            var encodedToken = WebUtility.UrlEncode(token);
            var confirmationLink = $"{_baseUrl}/confirm-email?token={encodedToken}";
            var plainTextContent = $"Please confirm your email by clicking the following link: {confirmationLink}";
            var htmlContent = $"<p>Please confirm your email by clicking the following link: <a href='{confirmationLink}'>Confirm Email</a></p>";
            var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
            //var response = await client.SendEmailAsync(msg);
            try
            {
                var response = await client.SendEmailAsync(msg);
                _logger.LogInformation("Email sent. Status code: {StatusCode}", response.StatusCode);

                if (response.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    string responseBody = await response.Body.ReadAsStringAsync();
                    _logger.LogError("SendGrid response error: {ResponseBody}", responseBody);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending email");
                throw;
            }
        }

        public async Task SendTwoFactorCodeAsync(string email, string twoFactorCode)
        {
            var client = new SendGridClient(_sendGridApiKey);
            var from = new EmailAddress("admin@mahfuzurr.com", "Inventory Management System");
            var subject = "Your Two-Factor Authentication Code";
            var to = new EmailAddress (email);
            var plainTextContent = $"Your two-factor authentication code is: {twoFactorCode}";
            var htmlContent = $"<p>Your two-factor authentication code is: <strong>{twoFactorCode}</strong></p>";
            var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
            try
            {
                var response = await client.SendEmailAsync(msg);
                _logger.LogInformation("Email sent. Status code: {StatusCode}", response.StatusCode);

                if (response.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    string responseBody = await response.Body.ReadAsStringAsync();
                    _logger.LogError("SendGrid response error: {ResponseBody}", responseBody);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending email");
                throw;
            }
        }
    }
}
