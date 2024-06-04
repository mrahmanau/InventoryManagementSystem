using DAL;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Types;
using System.Data;
using static Azure.Core.HttpHeader;

namespace InventoryManagementSystem.Repository
{
    public class UserRepo : IUserRepository
    {

        public readonly DataAccess db = new();

        #region Public Methods
        public async Task<User> GetUserByUsernameAsync(string username)
        {
            var parms = new List<Parm>
            {
                new Parm("@Username", SqlDbType.NVarChar, username, 50)
            };

            var dt = await db.ExecuteAsync("spGetUserByUsername", parms);

               // Log the column names for debugging
        Console.WriteLine("Columns in the returned DataTable:");
        foreach (DataColumn column in dt.Columns)
                {
                    Console.WriteLine(column.ColumnName);
                }

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
        public async Task AddUserAsync(User user)
        {
            var parms = new List<Parm>
            {
                new Parm("@FirstName", SqlDbType.NVarChar, user.FirstName, 50),
                new Parm("@LastName", SqlDbType.NVarChar, user.LastName, 50),
                new Parm("@Username", SqlDbType.NVarChar, user.Username, 50),
                new Parm("@Email", SqlDbType.NVarChar, user.Email, 100),
                new Parm("@HashedPassword", SqlDbType.NVarChar, user.HashedPassword, 200),
                new Parm("@RoleId", SqlDbType.Int, user.RoleId)
            };

            await db.ExecuteNonQueryAsync("spAddUser", parms);
        }

        public async Task<User> GetUserByUsernameAndPasswordAsync(string username, string hashedPassword)
        {
            var parms = new List<Parm>
            {
                new Parm("@Username", SqlDbType.NVarChar, username, 50),
                new Parm("@HashedPassword", SqlDbType.NVarChar, hashedPassword, 200)
            };

            var dt = await db.ExecuteAsync("spGetUserByUsernameAndPassword", parms);

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

        public async Task<User> GetUserByIdAsync(int userId)
        {
            var parms = new List<Parm>
            {
                new Parm("@UserId", SqlDbType.Int, userId)
            };

            var dt = await db.ExecuteAsync("spGetUserById", parms);

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

        public async Task<IEnumerable<User>> GetUsersAsync()
        {
            var users = new List<User>();

            var dt = await db.ExecuteAsync("spGetUsers", null);

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
        #endregion
    }
}
