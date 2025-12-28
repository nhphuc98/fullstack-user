pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-southeast-1'
        AWS_ACCOUNT_ID = '174666429126'
        BACKEND_ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/fullstack-user-backend"
        FRONTEND_ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/fullstack-user-frontend"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build Backend') {
            steps {
                echo 'Building Backend Docker image...'
                script {
                    dir('backend') {
                        sh """
                            docker build \
                                --platform linux/amd64 \
                                -t fullstack-user-backend:${IMAGE_TAG} \
                                -t fullstack-user-backend:latest \
                                .
                        """
                    }
                }
                echo 'Backend image built successfully!'
            }
        }
        
        stage('Build Frontend') {
            steps {
                echo 'Building Frontend Docker image...'
                script {
                    dir('frontend') {
                        sh """
                            docker build \
                                --platform linux/amd64 \
                                -t fullstack-user-frontend:${IMAGE_TAG} \
                                -t fullstack-user-frontend:latest \
                                .
                        """
                    }
                }
                echo 'Frontend image built successfully!'
            }
        }
        
        stage('Login to ECR') {
            steps {
                echo 'Logging in to Amazon ECR...'
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | \
                            docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        """
                    }
                }
                echo 'ECR login successful!'
            }
        }
        
        stage('Push Backend to ECR') {
            steps {
                echo 'Pushing Backend image to ECR...'
                script {
                    sh """
                        docker tag fullstack-user-backend:${IMAGE_TAG} ${BACKEND_ECR_REPO}:${IMAGE_TAG}
                        docker tag fullstack-user-backend:latest ${BACKEND_ECR_REPO}:latest
                        docker push ${BACKEND_ECR_REPO}:${IMAGE_TAG}
                        docker push ${BACKEND_ECR_REPO}:latest
                    """
                }
                echo "Backend pushed: ${BACKEND_ECR_REPO}:${IMAGE_TAG}"
            }
        }
        
        stage('Push Frontend to ECR') {
            steps {
                echo 'Pushing Frontend image to ECR...'
                script {
                    sh """
                        docker tag fullstack-user-frontend:${IMAGE_TAG} ${FRONTEND_ECR_REPO}:${IMAGE_TAG}
                        docker tag fullstack-user-frontend:latest ${FRONTEND_ECR_REPO}:latest
                        docker push ${FRONTEND_ECR_REPO}:${IMAGE_TAG}
                        docker push ${FRONTEND_ECR_REPO}:latest
                    """
                }
                echo "Frontend pushed: ${FRONTEND_ECR_REPO}:${IMAGE_TAG}"
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                echo 'Deploying to ECS Fargate...'
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        // Update Backend Service
                        echo 'Updating Backend ECS service...'
                        sh """
                            aws ecs update-service \
                                --cluster fullstack-user-ecs-cluster \
                                --service backend-service \
                                --force-new-deployment \
                                --region ${AWS_REGION}
                        """
                        
                        // Update Frontend Service
                        echo 'Updating Frontend ECS service...'
                        sh """
                            aws ecs update-service \
                                --cluster fullstack-user-ecs-cluster \
                                --service frontend-service \
                                --force-new-deployment \
                                --region ${AWS_REGION}
                        """
                        
                        // Wait for services to stabilize
                        echo 'Waiting for services to stabilize...'
                        sh """
                            aws ecs wait services-stable \
                                --cluster fullstack-user-ecs-cluster \
                                --services backend-service frontend-service \
                                --region ${AWS_REGION}
                        """
                    }
                }
                echo 'Deployment completed successfully!'
            }
        }
        
        stage('Cleanup') {
            steps {
                echo 'Cleaning up local Docker images...'
                script {
                    sh """
                        docker rmi fullstack-user-backend:${IMAGE_TAG} || true
                        docker rmi fullstack-user-backend:latest || true
                        docker rmi fullstack-user-frontend:${IMAGE_TAG} || true
                        docker rmi fullstack-user-frontend:latest || true
                        docker rmi ${BACKEND_ECR_REPO}:${IMAGE_TAG} || true
                        docker rmi ${BACKEND_ECR_REPO}:latest || true
                        docker rmi ${FRONTEND_ECR_REPO}:${IMAGE_TAG} || true
                        docker rmi ${FRONTEND_ECR_REPO}:latest || true
                    """
                }
                echo 'Cleanup completed!'
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Backend Image: ${BACKEND_ECR_REPO}:${IMAGE_TAG}"
            echo "Frontend Image: ${FRONTEND_ECR_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Pipeline finished at: ' + new Date().toString()
            // Clean workspace
            cleanWs()
        }
    }
}

