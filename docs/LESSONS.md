# Bài Học Từ Dự Án

Tổng hợp kinh nghiệm và bài học quan trọng học được qua quá trình triển khai dự án fullstack áp dụng quy trình DevOps.

## 1. Docker & Containerization

### ✅ Lessons Learned

**Platform Architecture Matters**
- ECS Fargate chỉ support `linux/amd64`
- Phải build với flag `--platform linux/amd64` nếu develop trên Apple Silicon (M1/M2)
- Error `exec format error` = sai platform architecture

**Multi-stage Builds**
- Frontend: build stage riêng với Node.js, runtime stage chỉ dùng Nginx
- Backend: không cần multi-stage vì .NET SDK đã nhẹ
- Giảm image size => pull nhanh hơn, chi phí ECR thấp hơn

**Docker Compose for Local Dev**
- Giúp replicate production environment ở local
- Easy để test database migrations
- Volumes cho hot-reload trong development

### ❌ Mistakes Made

1. **Không build đúng platform**: Mất 1 giờ debug "exec format error"
2. **Hardcode localhost**: Phải dùng environment variables cho flexible config
3. **Expose unnecessary ports**: Security risk, chỉ expose ports cần thiết

## 2. AWS Infrastructure

### ✅ Lessons Learned

**VPC Design**
- Public subnets cho ALB (internet-facing)
- Private subnets cho ECS + RDS (security)
- NAT Gateway cho private subnets access internet (pull images, packages)
- Multi-AZ cho high availability (nhưng tốn chi phí)

**Security Groups**
- Principle of least privilege: chỉ allow traffic cần thiết
- ALB SG: Allow 80 from 0.0.0.0/0
- ECS SG: Allow 80 from ALB SG only
- RDS SG: Allow 5432 from ECS SG only

**Secrets Management**
- Dùng AWS Secrets Manager cho database passwords
- ECS tasks fetch secrets tự động via `secrets` trong task definition
- Không bao giờ hardcode passwords trong code/Terraform

**Load Balancing**
- Path-based routing: `/api/*` → backend, `/*` → frontend
- Health checks quan trọng: nếu sai path, targets sẽ unhealthy mãi
- Sticky sessions không cần cho stateless APIs

### ❌ Mistakes Made

1. **Forgot NAT Gateway**: Tasks không pull được images từ ECR
2. **Wrong health check path**: Targets unhealthy, 503 errors
3. **RDS publicly accessible**: Security risk, phải để `false`
4. **Nginx proxy /api/ in frontend**: Conflict với ALB routing, gây DNS errors

## 3. Terraform (Infrastructure as Code)

### ✅ Lessons Learned

**Module Structure**
- Tách modules cho reusability: vpc, security-groups, rds, alb, ecs
- Module dependencies: dùng `depends_on` để control order
- Data sources để fetch existing resources (ECR repos, Secrets Manager)

**Variables & Outputs**
- Input variables cho customization
- Outputs để pass values giữa modules
- `.tfvars` file cho environment-specific configs

### ❌ Mistakes Made

1. **Terraform manage Secrets Manager secret**: Recovery window 30 days, không destroy được ngay
   - **Fix**: Dùng data source để reference existing secret
2. **Hardcode resource names**: Khó reuse cho multiple environments
3. **Không dùng variables**: Hard to customize, phải edit code trực tiếp

## 4. ECS Fargate

### ✅ Lessons Learned

**Task Definitions**
- CPU & Memory: Backend cần nhiều hơn frontend (512/1024 vs 256/512)
- Environment variables: pass DB config, API URLs
- Secrets: fetch từ Secrets Manager, không dùng env vars
- Log configuration: awslogs driver → CloudWatch

**Services**
- Desired count: 1 task ok cho dev, 2+ cho production
- Load balancer integration: auto-register tasks vào target groups
- Health checks: ECS stop unhealthy tasks, start new ones
- Force new deployment: `--force-new-deployment` để update tasks

**IAM Roles**
- Task Execution Role: pull images, logs, secrets
- Task Role: access AWS services (S3, DynamoDB, etc.)
- Separate roles cho different responsibilities

### ❌ Mistakes Made

1. **Quên execution role**: Tasks không start vì không pull được images
2. **Wrong port mapping**: Container port phải match với application port
3. **Security group rules**: ECS SG phải allow traffic from ALB SG

