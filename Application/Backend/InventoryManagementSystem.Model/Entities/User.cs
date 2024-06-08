using InventoryManagementSystem.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Model
{
    public class User : BaseEntity
    {
        public int UserId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string HashedPassword { get; set; }
        public int RoleId { get; set; } // Foreign key to Role entity
        public Role Role { get; set; }  // Navigation property to Role entity
        public bool EmailConfirmed { get; set; } 
        public string EmailConfirmationToken { get; set; }

    }
}
