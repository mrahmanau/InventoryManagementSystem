using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Model
{
    public class LoginOutputDTO
    {
        public int? UserId { get; set; }
        public string? Token { get; set; }
        public int ExpiresIn { get; set; }

        public string? Message { get; set; } 
        public bool RequiresTwoFactor { get; set; }
    }
}
