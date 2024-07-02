using InventoryManagementSystem.Model;
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
        //public readonly UserRepo repo = new();
        public readonly IUserRepository _repo;
        public UserService (IUserRepository repo)
        {
            _repo = repo;
        }

        #region Public Methods
        public async Task<IEnumerable<UsersListDTO>> GetUsersAsync()
        {
            var users = await _repo.GetUsersAsync();

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
                var user = await _repo.GetUserByIdAsync(userId);

                if(user == null)
                {
                    return null;
                }

                return new UserDTO
                {
                    UserId = user.UserId,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    UserName = user.UserName,
                    Email = user.Email,
                    RoleId = user.RoleId,
                    RoleName = user.RoleName,
                    ProfileImagePath = user.ProfileImagePath,
                    TotalLogs = user.TotalLogs,
                    LastActivity = user.LastActivity,
                    LastAction = user.LastAction,
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
                await _repo.DeleteUserAsync(userId);
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
                await _repo.UpdateUserAsync(user);
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

        public async Task<bool> UpdateUserProfileAsync(EditProfileDTO editProfileDto)
        {
            var existingUser = await _repo.GetUserByUsernameAsync(editProfileDto.Username);
            if (existingUser != null && existingUser.UserId != editProfileDto.UserId)
            {
                throw new Exception("Username already exists.");
            }

            return await _repo.UpdateUserProfileAsync(editProfileDto);
        }

        public async Task AddLogAsync(UserActivityLogDTO log)
        {
            try
            {
                await _repo.AddLogAsync(log);
            }
            catch(Exception ex)
            {
                throw new Exception("An error occurred while logging the activity.", ex);
            }
        }

        #endregion
    }
}
