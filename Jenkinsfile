pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "fizza424/dockerhub_repo:latest"
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
                    docker build -t ${env.DOCKER_IMAGE} .
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    powershell """
                        echo "$env:DOCKER_PASS" | docker login -u "$env:DOCKER_USER" --password-stdin
                        docker push ${env.DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                powershell 'echo "Deploy step placeholder (to be filled)"'
            }
        }

        stage('Backup logs to S3') {
            steps {
                powershell 'echo "Backup step placeholder (to be filled)"'
            }
        }
    }
}



