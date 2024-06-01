using InventoryManagementSystem.Interfaces;
using InventoryManagementSystem.Model;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace InventoryManagementSystem.Services
{
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _configuration;

        public TokenService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GenerateJwtToken(User user)
        {
            // Check if Jwt:Key is null or empty
            string? jwtKey = _configuration["Jwt:Key"];

            if(string.IsNullOrEmpty(jwtKey))
            {
                throw new InvalidOperationException("Jwt:Key is not configured");
            }

            SymmetricSecurityKey key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

            List<Claim> claims = new List<Claim>()
            {
                new Claim(JwtRegisteredClaimNames.UniqueName, user.UserId != null ? user.UserId.ToString() : ""),
                new Claim(JwtRegisteredClaimNames.Sub, user.UserId.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role.RoleName),
                new Claim("FirstName", user.FirstName),
                new Claim("LastName", user.LastName),
                new Claim(ClaimTypes.Email, user.Email),

            };

            // Create new credentials for signing the token
            SigningCredentials creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            // Describe the token. What goes inside
            SecurityTokenDescriptor tokenDescriptor = new SecurityTokenDescriptor()
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.Now.AddDays(7),
                SigningCredentials = creds
            };

            // Create a new token handler
            JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();

            // Create the token
            SecurityToken token = tokenHandler.CreateToken(tokenDescriptor);

            // Write the token and return
            return tokenHandler.WriteToken(token);
        }
    }
}
