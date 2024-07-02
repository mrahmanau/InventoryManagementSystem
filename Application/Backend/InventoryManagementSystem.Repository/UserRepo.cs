using DAL;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Types;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Diagnostics.Eventing.Reader;
using static Azure.Core.HttpHeader;

namespace InventoryManagementSystem.Repository
{
    public class UserRepo : IUserRepository
    {

        //public readonly DataAccess db = new();
        public readonly DataAccess _db;
        public UserRepo(DataAccess db)
        {
           _db = db;
        }

        #region Public Methods
        public async Task<User> GetUserByUsernameAsync(string username)
        {
            var parms = new List<Parm>
            {
                new Parm("@Username", SqlDbType.NVarChar, username, 50)
            };

            var dt = await _db.ExecuteAsync("spGetUserByUsername", parms);

               // Log the column names for debugging
                //Console.WriteLine("Columns in the returned DataTable:");
                //foreach (DataColumn column in dt.Columns)
                //{
                //    Console.WriteLine(column.ColumnName);
                //}

            if (dt.Rows.Count == 0)
                return null;

            var row = dt.Rows[0];
            return new User
            {
                UserId = (int)row["UserId"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                Username = row["Username"].ToString(),
                Email = row["Email"].ToString(),
                HashedPassword = row["HashedPassword"].ToString(),
                RoleId = (int)row["RoleId"],
                Role = new Role
                {
                    RoleId = (int)row["RoleId"],
                    RoleName = row["RoleName"].ToString()
                }
            };
        }
        public async Task<int> AddUserAsync(User user)
        {
            var parms = new List<Parm>
            {
                new Parm("@FirstName", SqlDbType.NVarChar, user.FirstName, 50),
                new Parm("@LastName", SqlDbType.NVarChar, user.LastName, 50),
                new Parm("@Username", SqlDbType.NVarChar, user.Username, 50),
                new Parm("@Email", SqlDbType.NVarChar, user.Email, 100),
                new Parm("@HashedPassword", SqlDbType.NVarChar, user.HashedPassword, 200),
                new Parm("@RoleId", SqlDbType.Int, user.RoleId),
                new Parm("@EmailConfirmed", SqlDbType.Bit, user.EmailConfirmed),
                new Parm("@EmailConfirmationToken", SqlDbType.NVarChar, user.EmailConfirmationToken, 200),
                new Parm("@ProfileImagePath", SqlDbType.NVarChar, user.ProfileImagePath, 200)

            };

            var userId = await _db.ExecuteScalarAsync<int>("spAddUser", parms);
            return userId;
        }

        public async Task<bool> UpdateUserProfileAsync(EditProfileDTO editProfileDto)
        {
            try
            {
                var parms = new List<Parm>
                {
                    new Parm("@UserId", SqlDbType.Int, editProfileDto.UserId),
                    new Parm("@FirstName", SqlDbType.NVarChar, editProfileDto.FirstName, 50),
                    new Parm("@LastName", SqlDbType.NVarChar, editProfileDto.LastName, 50),
                    new Parm("@Email", SqlDbType.NVarChar, editProfileDto.Email, 100),
                    new Parm("@Username", SqlDbType.NVarChar, editProfileDto.Username, 50)
                };

                var result = await _db.ExecuteNonQueryAsync("spUpdateUserProfile", parms);
                return result > 0;
            }
            catch (SqlException ex)
            {
                if (ex.Number == 50000 && ex.Message.Contains("Username already exists."))
                {
                    throw new Exception("Username already exists.");
                }
                throw new Exception("An error occurred while updating the user profile.", ex);
            }
        }

        public async Task<string> GetHashedPasswordAsync(int userId)
        {
            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, userId)
            };

            var dt = await _db.ExecuteAsync("spGetHashedPassword", parms);

            if (dt.Rows.Count == 0)
            {
                throw new Exception("User not found.");
            }

            var row = dt.Rows[0];
            return row["HashedPassword"].ToString();
        }


        public async Task<bool> UpdatePasswordAsync(int userId, string hashedNewPassword)
        {
            try
            {
                var parms = new List<Parm>
                {
                    new Parm("@UserId", SqlDbType.Int, userId),
                    new Parm("@NewPassword", SqlDbType.NVarChar, hashedNewPassword, 200)
                };

                var result = await _db.ExecuteNonQueryAsync("spUpdatePassword", parms);
                return result > 0;
            }
            catch (SqlException ex)
            {
                throw new Exception("An error occurred while updating the password.", ex);
            }
        }


