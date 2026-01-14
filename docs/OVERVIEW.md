# Tổng Quan Dự Án

## Giới Thiệu

Dự án **Fullstack User Management Application** là một ứng dụng web quản lý người dùng được xây dựng với mục đích áp dụng quy trình DevOps & Cloud AWS.

---

## Mục Đích
- Triển khai hệ thống AWS cloud với Terraform (IaC)
- Áp dụng containerization với Docker và Docker Compose
- Áp dụng CI/CD với Jenkins pipeline tự động hóa build & deployment
- Monitoring hệ thông với CloudWatch thu thập logs & metrics

---

## Công Nghệ Sử Dụng

| Class | Technology | Mục Đích |
|-------|-----------|------------------|
| **Backend** | .NET 6 Web API | RESTful API services, business logic |
| **Frontend** | Vue.js 3 + Nginx | Single Page Application, web server |
| **Database** | PostgreSQL 14 | Relational database, data persistence |
| **ORM** | Entity Framework Core | Database access, migrations |
| **Containerization** | Docker + Docker Compose | Application packaging, local development |
| **Container Registry** | Amazon ECR | Private Docker image storage |
| **Container Orchestration** | Amazon ECS Fargate | Serverless container deployment |
| **Infrastructure as Code** | Terraform | Provisioning AWS resources |
| **CI/CD** | Jenkins Pipeline | Automated build & deployment |
| **Load Balancer** | Application Load Balancer | Traffic distribution, path-based routing |
| **Networking** | Amazon VPC | Virtual private cloud, subnets, security |
| **Security** | Security Groups + Secrets Manager | Firewall rules, credentials management |
| **Monitoring** | CloudWatch Logs & Metrics | Application logging, performance metrics |
| **Version Control** | Git + GitHub | Source code management, webhooks |

---

## Workflow

![DevOps Workflow](./images/devops-workflow.png)

---

## Cấu Trúc Dự Án

```
fullstack-user/
│
├── backend/                    # .NET 6 Web API
│   ├── Controllers/            # API endpoints
│   │   └── UsersController.cs
│   ├── Models/                 # Entity models
│   │   └── User.cs
│   ├── Data/                   # Database context
│   │   └── ApplicationDbContext.cs
│   ├── Program.cs              # Entry point
│   ├── appsettings.json        # Configuration
│   ├── Dockerfile              # Container definition
│   └── FullstackUser.csproj    # Project file
│
├── frontend/                   # Vue.js 3 SPA
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── views/              # Vue components
│   │   │   ├── UserList.vue
│   │   │   ├── AddUser.vue
│   │   │   └── EditUser.vue
│   │   ├── services/           # API client
│   │   │   └── UserService.js
│   │   ├── router/             # Vue Router
│   │   │   └── index.js
│   │   ├── App.vue
│   │   └── main.js
│   ├── nginx.conf              # Nginx config
│   ├── Dockerfile              # Container definition
│   ├── package.json
│   └── vue.config.js
│
├── terraform/                  # Infrastructure as Code
│   ├── singapore-dev/          # Dev environment
│   │   ├── main.tf             # Module orchestration
│   │   ├── variable.tf         # Input variables
│   │   ├── output.tf           # Output values
│   │   └── terraform.tfvars    # Variable values
│   │
│   └── modules/                # Reusable modules
│       ├── vpc/                # Networking
│       │   ├── main.tf
│       │   ├── variable.tf
│       │   └── output.tf
│       ├── security-groups/    # Firewall rules
│       ├── rds/                # Database
│       ├── alb/                # Load balancer
│       └── ecs/                # Container services
│
├── docs/                       # Documentation
│   ├── README.md               # Main documentation
│   ├── OVERVIEW.md             # This file
│   ├── ARCHITECTURE.md         # Architecture details
│   ├── DEPLOYMENT.md           # Deployment guide
│   ├── CI-CD.md                # CI/CD guide
│   ├── MONITORING.md           # Monitoring guide
│   ├── LESSONS.md              # Lessons learned
│   └── images/                 # Architecture diagrams
│
├── Jenkinsfile                 # CI/CD pipeline definition
├── docker-compose.yml          # Local development
├── database.sql                # Database schema
└── .gitignore
```

---

**Last Updated**: December 2025  
**Author**: Nguyen Hoang Phuc  
