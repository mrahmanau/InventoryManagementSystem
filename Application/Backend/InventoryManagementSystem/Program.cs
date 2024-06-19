
using DAL;
using InventoryManagementSystem.Interfaces;
using InventoryManagementSystem.Model;
using InventoryManagementSystem.Repository;
using InventoryManagementSystem.Service;
using InventoryManagementSystem.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;


namespace InventoryManagementSystem
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Configuration
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .AddEnvironmentVariables();

            // Add services to the container.

            builder.Services.AddControllers();

            builder.Services.AddSingleton<DataAccess>();

            builder.Services.AddScoped<IAuthService, AuthService>();
            builder.Services.AddScoped<IUserService, UserService>();
            builder.Services.AddScoped<ITokenService, TokenService>();
            builder.Services.AddScoped<IProductService, ProductService>();
            builder.Services.AddScoped<ICategoryService, CategoryService>();
            builder.Services.AddScoped<IUserRepository, UserRepo>();
            builder.Services.AddScoped<IEmailService, EmailService>(provider =>
            {
                var configuration = provider.GetRequiredService<IConfiguration>();
                var sendGridApiKey = configuration.GetValue<string>("SendGridApiKey");
                var baseUrl = configuration.GetValue<string>("AppSettings:BaseUrl");
                var logger = provider.GetRequiredService<ILogger<EmailService>>();
                return new EmailService(sendGridApiKey, baseUrl, logger);
            });

            // Register ContactService and ContactRepository
            builder.Services.AddScoped<IContactService, ContactService>();
            builder.Services.AddScoped<IContactRepository, ContactRepository>();

            builder.Services.Configure<StripeSettings>(builder.Configuration.GetSection("Stripe"));

            // Register PaymentService and PaymentRepository
            builder.Services.AddScoped<IPaymentService, PaymentService>();
            builder.Services.AddScoped<IPaymentRepository, PaymentRepository>();

            // Register ImageService
            builder.Services.AddScoped<IImageService, ImageService>();


            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            // Add JWT authentication
            builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
            {
                string? jwtKey = builder.Configuration["Jwt:Key"];
                if (string.IsNullOrEmpty(jwtKey))
                {
                    throw new InvalidOperationException("Jwt:Key is not configured.");
                }

                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
                    ValidateIssuer = false,
                    ValidateAudience = false
                };
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseStaticFiles();
            app.UseDefaultFiles();

            // Configure CORS in ASP.NET Core
            app.UseCors(policy =>
                policy
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .WithOrigins("*")
                );

            app.UseHttpsRedirection();

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}