        public async Task<User> GetUserByUsernameAndPasswordAsync(string username, string hashedPassword)
        {
            var parms = new List<Parm>
            {
                new Parm("@Username", SqlDbType.NVarChar, username, 50),
                new Parm("@HashedPassword", SqlDbType.NVarChar, hashedPassword, 200)
            };

            var dt = await _db.ExecuteAsync("spGetUserByUsernameAndPassword", parms);

            if (dt.Rows.Count == 0)
                return null;

            var row = dt.Rows[0];
            return new User
            {
                UserId = (int)row["UserId"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                Username = row["Username"].ToString(),
                Email = row["Email"].ToString(),
                HashedPassword = row["HashedPassword"].ToString(),
                RoleId = (int)row["RoleId"],
                EmailConfirmed = row["EmailConfirmed"] != DBNull.Value && (bool)row["EmailConfirmed"],

                Role = new Role
                {
                    RoleId = (int)row["RoleId"],
                    RoleName = row["RoleName"].ToString()
                }
            };
        }

        public async Task UpdateTwoFactorCodeAsync(UserDTO user)
        {
            // Log the parameter values
            Console.WriteLine($"UserId: {user.UserId}");
            Console.WriteLine($"TwoFactorCode: {user.TwoFactorCode}");
            Console.WriteLine($"TwoFactorCodeExpiration: {user.TwoFactorCodeExpiration}");

            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, user.UserId),
                new Parm("@TwoFactorCode", SqlDbType.NVarChar, user.TwoFactorCode, 6),
                new Parm("@TwoFactorCodeExpiration", SqlDbType.DateTime, user.TwoFactorCodeExpiration)
            };

