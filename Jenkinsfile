pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "fizza424/final-project"   // change if repo name is different
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Fizza424/Final-Project.git',
                    credentialsId: 'pat'
            }
        }

        stage('List files in workspace') {
            steps {
                powershell "dir"
            }
        }

        stage('Build Docker image') {
            steps {
                powershell """
                    docker build -t $env:DOCKER_IMAGE .
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    powershell """
                        echo "$env:DOCKER_PASS" | docker login -u "$env:DOCKER_USER" --password-stdin
                        docker push $env:DOCKER_IMAGE
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                powershell """
                    echo "Here you can run SSH/Ansible/Terraform commands to deploy to EC2"
                """
            }
        }

        stage('Backup logs to S3') {
            steps {
                powershell """
                    aws s3 cp C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\devops-demo-pipeline2\\logs s3://your-s3-bucket-name/ --recursive
                """
            }
        }
    }
}


