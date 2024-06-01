using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using System;
using System.Collections.Generic;
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
    }
}
