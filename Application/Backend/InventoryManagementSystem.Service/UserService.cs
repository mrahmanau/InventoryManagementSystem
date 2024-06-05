﻿using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static InventoryManagementSystem.Repository.UserRepo;

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

        public async Task<UserDTO> GetUserByIdAsync(int userId)
        {
            try
            {
                var user = await repo.GetUserByIdAsync(userId);

                if(user == null)
                {
                    return null;
                }

                return new UserDTO
                {
                    UserId = user.UserId,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    UserName = user.Username,
                    Email = user.Email,
                    RoleId = user.RoleId,
                    RoleName = user.Role.RoleName
                };

            }
            catch(Exception ex)
            {
                throw new Exception("An error occurred while retrieving the user details.", ex);
            }
        }

        public async Task DeleteUserAsync(int userId)
        {
            try
            {
                await repo.DeleteUserAsync(userId);
            }
            catch(RepositoryException ex)
            {
                throw new ArgumentException(ex.Message, ex);
            }
            catch(Exception ex)
            {
                throw new Exception("An error occurred while deleting the user", ex);
            }
        }

        public async Task UpdateUserAsync(UserDTO user)
        {
            try
            {
                await repo.UpdateUserAsync(user);
            }
            catch(RepositoryException ex)
            {
                throw new ArgumentException(ex.Message, ex);
            }
            catch(Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        #endregion
    }
}
