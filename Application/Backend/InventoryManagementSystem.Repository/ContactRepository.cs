using DAL;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Repository
{
    public class ContactRepository : IContactRepository
    {
        private readonly DataAccess _db;

        public ContactRepository(DataAccess db)
        {
            _db = db;
        }

        #region Public Methods
        public async Task<bool> AddContactAsync(Contact contact)
        {
            try
            {
                var parms = new List<Parm>
                {
                    new Parm("@Name", SqlDbType.NVarChar, contact.Name, 100),
                    new Parm("@Email", SqlDbType.NVarChar, contact.Email, 100),
                    new Parm("@Subject", SqlDbType.NVarChar, contact.Subject, 200),
                    new Parm("@Message", SqlDbType.NVarChar, contact.Message)
                };

                var result = await _db.ExecuteNonQueryAsync("spAddContact", parms);
                return result > 0;
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
