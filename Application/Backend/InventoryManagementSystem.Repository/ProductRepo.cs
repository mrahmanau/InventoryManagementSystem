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
    public class ProductRepo : IProductRepository
    {
        public readonly DataAccess db = new();

        #region Public Methods
        public async Task AddProductAsync(Product product)
        {
            var parms = new List<Parm>
            {
                new Parm("@ProductName", SqlDbType.NVarChar, product.ProductName),
                new Parm("@Quantity", SqlDbType.Int, product.Quantity),
                new Parm("@Price", SqlDbType.Decimal, product.Price),
                new Parm("@CategoryId", SqlDbType.Int, product.CategoryId)
            };

            await db.ExecuteNonQueryAsync("spAddProduct", parms);
        }

        public async Task<Product> GetProductByNameAsync(string productName)
        {
            var parms = new List<Parm>
            {
                new Parm("ProductName", SqlDbType.NVarChar, productName)
            };

            var dt = await db.ExecuteAsync("spGetProductByName", parms);

            if(dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                return new Product
                {
                    ProductId = Convert.ToInt32(row["ProductId"]),
                    ProductName = row["ProductName"].ToString(),
                    Quantity = Convert.ToInt32(row["Quantity"]),
                    Price = Convert.ToDecimal(row["Price"]),
                    CategoryId = Convert.ToInt32(row["CategoryId"]),
                    Version = (byte[])row["Version"]
                };
            }

            return null;

        }
        #endregion

        #region Private Methods
        #endregion
    }
}