            await _db.ExecuteNonQueryAsync("spUpdateTwoFactorCode", parms);
        }

        public async Task ClearTwoFactorCodeAsync(int userId)
        {
            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, userId),
                new Parm("@TwoFactorCode", SqlDbType.NVarChar, DBNull.Value, 6),
                new Parm("@TwoFactorCodeExpiration", SqlDbType.DateTime, DBNull.Value)
            };

            await _db.ExecuteNonQueryAsync("spUpdateTwoFactorCode", parms);
        }

        public async Task<User> GetUserByEmailAsync(string email)
        {
            var parms = new List<Parm>
            {
                new Parm("@Email", SqlDbType.NVarChar, email, 100)
            };

            var dt = await _db.ExecuteAsync("spGetUserByEmail", parms);

            if (dt.Rows.Count == 0)
            {
                return null;
            }

            var row = dt.Rows[0];
            return new User
            {
                UserId = (int)row["UserId"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                Username = row["Username"].ToString(),
                Email = row["Email"].ToString(),
                RoleId = (int)row["RoleId"],
                EmailConfirmed = (bool)row["EmailConfirmed"]
            };
        }

        public async Task<string> GeneratePasswordResetTokenAsync(int userId)
        {
            var token = Guid.NewGuid().ToString();
            var expiration = DateTime.UtcNow.AddHours(24);

            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, userId),
                new Parm("@ResetToken", SqlDbType.NVarChar, token, 200),
                new Parm("@Expiration", SqlDbType.DateTime, expiration)
            };

            await _db.ExecuteNonQueryAsync("spUpdatePasswordResetToken", parms);

            return token;
        }

        public async Task<bool> UpdatePasswordResetTokenAsync(int userId, string resetToken, DateTime expiration)
        {
            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, userId),
                new Parm("@ResetToken", SqlDbType.NVarChar, resetToken, 200),
                new Parm("@Expiration", SqlDbType.DateTime, expiration)
            };

            var result = await _db.ExecuteNonQueryAsync("spUpdatePasswordResetToken", parms);
            return result > 0;
        }

        public async Task<User> GetUserByResetTokenAsync(string token)
        {
            var parms = new List<Parm>
    {
        new Parm("@PasswordResetToken", SqlDbType.NVarChar, token, 200)
    };

            var dt = await _db.ExecuteAsync("spGetUserByResetToken", parms);

            if (dt.Rows.Count == 0)
            {
                return null;
            }

            var row = dt.Rows[0];
            return new User
            {
                UserId = (int)row["UserId"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                Username = row["Username"].ToString(),
                Email = row["Email"].ToString(),
                RoleId = (int)row["RoleId"],
                EmailConfirmed = (bool)row["EmailConfirmed"]
            };
        }

        public async Task<bool> ResetPasswordAsync(int userId, string hashedNewPassword)
        {
            var parms = new List<Parm>
        {
            new Parm("@UserId", SqlDbType.Int, userId),
            new Parm("@NewPassword", SqlDbType.NVarChar, hashedNewPassword, 200)
        };

            var result = await _db.ExecuteNonQueryAsync("spResetPassword", parms);
            return result > 0;
        }


        public async Task<UserDTO> GetUserByIdAsync(int userId)
        {
            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, userId)
            };

            var dt = await _db.ExecuteAsync("spGetUserById", parms);

            if (dt.Rows.Count == 0)
                return null;

            var row = dt.Rows[0];

            return new UserDTO
            {
                UserId = (int)row["UserId"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                UserName = row["Username"].ToString(),
                Email = row["Email"].ToString(),
                RoleId = (int)row["RoleId"],
                RoleName = row["RoleName"].ToString(),
                ProfileImagePath = row["ProfileImagePath"].ToString(),
                TotalLogs = (int)row["TotalLogs"],
                LastActivity = row["LastActivity"] == DBNull.Value ? (DateTime?)null : (DateTime)row["LastActivity"],
                LastAction = row["LastAction"].ToString(),
                TwoFactorCode = row["TwoFactorCode"].ToString(), 
                TwoFactorCodeExpiration = row["TwoFactorCodeExpiration"] == DBNull.Value ? (DateTime?)null : (DateTime)row["TwoFactorCodeExpiration"] 
            };
        }

        public async Task<IEnumerable<User>> GetUsersAsync()
        {
            var users = new List<User>();

            var dt = await _db.ExecuteAsync("spGetUsers", null);

            foreach(DataRow row in dt.Rows)
            {
                users.Add(new User
                {
                    UserId = Convert.ToInt32(row["UserId"]),
                    FirstName = row["FirstName"].ToString(),
                    LastName = row["LastName"].ToString()
                });
            }

            return users;
        }

        public async Task DeleteUserAsync(int userId)
        {
            try
            {
                var parms = new List<Parm>
                {
                    new Parm("@UserId", SqlDbType.Int, userId)
                };

                await _db.ExecuteNonQueryAsync("spDeleteUser", parms);
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
                var parms = new List<Parm>
                {
                    new Parm("@UserId", SqlDbType.Int, user.UserId),
                    new Parm("@FirstName", SqlDbType.NVarChar, user.FirstName),
                    new Parm("@LastName", SqlDbType.NVarChar, user.LastName),
                    new Parm("@UserName", SqlDbType.NVarChar, user.UserName),
                    new Parm("@Email", SqlDbType.NVarChar, user.Email),
                    new Parm("@RoleId", SqlDbType.Int, user.RoleId)
                };

                await _db.ExecuteNonQueryAsync("spUpdateUser", parms);
            }
            catch(SqlException ex)
            {
                if (ex.Number == 50000 && ex.Message.Contains("Duplicate username."))
                {
                    throw new RepositoryException("Please choose another username as it is already taken by another user.", ex);
                }
                else
                {
                    throw new Exception("An error occurred while updating the user", ex);
                }
            }
        }

        public async Task AddLogAsync(UserActivityLogDTO log)
        {
            try
            {
                var parms = new List<Parm>
                {
                    new Parm("@UserId", SqlDbType.Int, log.UserId),
                    new Parm("@Action", SqlDbType.NVarChar, log.Action),
                    new Parm("@Timestamp", SqlDbType.DateTime, log.Timestamp),
                    new Parm("@Details", SqlDbType.NVarChar, log.Details)
                };

                await _db.ExecuteNonQueryAsync("spAddUserActivityLog", parms);
            }
            catch(SqlException ex)
            {
                throw new Exception("An error occurred while adding the log entry to the database.", ex);
            }
            catch (Exception ex)
            {
                throw new Exception("An unexpected error occurred while adding the log entry.", ex);
            }
        }

        public async Task<User> GetUserByTokenAsync(string token)
        {
            //token = token.Trim();
            var parms = new List<Parm>
            {
                new Parm("@Token", SqlDbType.NVarChar, token, 200)
            };

            var dt = await _db.ExecuteAsync("spGetUserByToken", parms);

            Console.WriteLine("Rows returned: " + dt.Rows.Count);

            if (dt.Rows.Count == 0)
            {
                // Log if no rows are returned
                Console.WriteLine("No user found for the given token.");
                return null;
            }

            var row = dt.Rows[0];

            // Log the returned data
            Console.WriteLine("UserId: " + row["UserId"]);
            Console.WriteLine("FirstName: " + row["FirstName"]);
            Console.WriteLine("LastName: " + row["LastName"]);
            Console.WriteLine("Username: " + row["Username"]);
            Console.WriteLine("Email: " + row["Email"]);
            Console.WriteLine("EmailConfirmed: " + row["EmailConfirmed"]);
            Console.WriteLine("EmailConfirmationToken: " + row["EmailConfirmationToken"]);

            return new User
            {
                UserId = (int)row["UserId"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                Username = row["Username"].ToString(),
                Email = row["Email"].ToString(),
                HashedPassword = row["HashedPassword"].ToString(),
                RoleId = (int)row["RoleId"],
                EmailConfirmed = (bool)row["EmailConfirmed"],
                EmailConfirmationToken = row["EmailConfirmationToken"].ToString(),
                Role = new Role
                {
                    RoleId = (int)row["RoleId"],
                    RoleName = row["RoleName"].ToString()
                }
            };
        }

        public async Task UpdateEmailConfirmationStatusAsync(User user)
        {
            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, user.UserId),
                new Parm("@EmailConfirmed", SqlDbType.Bit, user.EmailConfirmed),
                new Parm("@EmailConfirmationToken", SqlDbType.NVarChar, DBNull.Value, 200)
            };

            await _db.ExecuteNonQueryAsync("spUpdateEmailConfirmationStatus", parms);
        }
        #endregion

        public class RepositoryException : Exception
        {
            public RepositoryException(string message) : base(message)
            {
            }

            public RepositoryException(string message, Exception innerException) : base(message, innerException)
            {
            }
        }
    }
}
