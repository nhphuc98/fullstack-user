# 🚀 Fullstack User Management Application

A complete fullstack application with modern DevOps practices, featuring containerization, CI/CD pipeline, and AWS cloud deployment.

## 📖 Overview

This project demonstrates a production-ready fullstack application with:
- **Modern Tech Stack**: .NET 6 API + Vue.js 3 SPA
- **Containerization**: Docker + Docker Compose
- **Infrastructure as Code**: Terraform (AWS ECS Fargate)
- **CI/CD Pipeline**: Jenkins automation
- **Cloud Deployment**: AWS (ECS, RDS, ALB, ECR)

### ✨ Key Features

- ✅ Full CRUD operations for user management
- ✅ RESTful API with Swagger documentation
- ✅ Responsive SPA with real-time search
- ✅ Dockerized microservices architecture
- ✅ Automated CI/CD pipeline
- ✅ AWS cloud infrastructure with Terraform

## 🛠️ Tech Stack

### Application Layer
| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Backend** | .NET 6 Web API | RESTful API services |
| **Frontend** | Vue.js 3 + Nginx | Single Page Application |
| **Database** | PostgreSQL 14 | Relational database |
| **ORM** | Entity Framework Core | Database access |

### DevOps & Infrastructure
| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Containerization** | Docker + Docker Compose | Local development & deployment |
| **CI/CD** | Jenkins Pipeline | Automated build & deploy |
| **IaC** | Terraform | Infrastructure provisioning |
| **Cloud Platform** | AWS | Production hosting |
| **Container Registry** | Amazon ECR | Docker image storage |
| **Orchestration** | Amazon ECS Fargate | Serverless containers |
| **Load Balancer** | Application Load Balancer | Traffic distribution |
| **Monitoring** | CloudWatch Logs | Application logging |

## 📁 Project Structure

```
fullstack-user/
├── backend/              # .NET 6 Web API
│   ├── Controllers/      # REST API endpoints
│   ├── Models/           # Entity models
│   ├── Data/             # EF Core DbContext
│   ├── Dockerfile        # Backend container
│   └── FullstackUser.csproj
│
├── frontend/             # Vue.js 3 SPA
│   ├── src/
│   │   ├── views/        # Vue components
│   │   ├── services/     # API client
│   │   └── router/       # Vue Router
│   ├── nginx.conf        # Nginx configuration
│   └── Dockerfile        # Frontend container
│
├── terraform/            # Infrastructure as Code
│   ├── singapore-dev/    # Dev environment
│   └── modules/          # Reusable modules
│       ├── vpc/
│       ├── security-groups/
│       ├── rds/
│       ├── alb/
│       └── ecs/
│
├── Jenkinsfile          # CI/CD pipeline
├── docker-compose.yml   # Local development
└── database.sql         # Database schema
```

## ⚡ Quick Start

### Prerequisites
- Docker & Docker Compose
- AWS CLI (for cloud deployment)
- Terraform (for infrastructure)

### 🐳 Run with Docker

```bash
# Start all services
docker-compose up -d

# Access application
# Frontend: http://localhost:8080
# Backend API: http://localhost:5001
# Swagger: http://localhost:5001/swagger
```

### 🖥️ Run Locally (Development)

**Backend:**
```bash
cd backend
dotnet restore
dotnet run  # http://localhost:5000
```

**Frontend:**
```bash
cd frontend
npm install
npm run serve  # http://localhost:8080
```

**Database:**
```bash
psql -U postgres -f database.sql
```

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| GET | `/api/users/{id}` | Get user by ID |
| POST | `/api/users` | Create new user |
| PUT | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Delete user |

Swagger UI available at: `http://localhost:5001/swagger`


