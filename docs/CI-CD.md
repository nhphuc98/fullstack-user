# CI/CD với Jenkins

Setup Jenkins CI/CD pipeline để tự động build, test và deploy ứng dụng lên AWS ECS.

## Tổng Quan

### Workflow CI/CD

```
Developer Push Code (GitHub)
          ↓
  Webhook Trigger Jenkins
          ↓
   Jenkins Pipeline Start
          ↓
  Build Docker Images
   (Frontend + Backend)
          ↓
    Login to AWS ECR
          ↓
  Push Images to ECR
          ↓
  Deploy to ECS Fargate
   (Force New Deployment)
          ↓
    Health Check & Monitor
```

## Prerequisites

### 1. Jenkins Server
- **Instance**: EC2 t3.medium (2 vCPU, 4GB RAM)
- **OS**: Ubuntu 22.04
- **Storage**: 30GB
- **Security Group**: Port 22 (SSH), Port 8080 (Jenkins)

### 2. Cài Đặt Cần Thiết
```bash
# Jenkins
sudo systemctl status jenkins

# Docker
docker --version

# AWS CLI
aws --version

# Git
git --version
```

## Setup Jenkins

### Bước 1: Unlock Jenkins
1. Truy cập `http://<EC2-IP>:8080`
2. Lấy initial password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
3. Install suggested plugins

### Bước 2: Cài Plugins
**Manage Jenkins** → **Plugins** → **Available plugins**

Cài các plugins:
- **Docker Plugin**
- **GitHub Plugin**
- **Blue Ocean**
- **AWS Credentials**

### Bước 3: Configure Credentials
**Manage Jenkins** → **Credentials** → **System** → **Global credentials**

Thêm credential:
- **Type**: AWS Credentials
- **ID**: `aws-credentials`
- **Access Key ID**: `<your-access-key>`
- **Secret Access Key**: `<your-secret-key>`

### Bước 4: Tạo Pipeline Job
1. **New Item** → Nhập tên → Chọn **Pipeline**
2. **Build Triggers**: ✅ GitHub hook trigger for GITScm polling
3. **Pipeline** section:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/<username>/fullstack-user.git`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
4. **Save**

### Bước 5: Setup GitHub Webhook
1. GitHub repo → **Settings** → **Webhooks** → **Add webhook**
2. **Payload URL**: `http://<jenkins-ip>:8080/github-webhook/`
3. **Content type**: `application/json`
4. **Events**: Just the push event
5. **Active**: ✅
6. **Add webhook**

## Jenkinsfile Explained

### Pipeline Stages

```groovy
pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-southeast-1'
        ECR_REGISTRY = '<account-id>.dkr.ecr.ap-southeast-1.amazonaws.com'
        BACKEND_IMAGE = 'fullstack-user-backend'
        FRONTEND_IMAGE = 'fullstack-user-frontend'
        ECS_CLUSTER = 'fullstack-user-cluster'
    }
    
    stages {
        // 8 stages chi tiết bên dưới
    }
}
```

### Stage 1: Checkout
```groovy
stage('Checkout') {
    steps {
        checkout scm  // Clone code từ GitHub
    }
}
```

### Stage 2: Build Backend
```groovy
stage('Build Backend') {
    steps {
        sh 'docker build --platform linux/amd64 -t $BACKEND_IMAGE:latest ./backend'
    }
}
```
**Lưu ý**: `--platform linux/amd64` để tương thích với ECS Fargate

### Stage 3: Build Frontend
```groovy
stage('Build Frontend') {
    steps {
        sh 'docker build --platform linux/amd64 -t $FRONTEND_IMAGE:latest ./frontend'
    }
}
```

### Stage 4: Login to ECR
```groovy
stage('Login to ECR') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                         credentialsId: 'aws-credentials']]) {
            sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REGISTRY
            '''
        }
    }
}
```

### Stage 5: Push Backend to ECR
```groovy
stage('Push Backend to ECR') {
    steps {
        sh '''
            docker tag $BACKEND_IMAGE:latest $ECR_REGISTRY/$BACKEND_IMAGE:latest
            docker push $ECR_REGISTRY/$BACKEND_IMAGE:latest
        '''
    }
}
```

### Stage 6: Push Frontend to ECR
```groovy
stage('Push Frontend to ECR') {
    steps {
        sh '''
            docker tag $FRONTEND_IMAGE:latest $ECR_REGISTRY/$FRONTEND_IMAGE:latest
            docker push $ECR_REGISTRY/$FRONTEND_IMAGE:latest
        '''
    }
}
```

### Stage 7: Deploy to ECS
```groovy
stage('Deploy to ECS') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                         credentialsId: 'aws-credentials']]) {
            sh '''
                # Update backend service
                aws ecs update-service \
                    --cluster $ECS_CLUSTER \
                    --service fullstack-user-backend-service \
                    --force-new-deployment \
                    --region $AWS_REGION
                
                # Update frontend service
                aws ecs update-service \
                    --cluster $ECS_CLUSTER \
                    --service fullstack-user-frontend-service \
                    --force-new-deployment \
                    --region $AWS_REGION
            '''
        }
    }
}
```

### Stage 8: Cleanup
```groovy
stage('Cleanup') {
    steps {
        sh '''
            docker rmi $BACKEND_IMAGE:latest || true
            docker rmi $FRONTEND_IMAGE:latest || true
            docker rmi $ECR_REGISTRY/$BACKEND_IMAGE:latest || true
            docker rmi $ECR_REGISTRY/$FRONTEND_IMAGE:latest || true
        '''
    }
}
```

## Testing Pipeline

### Manual Trigger
1. Vào Jenkins job
2. Click **Build Now**
3. Xem progress trong **Console Output**

### Automatic Trigger
```bash
# Make a change
echo "// test" >> backend/Program.cs

# Commit & push
git add .
git commit -m "test: trigger jenkins pipeline"
git push origin main

# Jenkins sẽ tự động build
```


## Pipeline Duration

Typical build time:
- Checkout: 5s
- Build Backend: 2-3 phút
- Build Frontend: 2-3 phút
- Push to ECR: 1-2 phút
- Deploy to ECS: 30s
- **Total: ~6-8 phút**

## Kết Luận

Pipeline này tự động hóa toàn bộ quá trình từ code → build → deploy, giúp:
- ✅ Giảm human errors
- ✅ Tăng tốc độ deployment
- ✅ Consistent builds
- ✅ Easy rollback
- ✅ Audit trail (build history)
