# Project Overview 
I created this project to complete the final Capstone project for [Udacity's AWS Cloud DevOps course](https://www.udacity.com/course/cloud-dev-ops-nanodegree--nd9991). It uses the Blue Green methodology to take traffic to move from one docker instance to the other.

This is the criteria for which I was graded on: [rubric](https://review.udacity.com/#!/rubrics/2577/view).
# Objectives
* Working in AWS
* Using Jenkins to implement Continuous Integration and Continuous Deployment
* Building pipelines
* Working with CloudFormation to deploy clusters
* Building Kubernetes clusters
* Building Docker containers in pipelines

# Tools Used
* Git & GitHub
* AWS & AWS-CLI
* Nginx
* pip3
* Hadolint
* Docker & Docker-Hub Registry
* Jenkins
* Kubernetes CLI (kubectl)
* EKS
* EKSCTL
* CloudFormation
* BASH

# Procedure

### Build Jenkins Server with Blue Ocean plugin in EC2
Create an Amazon Linux 2 instance in EC2

SSH into EC2 instance using:
`ssh -i key.pem ec2-user@Instance.Public.Hostname`

```shell
# Install Docker on ec2 instance
sudo yum install docker

## Set up user permissions for docker with ec2-user
sudo usermod -a -G docker ec2-user
exit
 
## Enable docker service on ec2 instance
sudo systemctl enable docker
 
## Start docker service on ec2 instance
sudo systemctl start docker
 
## Run docker jenkins blueocean container on ec2 instance
docker run -u root --rm -d -p 8080:8080 -p 50000:50000 --name jenkins -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean
 
## get the administrator password for initial login to Jenkins UI
docker exec -it jenkins bash
cat /var/jenkins_home/secrets/initialAdminPassword
```
At this point you should be able to go to Instance.Public.Hostname:8080 and get the login page for Jenkins and use the initial password you rreceived from the terminal.

Now you just need to go through the prompts and select install suggested plugins.

Once you are in Jenkins you need to install the [AWS-Credential-Plugin AKA AWS Steps](https://github.com/jenkinsci/pipeline-aws-plugin) from the plugin store. Here is a [link](https://plugins.jenkins.io/pipeline-aws/) to the plugin store info for this plugin.

Now all you need to do is provide your AWS Credentials, Docker Credentials, connection to your Github repository, and environment variable named MoveToProduction (This will be set to True when you are ready to move the Green over from the Blue build.

### Build AWS Cluster using EKSCTL

First step for this is installing [homebrew](https://brew.sh)

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

Then you will need to add the [weaveworks tap](https://github.com/weaveworks/homebrew-tap)

`brew tap weaveworks/tap`

Then you will need to install [EKSCTL](https://github.com/weaveworks/eksctl)

`brew install weaveworks/tap/eksctl`

Now that you have EKSCTL you should be able to run [my script](https://github.com/AustinAMeyer/Udacity-AWS-Cloud-DevOps-Capstone/blob/master/BlueDeployment/CreateCluster.sh) to build a EKS cluster in AWS. Keep in mind it will take some time to build the cluster (Expect about 30+ minutes)

Final step is to go to the AWS console and make modifications to the security group that was created and allow inbound traffic on port 80 to the nodes.

### Finish

At this point you should be able to run it through the pipeline in Jenkins and see something along the lines of the below

![picture alt](https://github.com/AustinAMeyer/Udacity-AWS-Cloud-DevOps-Capstone/blob/master/Screenshots/Screen%20Shot%202021-01-11%20at%203.43.48%20PM.png "Fully functioning pipeline")

If you set the MoveToProduction Environment Variable to False in Jenkins you would see the below webpage because it built the Blue but didn't move over to the Green

![picture alt](https://github.com/AustinAMeyer/Udacity-AWS-Cloud-DevOps-Capstone/blob/master/Screenshots/WebpageAfterDeployingBlue.png "Blue Webpage")

If you set the MoveToProduction Environment Variable to True in Jenkins you would see the below webpage because it built the Blue and changed the service over to the Green

![picture alt](https://github.com/AustinAMeyer/Udacity-AWS-Cloud-DevOps-Capstone/blob/master/Screenshots/WebpageAfterChangingToGreen.png "Green Webpage")
