pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "fizza424/dockerhub_repo:latest"
        EC2_USER = "ec2-user"
        EC2_HOST = "13.235.78.253"
        PEM_FILE = "C:/Users/HP/Downloads/fizza-ec2-key.pem"
        S3_BUCKET = "fizza-devops-logs"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'pat',
                    url: 'https://github.com/Fizza424/Final-Project.git'
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    // use ${} so Jenkins expands the environment variable correctly
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no -i ${PEM_FILE} ${EC2_USER}@${EC2_HOST} \
                    "docker pull ${DOCKER_IMAGE} && \
                     docker stop nodeapp || true && \
                     docker rm nodeapp || true && \
                     docker run -d --name nodeapp -p 80:3000 ${DOCKER_IMAGE}"
                """
            }
        }

        stage('Backup logs to S3') {
            steps {
                sh """
                ssh -i ${PEM_FILE} ${EC2_USER}@${EC2_HOST} "docker logs nodeapp > app.log"
                scp -i ${PEM_FILE} ${EC2_USER}@${EC2_HOST}:app.log .
                aws s3 cp app.log s3://${S3_BUCKET}/
                """
            }
        }
    }
}

