using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class CategoryService : ICategoryService
    {
        private readonly CategoryRepository repo = new();

        public async Task<List<Category>> GetCategoriesAsync()
        {
            return await repo.GetCategoriesAsync();
        }
    }
}
