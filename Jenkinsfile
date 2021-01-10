pipeline {
    agent any                 
    stages {
        stage('install requirements') {
                steps {
                    script {
                        sh '''
                            apk add --no-cache python3 py3-pip
                            python3 -m pip install awscli
                        '''
                    }    
                }
            }   
        stage('Lint Blue Deployment Dockerfile') {
                steps {
                    script {
                        'hadolint ./GreenDeployment/Dockerfile'
                    }    
                }
            }
        stage('Lint Green Deployment Dockerfile') {
                steps {
                    script {
                        'hadolint ./GreenDeployment/Dockerfile'
                    }    
                }
            }
        stage('Build Blue Deployment Docker Image') {
                steps {
                    sh '''
                        ls
                        cd ./BlueDeployment
                        ls
                        docker build --tag=udacity_aws_cloud_devops_capstone_blue .
                        cd ..
                    '''
                }
            }
        stage('Push Image') {
            steps {
                sh '''
                    dockerpath=austinmeyer/udacity_aws_cloud_devops_capstone_blue
                    docker login -u austinmeyer --password $DockerPassword
                    docker tag udacity_aws_cloud_devops_capstone_blue $dockerpath
                    '''
            }
        }
        stage('Config AWS EKS for Blue') {
            steps {
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials'){
                    sh '''
                        aws eks update-kubeconfig\
                        --region us-west-2 \
                        --name Kubernetes-Capstone
                       '''
                }
            }
        }
        stage('Deploy Blue') {
            steps {
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials') {
                sh '''
                    aws eks --region us-west-2 update-kubeconfig \
                    --name Kubernetes-Capstone
                    kubectl config use-context arn:aws:eks:us-west-2:257587651812:cluster/Kubernetes-Capstone
                    kubectl apply -f ./BlueDeployment/deployBlue.yml
                    kubectl apply -f ./BlueDeployment/serviceBlue.yml
                   '''
                }
            }
        }
        stage('Build Green Deployment Docker Image') {
            steps {
                sh '''
                    ls
                    cd ./GreenDeployment
                    ls
                    docker build --tag=udacity_aws_cloud_devops_capstone_green .
                    cd ..
                   '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                    dockerpath=austinmeyer/udacity_aws_cloud_devops_capstone_green
                    docker login -u austinmeyer --password $DockerPassword
                    docker tag udacity_aws_cloud_devops_capstone_green $dockerpath
                    '''
            }
        }
        stage('Config AWS EKS') {
            steps {
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials'){
                    sh '''
                        aws eks update-kubeconfig \
                        --region us-west-2 \
                        --name Kubernetes-Capstone
                       '''
                }
            }
        }
        stage('Deploy Green') {
            steps {
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials') {
                sh '''
                    aws eks --region us-west-2 update-kubeconfig \
                    --name Kubernetes-Capstone
                    kubectl config use-context arn:aws:eks:us-west-2:257587651812:cluster/Kubernetes-Capstone
                    kubectl apply -f ./GreenDeployment/deployGreen.yml
                   '''
                }
            }
        }
        stage('Switch Traffic To Green Deployment'){
            steps{
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials'){
                    sh '''
                        if ["$MoveToProduction" == "True"]
                        then
                            kubectl apply -f ./Green/serviceGreen.yaml
                        else
                            echo "It is not time to move to production yet"
                        fi
                       '''
                }
            }
        }
    }
}