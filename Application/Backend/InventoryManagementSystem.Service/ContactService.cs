using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class ContactService : IContactService
    {
        private readonly IContactRepository _contactRepository;

        public ContactService (IContactRepository contactRepository)
        {
            _contactRepository = contactRepository;
        }

        #region Public Methods
        public async Task<bool> AddContactAsync(Contact contact)
        {
            try
            {
                return await _contactRepository.AddContactAsync(contact);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred while adding a contact: {ex.Message}");
                return false;
            }
        }
        #endregion
    }
}
