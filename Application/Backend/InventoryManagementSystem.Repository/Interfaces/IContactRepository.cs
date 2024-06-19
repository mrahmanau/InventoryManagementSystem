using InventoryManagementSystem.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Repository
{
    public interface IContactRepository
    {
        Task<bool> AddContactAsync(Contact contact);
    }
}
