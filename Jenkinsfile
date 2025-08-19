pipeline {
  agent any

  parameters {
    string(name: 'DOCKERHUB_REPO', defaultValue: 'CHANGE_ME/docker-devops-demo', description: 'Docker Hub repo (username/repo)')
    string(name: 'APP_NAME',        defaultValue: 'devops-demo', description: 'Container name + log folder name on EC2')
    string(name: 'EC2_HOST',        defaultValue: 'CHANGE_ME.compute.amazonaws.com', description: 'EC2 Public DNS or IP')
    string(name: 'EC2_USER',        defaultValue: 'ec2-user', description: 'EC2 SSH user (Amazon Linux = ec2-user, Ubuntu = ubuntu)')
    string(name: 'HOST_PORT',       defaultValue: '80', description: 'Host port on EC2')
    string(name: 'CONTAINER_PORT',  defaultValue: '3000', description: 'Container port exposed by the app')
    string(name: 'AWS_REGION',      defaultValue: 'ap-south-1', description: 'AWS region for S3 backups')
    string(name: 'S3_BUCKET',       defaultValue: 'CHANGE_ME-devops-demo-logs', description: 'S3 bucket for logs')
  }

  environment {
    DOCKER_IMAGE = "${params.DOCKERHUB_REPO}"
  }

  options { timestamps() }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Docker image') {
      steps {
        powershell '''
          docker --version
          docker build -t ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} -t ${env.DOCKER_IMAGE}:latest app
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          powershell '''
            echo $env:DH_PASS | docker login -u $env:DH_USER --password-stdin
            docker push ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}
            docker push ${env.DOCKER_IMAGE}:latest
          '''
        }
      }
    }

    stage('Deploy to EC2') {
      steps {
        withCredentials([file(credentialsId: 'ec2-key', variable: 'EC2_PEM')]) {
          powershell '''
            $ErrorActionPreference = 'Stop'
            scp -o StrictHostKeyChecking=no -i $env:EC2_PEM deploy/deploy.sh ${env.EC2_USER}@${params.EC2_HOST}:/tmp/deploy.sh
            ssh -o StrictHostKeyChecking=no -i $env:EC2_PEM ${env.EC2_USER}@${params.EC2_HOST} "chmod +x /tmp/deploy.sh && DOCKER_IMAGE=${env.DOCKER_IMAGE} APP_NAME=${params.APP_NAME} HOST_PORT=${params.HOST_PORT} CONTAINER_PORT=${params.CONTAINER_PORT} /tmp/deploy.sh ${env.BUILD_NUMBER}"
          '''
        }
      }
    }

    stage('Backup logs to S3') {
      steps {
        withCredentials([file(credentialsId: 'ec2-key', variable: 'EC2_PEM')]) {
          powershell '''
            $ErrorActionPreference = 'Stop'
            scp -o StrictHostKeyChecking=no -i $env:EC2_PEM deploy/backup_logs.sh ${env.EC2_USER}@${params.EC2_HOST}:/tmp/backup_logs.sh
            ssh -o StrictHostKeyChecking=no -i $env:EC2_PEM ${env.EC2_USER}@${params.EC2_HOST} "chmod +x /tmp/backup_logs.sh && S3_BUCKET=${params.S3_BUCKET} AWS_REGION=${params.AWS_REGION} APP_NAME=${params.APP_NAME} /tmp/backup_logs.sh"
          '''
        }
      }
    }
  }

  post {
    always { cleanWs() }
  }
}