# Monitoring với CloudWatch

Setup và sử dụng AWS CloudWatch để monitor ứng dụng fullstack trên ECS.

## Tổng Quan

CloudWatch tự động thu thập logs và metrics từ:
- ✅ ECS Backend tasks
- ✅ ECS Frontend tasks
- ✅ Application Load Balancer
- ✅ RDS PostgreSQL
- ✅ NAT Gateway

## CloudWatch Logs

### Xem Logs Qua Console

#### Backend Logs
1. **CloudWatch Console** → **Log groups**
2. Chọn `/ecs/fullstack-user-backend-log-group`
3. Click vào log stream mới nhất
4. Xem real-time logs

#### Frontend Logs
1. Chọn `/ecs/fullstack-user-frontend-log-group`
2. Click vào log stream
3. Xem Nginx access logs

## CloudWatch Metrics

### Enable Container Insights 

```bash
aws ecs update-cluster-settings \
  --cluster fullstack-user-cluster \
  --settings name=containerInsights,value=enabled \
  --region ap-southeast-1
```

Container Insights cung cấp:
- CPU & Memory usage per task
- Network metrics
- Task count
- Container-level metrics

### Key Metrics

#### ECS Metrics
| Metric | Ý Nghĩa | Threshold |
|--------|---------|-----------|
| CPUUtilization | CPU usage % | < 80% |
| MemoryUtilization | Memory usage % | < 85% |
| RunningTaskCount | Số tasks đang chạy | >= 1 |

#### ALB Metrics
| Metric | Ý Nghĩa | Threshold |
|--------|---------|-----------|
| RequestCount | Số requests | - |
| TargetResponseTime | Latency trung bình | < 1s |
| HTTPCode_Target_5XX_Count | Server errors | < 5/5min |
| HealthyHostCount | Targets healthy | >= 1 |
| UnHealthyHostCount | Targets unhealthy | 0 |

#### RDS Metrics
| Metric | Ý Nghĩa | Threshold |
|--------|---------|-----------|
| DatabaseConnections | Active connections | < 100 |
| CPUUtilization | CPU usage | < 80% |
| FreeableMemory | Free memory | > 100MB |
| FreeStorageSpace | Free disk | > 5GB |

### Query Metrics via CLI

#### ECS CPU Usage
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=fullstack-user-cluster \
              Name=ServiceName,Value=fullstack-user-backend-service \
  --start-time $(date -v-1H -u +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region ap-southeast-1
```

#### ALB Request Count
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=app/fullstack-user-alb/<id> \
  --start-time $(date -v-1H -u +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum \
  --region ap-southeast-1
```

## CloudWatch Dashboards

### Tạo Dashboard Qua Console

1. **CloudWatch** → **Dashboards** → **Create dashboard**
2. Nhập tên: `fullstack-user-dashboard`
3. **Add widget**

### Widget 1: ECS CPU & Memory

**Widget type**: Line

**Metrics**:
```
AWS/ECS > ClusterName, ServiceName
- CPUUtilization (fullstack-user-cluster, fullstack-user-backend-service)
- MemoryUtilization (fullstack-user-cluster, fullstack-user-backend-service)
- CPUUtilization (fullstack-user-cluster, fullstack-user-frontend-service)
- MemoryUtilization (fullstack-user-cluster, fullstack-user-frontend-service)
```

### Widget 2: ALB Metrics

**Metrics**:
```
AWS/ApplicationELB > LoadBalancer
- RequestCount (Sum, 5 minutes)
- TargetResponseTime (Average, 5 minutes)
- HTTPCode_Target_5XX_Count (Sum, 5 minutes)
```

### Widget 3: Target Health

**Metrics**:
```
AWS/ApplicationELB > TargetGroup
- HealthyHostCount (fullstack-user-backend-tg)
- UnHealthyHostCount (fullstack-user-backend-tg)
- HealthyHostCount (fullstack-user-frontend-tg)
- UnHealthyHostCount (fullstack-user-frontend-tg)
```

### Widget 4: RDS Metrics

**Metrics**:
```
AWS/RDS > DBInstanceIdentifier
- DatabaseConnections (fullstack-user-postgres)
- CPUUtilization (fullstack-user-postgres)
```

## CloudWatch Alarms

### Alarm 1: High Error Rate

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name fullstack-backend-high-errors \
  --alarm-description "Alert when 5xx errors > 10 in 5 minutes" \
  --metric-name HTTPCode_Target_5XX_Count \
  --namespace AWS/ApplicationELB \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --region ap-southeast-1
```

### Alarm 2: Unhealthy Targets

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name fullstack-backend-unhealthy \
  --alarm-description "Alert when backend targets unhealthy" \
  --metric-name UnHealthyHostCount \
  --namespace AWS/ApplicationELB \
  --statistic Average \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 2 \
  --region ap-southeast-1
```

### Alarm 3: High CPU Usage

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name fullstack-backend-high-cpu \
  --alarm-description "Alert when CPU > 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --dimensions Name=ClusterName,Value=fullstack-user-cluster \
              Name=ServiceName,Value=fullstack-user-backend-service \
  --region ap-southeast-1
```

### Alarm 4: Low Memory

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name fullstack-backend-low-memory \
  --alarm-description "Alert when memory < 100MB" \
  --metric-name FreeableMemory \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 100000000 \
  --comparison-operator LessThanThreshold \
  --evaluation-periods 1 \
  --dimensions Name=DBInstanceIdentifier,Value=fullstack-user-postgres \
  --region ap-southeast-1
```


## Health Checks

### Check ECS Task Health

```bash
# List running tasks
aws ecs list-tasks \
  --cluster fullstack-user-cluster \
  --service-name fullstack-user-backend-service \
  --desired-status RUNNING \
  --region ap-southeast-1

# Get task details
aws ecs describe-tasks \
  --cluster fullstack-user-cluster \
  --tasks <task-arn> \
  --region ap-southeast-1
```

## Cost Monitoring

### CloudWatch Costs
- **Logs Ingestion**: $0.50/GB
- **Logs Storage**: $0.03/GB/month
- **Metrics**: First 10 metrics free, $0.30/metric/month sau đó
- **Dashboards**: First 3 free, $3/dashboard/month
- **Alarms**: $0.10/alarm/month

### Giảm Chi Phí

```bash
# Set log retention (mặc định: Never expire)
aws logs put-retention-policy \
  --log-group-name /ecs/fullstack-user-backend-log-group \
  --retention-in-days 7 \
  --region ap-southeast-1

# Delete old log groups không dùng
aws logs delete-log-group \
  --log-group-name <old-log-group> \
  --region ap-southeast-1
```
