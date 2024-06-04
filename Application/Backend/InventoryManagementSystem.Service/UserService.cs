using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class UserService : IUserService
    {
        public readonly UserRepo repo = new();

        #region Public Methods
        public async Task<IEnumerable<UsersListDTO>> GetUsersAsync()
        {
            var users = await repo.GetUsersAsync();

            var usersDTO = users.Select(u => new UsersListDTO
            {
                UserId = u.UserId,
                FirstName = u.FirstName,
                LastName = u.LastName
            });

            return usersDTO;
        }
        #endregion
    }
}
