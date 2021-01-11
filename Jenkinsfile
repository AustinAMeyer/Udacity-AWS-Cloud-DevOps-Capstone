pipeline {
    agent any

    stages {
        stage('install requirements') {
                steps {
                    script {
                        sh '''
                            apk add --no-cache python3 py3-pip
                            python3 -m pip install awscli
                            curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
                            chmod +x ./kubectl
                            mv ./kubectl /usr/local/bin/kubectl
                        '''
                    }    
                }
            }   
        stage('Lint Blue Deployment Dockerfile') {
                steps {
                    script {
                       'hadolint ./BlueDeployment/Dockerfile'   
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
        stage('Clean Up Blue Image') {
                steps { 
                    sh 'docker rmi austinmeyer/udacity-devops-capstone-blue'
                }
            }
        stage('Clean Up Blue Image') {
                steps { 
                    sh 'docker rmi austinmeyer/udacity-devops-capstone-green'
                }
            }
        stage('Build Blue Deployment Docker Image') {
                steps {
                    sh '''
                        ls
                        cd ./BlueDeployment
                        ls
                        docker build --tag=udacity-devops-capstone-blue .
                    '''
                }
            }
        stage('Push Blue Image') {
            steps {
                sh '''
                    dockerpathblue=austinmeyer/udacity-devops-capstone-blue
                    docker login -u austinmeyer --password $DockerPassword
                    docker tag udacity-devops-capstone-blue $dockerpathblue
                    docker image push $dockerpathblue
                    cd ..
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
                    kubectl get nodes
                    kubectl get deployment
                    kubectl get pod -o wide
                    kubectl get services
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
                    docker build --tag=udacity-devops-capstone-green .
                   '''
            }
        }

        stage('Push Green Image') {
            steps {
                sh '''
                    dockerpathgreen=austinmeyer/udacity-devops-capstone-green
                    docker login -u austinmeyer --password $DockerPassword
                    docker tag udacity-devops-capstone-green $dockerpathgreen
                    docker image push $dockerpathgreen
                    cd ..
                    '''
            }
        }
        stage('Config AWS EKS for green') {
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
                    if ["$MoveToProduction" == "True"]
                    then
                        aws eks --region us-west-2 update-kubeconfig \
                        --name Kubernetes-Capstone
                        kubectl config use-context arn:aws:eks:us-west-2:257587651812:cluster/Kubernetes-Capstone
                        kubectl apply -f ./GreenDeployment/deployGreen.yml
                        kubectl get nodes
                        kubectl get deployment
                        kubectl get pod -o wide
                    else
                        echo "It is not time to move to production yet"
                    fi
                   '''
                }
            }
        }
        stage('Switch Traffic To Green Deployment from blue'){
            steps{
                withAWS(region: 'us-west-2', credentials: 'AWSCLICredentials'){
                    sh '''
                        if ["$MoveToProduction" == "True"]
                        then
                            kubectl apply -f ./Green/serviceGreen.yaml
                            kubectl get services
                        else
                            echo "It is not time to move to production yet"
                        fi
                       '''
                }
            }
        }
    }
}