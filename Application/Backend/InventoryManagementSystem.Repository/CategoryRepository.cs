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
    public class CategoryRepository : ICategoryRepository
    {
        private readonly DataAccess db = new();

        #region Public Methods
        public async Task<List<Category>> GetCategoriesAsync()
        {
            var dataTable = await db.ExecuteAsync("spGetCategories", new List<Parm>());
            var categories = new List<Category>();

            foreach (DataRow row in dataTable.Rows)
            {
                categories.Add(new Category
                {
                    CategoryId = Convert.ToInt32(row["CategoryId"]),
                    CategoryName = row["CategoryName"].ToString()
                });
            }

            return categories;
        }
        #endregion

        #region Private Methods
        #endregion
    }
}
