# DevOps Project 2 - Trendify Application Deployment

## Application
Trendify - A React-based fashion e-commerce application deployed to production using Docker, Jenkins CI/CD, and Kubernetes on AWS EKS.

## Repository
Source: https://github.com/Vennilavanguvi/Trend.git

## Infrastructure (Terraform)
- AWS VPC with public subnet
- Internet Gateway and Route Table
- Security Group with ports 22, 80, 8080, 3000
- IAM Role with AdministratorAccess
- EC2 t3.small instance (Jenkins server)

## Docker Setup
- Base Image: nginx:alpine
- Custom nginx.conf serving app on port 3000
- .dockerignore to exclude unnecessary files

## DockerHub Repository
- Image: rajdevops5/devops-project-2-trend
- URL: https://hub.docker.com/r/rajdevops5/devops-project-2-trend

## Kubernetes (AWS EKS)
- Cluster: project2-eks-cluster (ap-south-2)
- Deployment: 2 replicas of trend container
- Service: LoadBalancer type on port 80 to 3000

## Jenkins CI/CD Pipeline
Declarative pipeline with 4 stages:
1. Checkout - Pull code from GitHub
2. Build Docker Image - Build and tag image
3. Push to DockerHub - Push image with build number and latest tag
4. Deploy to EKS - Update kubeconfig and apply k8s manifests
- GitHub webhook triggers auto build on every commit

## Monitoring
- Uptime Kuma running on port 3001
- Monitors Trendify app health every 60 seconds

## EC2 Details
- Jenkins: http://18.60.117.240:8080
- App: http://18.60.117.240:3000
- Monitoring: http://18.60.117.240:3001
