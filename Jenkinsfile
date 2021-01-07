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
        stage('Push Image') {
            steps {
                sh '''
                    dockerpath=austinmeyer/udacity_aws_cloud_devops_capstone
                    docker login -u austinmeyer --password $DockerPassword
                    docker tag udacity_aws_cloud_devops_capstone $dockerpath
                    '''
            }
        }
        stage('Deploy to AWS EKS') {
            steps {
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials'){
                    sh '''
                        aws s3 ls
                       '''
            }
        }
    }
    }
}