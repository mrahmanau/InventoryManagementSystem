using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InventoryManagementSystem.Service
{
    public class ImageService : IImageService
    {
        private readonly IWebHostEnvironment _env;

        public ImageService (IWebHostEnvironment env)
        {
            _env = env;
        }

        public async Task<string> UploadProfileImageAsync(IFormFile file)
        {
            try
            {
                const long maxSize = 2 * 1024 * 1024;

                if (file == null || file.Length == 0)
                    throw new ArgumentException("No file uploaded.");

                if (file.Length > maxSize)
                    throw new ArgumentException("File size exceeds the limit of 2 MB.");

                var uploadsFolder = Path.Combine(_env.WebRootPath, "images/profiles");
                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                }
                var uniqueFileName = Guid.NewGuid().ToString() + "_" + file.FileName;
                var filePath = Path.Combine(uploadsFolder, uniqueFileName);

                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(fileStream);
                }

                //return "images/profiles/" + uniqueFileName;
                var baseUrl = "https://localhost:7139"; // Update with your backend URL
                return $"{baseUrl}/images/profiles/{uniqueFileName}";
            }
            catch (ArgumentException ex)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new ApplicationException("An error occurred while uploading the file. Please try again later.", ex);
            }
        }

    }
}
