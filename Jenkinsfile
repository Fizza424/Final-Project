pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "fizza424/dockerhub_repo:latest"
        EC2_USER = "ec2-user"
        EC2_HOST = "13.235.78.253"     // your EC2 IP
        S3_BUCKET = "fizza-devops-logs"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker image') {
            steps {
                powershell "docker build -t ${DOCKER_IMAGE} ."
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    powershell """
                        echo $env:DOCKER_PASS | docker login -u $env:DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }
        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-key']) {
                    powershell """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} `
                            "docker pull ${DOCKER_IMAGE} && `
                             docker stop nodeapp || true && `
                             docker rm nodeapp || true && `
                             docker run -d --name nodeapp -p 80:3000 ${DOCKER_IMAGE}"
                    """
                }
            }
        }
        stage('Backup logs to S3') {
            steps {
                sshagent(credentials: ['ec2-key']) {
                    powershell """
                        ssh ${EC2_USER}@${EC2_HOST} "docker logs nodeapp > app.log"
                        scp ${EC2_USER}@${EC2_HOST}:app.log .
                    """
                }
                withAWS(credentials: 'aws-creds', region: 'ap-south-1') {
                    powershell "aws s3 cp app.log s3://${S3_BUCKET}/"
                }
            }
        }
    }
}