## 4. CI/CD Pipeline

### ✅ Lessons Learned

**Jenkins Setup**
- t3.medium ok cho nhỏ projects (2 services)
- Install Docker, AWS CLI on Jenkins server
- Jenkins user phải trong docker group

**Pipeline Design**
- Parallel stages khi có thể (build backend + frontend)
- Always cleanup images sau khi push
- Use AWS Credentials binding, không hardcode keys
- Force new deployment sau push images

**GitHub Webhooks**
- Webhook URL: `http://<jenkins-ip>:8080/github-webhook/`
- Test webhook trong GitHub settings
- Monitor webhook deliveries để debug issues

### ❌ Mistakes Made

1. **Wrong credential type**: Dùng "Username with password" thay vì "AWS Credentials"
2. **Không cleanup images**: Jenkins server full disk sau vài builds
3. **Hardcode environment**: Khó deploy lên multiple environments

## 5. Monitoring & Debugging

### ✅ Lessons Learned

**CloudWatch Logs**
- Setup log groups trước khi start tasks
- Name format: `/ecs/<cluster>-<service>-log-group`
- Retention policy để giảm costs
- Filter patterns cho quick debugging

**Metrics**
- Enable Container Insights cho detailed metrics
- Monitor: CPU, Memory, Request count, Error rate
- Set alarms cho critical metrics
- Dashboard cho quick overview

**Debugging Process**
1. Check CloudWatch logs first
2. Check ECS task events
3. Check target group health
4. Check security groups
5. Test locally với docker-compose

### ❌ Mistakes Made

1. **Không set log retention**: Chi phí CloudWatch tăng cao
2. **Không setup alarms**: Không biết khi nào có issues
3. **Ignore ECS task events**: Missed helpful error messages

## 6. Cost Optimization

### 💰 Cost Breakdown

**Expensive Resources**:
- NAT Gateway: ~$32/month (unavoidable nếu cần private subnets)
- ECS Fargate: ~$30/month (2 tasks)
- ALB: ~$16/month

**Cheap Resources**:
- RDS t3.micro: ~$15/month
- CloudWatch Logs: ~$3/month
- Secrets Manager: ~$0.4/month

### ✅ Lessons Learned

**Cost Reduction Strategies**:
1. Stop RDS khi không dùng: `aws rds stop-db-instance`
2. Scale down ECS desired count to 0: Free khi không chạy
3. Use spot instances cho Jenkins server: Tiết kiệm 60-70%
4. Set CloudWatch log retention: 7 days thay vì forever
5. Single NAT Gateway thay vì multi-AZ: Tiết kiệm $32/month
6. Destroy resources khi không dùng: `terraform destroy`

**Trade-offs**:
- Multi-AZ NAT = high availability nhưng đắt gấp đôi
- Bigger ECS tasks = better performance nhưng đắt hơn
- CloudWatch detailed monitoring = better insights nhưng tốn thêm $3/month

## 7. Security

### ✅ Lessons Learned

**Network Security**:
- Private subnets cho backend services
- No public IPs cho ECS tasks

**Secrets Management**:
- AWS Secrets Manager cho passwords
- Rotate secrets regularly (optional)
- Never commit secrets to Git

**IAM Permissions**:
- Least privilege principle
- Separate roles cho different services
- No root access keys

### ❌ Mistakes Made

1. **RDS publicly accessible**: Security audit flagged this
2. **Overly permissive security groups**: Allow all traffic ban đầu

## 8. Overall Workflow

### ✅ Best Practices

```
Development:
1. Code locally
2. Test với docker-compose
3. Commit với meaningful messages
4. Push to GitHub
5. Jenkins auto build & deploy
6. Monitor logs & metrics
7. Rollback nếu có issues

Infrastructure:
1. Design architecture
2. Write Terraform modules
3. Test với terraform plan
4. Apply changes
5. Verify resources created
6. Document changes

Deployment:
1. Build images với correct platform
2. Push to ECR
3. Deploy infrastructure
4. Initialize database
5. Verify health checks
6. Test application
```

## 9. Future Improvements

**Technical:**
- Kubernetes orchestration
- Automated testing (unit, integration)
- Blue-green deployments

**Monitoring:**
- ELK stack for centralized logging
- Distributed tracing (Jaeger)
- APM tools

**Security:**
- Container vulnerability scanning
- Secrets rotation
- WAF implementation