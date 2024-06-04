using InventoryManagementSystem.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public interface IUserService
    {
        Task<IEnumerable<UsersListDTO>> GetUsersAsync();
    }
}
