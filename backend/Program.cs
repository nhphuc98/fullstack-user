using Microsoft.EntityFrameworkCore;
using FullstackUser.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Configure PostgreSQL
// Support both connection string and individual environment variables (for ECS with Secrets Manager)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// If individual DB env vars are set (ECS deployment), build connection string from them
var dbHost = Environment.GetEnvironmentVariable("DB_HOST");
var dbName = Environment.GetEnvironmentVariable("DB_NAME");
var dbUsername = Environment.GetEnvironmentVariable("DB_USERNAME");
var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD");

if (!string.IsNullOrEmpty(dbHost) && !string.IsNullOrEmpty(dbPassword))
{
    connectionString = $"Host={dbHost};Database={dbName};Username={dbUsername};Password={dbPassword}";
    Console.WriteLine($"Using database connection from environment variables: Host={dbHost}, Database={dbName}");
}
else
{
    Console.WriteLine("Using database connection from appsettings.json");
}

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(connectionString));

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowVueApp",
        policy =>
        {
            policy.WithOrigins("http://localhost:8080", "http://localhost:8081")
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowVueApp");

app.UseAuthorization();

app.MapControllers();

app.Run();

