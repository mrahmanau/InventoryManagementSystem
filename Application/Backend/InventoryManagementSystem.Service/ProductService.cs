using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class ProductService : IProductService
    {
        private readonly ProductRepo repo = new();

        public async Task AddProductAsync(ProductDTO productDTO)
        {
   
                // Check for duplicate product name
                var existingProduct = await repo.GetProductByNameAsync(productDTO.ProductName);
                if (existingProduct != null)
                {
                    throw new Exception("Product with the same name already exists.");
                }

                var product = new Product
                {
                    ProductName = productDTO.ProductName,
                    Quantity = productDTO.Quantity,
                    Price = productDTO.Price,
                    CategoryId = productDTO.CategoryId,
                };

                await repo.AddProductAsync(product);
           

        }

        public async Task<IEnumerable<ProductDTO>> GetAllProductsAsync()
        {
            try
            {
                var products = await repo.GetAllProductsAsync();
                var productsDTOs = products.Select(product => new ProductDTO
                {
                    ProductId = product.ProductId,
                    ProductName = product.ProductName,
                    Quantity = product.Quantity,
                    Price = product.Price,
                    CategoryId = product.CategoryId
                });

                return productsDTOs;
            }
            catch(Exception ex)
            {
                throw new Exception("An error occurred while retrieving the products.", ex);
            }
        }

        public async Task UpdateProductAsync(ProductUpdateDTO productUpdateDTO)
        {
            var product = new Product
            {
                ProductId = productUpdateDTO.ProductId,
                ProductName = productUpdateDTO.ProductName,
                Quantity = productUpdateDTO.Quantity,
                Price = productUpdateDTO.Price,
                CategoryId = productUpdateDTO.CategoryId,
                Version = productUpdateDTO.Version
            };

            try
            {
                await repo.UpdateProductAsync(product);
            }
            catch(DBConcurrencyException ex)
            {
                throw new ArgumentException(ex.Message, ex);
            }
        }
    }
}
