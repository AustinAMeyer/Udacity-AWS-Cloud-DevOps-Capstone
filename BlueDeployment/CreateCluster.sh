aws eks create-cluster \
--region us-west-2 \
--name Kubernetes-Capstone \
--role-arn arn:aws:iam::257587651812:role/Kubernetes-Capstone \
--resources-vpc-config \
subnetIds=subnet-fe62c8a3,subnet-4313d609,subnet-8bdb00f3,subnet-a5af8d8e,securityGroupIds=sg-0e78cc28143cae9c6