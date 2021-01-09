pipeline {
    agent any

    stages {
        stage('Lint Dockerfile') {
            steps {
                script {
                    'hadolint Dockerfile'
                }    
            }
        }
    stage('Build Docker Image') {
            steps {
                sh 'docker build --tag=udacity_aws_cloud_devops_capstone .'
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                    dockerpath=austinmeyer/udacity_aws_cloud_devops_capstone
                    docker login -u austinmeyer --password $DockerPassword
                    docker tag udacity_aws_cloud_devops_capstone $dockerpath
                    '''
            }
        }
        stage('Config AWS EKS') {
            steps {
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials'){
                    sh '''
                        apk add --no-cache python3 py3-pip
                        python3 -m pip install awscli
                        aws eks \
                        --region us-west-2 update-kubeconfig \
                        --name Kubernetes-Capstone
                       '''
                }
            }
        }
        
    }
}