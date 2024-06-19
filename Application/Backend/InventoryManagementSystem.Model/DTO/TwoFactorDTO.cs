using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Model
{
    public class TwoFactorDTO
    {
        public int UserId { get; set; }
        public string TwoFactorCode { get; set; }
    }

}
