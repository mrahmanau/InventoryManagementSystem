using InventoryManagementSystem.Model;
using InventoryManagementSystem.Service;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace InventoryManagementSystem.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductController : ControllerBase
    {
        private readonly IProductService productService;

        public ProductController(IProductService productService)
        {
            this.productService = productService;
        }

        [HttpPost]
        public async Task<IActionResult> AddProductAsync([FromBody] ProductDTO productDTO)
        {
            try
            {
                await productService.AddProductAsync(productDTO);
                return Ok(new { message = "Product added successfully" });
            }
            catch(Exception ex)
            {
                return BadRequest(new {message = ex.Message});
            }
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ProductDTO>>> GetAllProductsAsync()
        {
            try
            {
                var products = await productService.GetAllProductsAsync();
                return Ok(products);
            }
            catch(Exception ex)
            {
                return StatusCode(500, "Internal server error.");
            }
        }

        [HttpPut("edit")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(string))]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UpdateProduct([FromBody] ProductUpdateDTO productUpdateDTO)
        {
            try
            {
                await productService.UpdateProductAsync(productUpdateDTO);
                return Ok(new { message = "Product updated successfully." });
            }
            catch (DBConcurrencyException ex)
            {
                return BadRequest(new { Message = "The record has been modified by another user. Please refresh and try again.", Details = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProductAsync(int id)
        {
            try
            {
                await productService.DeleteProductAsync(id);
                return NoContent();
            }
            catch(Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while deleting the product.", error = ex.Message });

            }
        }

        [HttpPost("search")]
        public async Task<IActionResult> SearchProducts([FromBody] ProductSearchDTO searchCriteria)
        {
            try
            {
                var products = await productService.SearchProductsAsync(searchCriteria);
                return Ok(products);
            }
            catch(Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while searching for products.", error = ex.Message });
            }
        }
    }
}
