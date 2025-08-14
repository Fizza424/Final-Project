# DevOps Demo: Node.js → Docker → Jenkins (Windows) → EC2 → S3

This repo supports a live demo pipeline:
- Build a Docker image on Jenkins (Windows + Docker Desktop)
- Push to Docker Hub
- SSH deploy to EC2 (Amazon Linux) and run the container on port 80
- Backup container logs to Amazon S3

## Prerequisites
- **Docker Hub** account (public repo recommended for simplicity)
- **AWS**: EC2 key pair (.pem), Security Group allowing 22 (SSH) + 80 (HTTP), S3 bucket for logs
- **EC2**: Amazon Linux 2023 t2.micro is fine
- **IAM**: an Instance Role attached to EC2 with S3 write permissions
- **Jenkins on Windows** with: Git, Pipeline, Credentials Binding plugins, OpenSSH client, Docker Desktop (Linux containers)

## Jenkins credentials (create before first run)
- `dockerhub-creds` – Username/Password for Docker Hub
- `ec2-key` – Secret file: upload your `.pem` EC2 key

## Configure job parameters (per environment)
- `DOCKERHUB_REPO` = `your-dockerhub-username/docker-devops-demo`
- `EC2_HOST` = EC2 public DNS (e.g. `ec2-3-120-...compute.amazonaws.com`)
- `S3_BUCKET` = your logs bucket (e.g. `fizza-devops-logs`)
- `AWS_REGION` = e.g. `ap-south-1`
- Others as needed

## Run locally (optional)
```bash
cd app
npm ci
npm start
# open http://localhost:3000/health