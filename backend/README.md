# Backend - User Management API

.NET 6 Web API cho quản lý user với PostgreSQL.

## 🛠️ Công nghệ

- .NET 6
- Entity Framework Core
- PostgreSQL (Npgsql)
- Swagger/OpenAPI

## 📦 Cài đặt

```bash
dotnet restore
```

## 🚀 Chạy Development

```bash
dotnet run
```

API sẽ chạy tại http://localhost:5000

Swagger UI: http://localhost:5000/swagger

## 🏗️ Build Production

```bash
dotnet publish -c Release -o ./publish
```

## 🗄️ Database Configuration

Cập nhật connection string trong `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=fullstack_user;Username=postgres;Password=YOUR_PASSWORD"
  }
}
```

## 📁 Cấu trúc thư mục

```
backend/
├── Controllers/
│   └── UsersController.cs    # API endpoints
├── Models/
│   └── User.cs               # User model
├── Data/
│   └── ApplicationDbContext.cs  # EF DbContext
├── Properties/
│   └── launchSettings.json   # Launch configuration
├── Program.cs                # Entry point
├── appsettings.json          # Configuration
└── UserManagement.csproj     # Project file
```

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Lấy tất cả users |
| GET | `/api/users/{id}` | Lấy user theo ID |
| POST | `/api/users` | Tạo user mới |
| PUT | `/api/users/{id}` | Cập nhật user |
| DELETE | `/api/users/{id}` | Xóa user |

## 🧪 Test với curl

```bash
# Get all users
curl http://localhost:5000/api/users

# Create user
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","firstName":"Test","lastName":"User"}'
```

## 🔧 Database Migration

Project này sử dụng existing database. Nếu cần tạo migration:

```bash
# Install EF tools (chỉ lần đầu)
dotnet tool install --global dotnet-ef

# Add migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update
```

