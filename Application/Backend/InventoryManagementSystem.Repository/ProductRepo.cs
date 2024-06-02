using DAL;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Types;
using Microsoft.Data.SqlClient;
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

        public async Task<IEnumerable<Product>> GetAllProductsAsync()
        {
            var products = new List<Product>();
            var dt = await db.ExecuteAsync("spGetAllProducts");

            foreach (DataRow row in dt.Rows)
            {
                products.Add(new Product
                {
                    ProductId = Convert.ToInt32(row["ProductId"]),
                    ProductName = row["ProductName"].ToString(),
                    Quantity = Convert.ToInt32(row["Quantity"]),
                    Price = Convert.ToDecimal(row["Price"]),
                    CategoryId = Convert.ToInt32(row["CategoryId"]),
                    Version = (byte[])row["Version"]
                }) ;
            }

            return products;
        }

        public async Task UpdateProductAsync(Product product)
        {
            try
            {
                var parms = new List<Parm>
                {
                    new Parm("@ProductId", SqlDbType.Int, product.ProductId),
                    new Parm("@ProductName", SqlDbType.NVarChar, product.ProductName),
                    new Parm("@Quantity", SqlDbType.Int, product.Quantity),
                    new Parm("@Price", SqlDbType.Decimal, product.Price),
                    new Parm("@CategoryId", SqlDbType.Int, product.CategoryId),
                    new Parm("@Version", SqlDbType.Binary, product.Version)
                };

                await db.ExecuteNonQueryAsync("spUpdateProduct", parms);
            }
            catch(SqlException ex)
            {
                if(ex.Message.Contains("Concurrency error occurred in updating product. Please try again."))
                {
                    throw new DBConcurrencyException("The record has been modified by another user. Please refresh and try again.");
                }
            }
        }
        #endregion

        #region Private Methods
        #endregion
    }
}
