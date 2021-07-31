### How to manage Docker containers in Amazon?
- ECS (Elastic Container Service)
- Fargate
- EKS (Elastic Kubernetes Service)




### ECS (Elastic Container Service)
ECS Cluster > EC2 Instance > ECS Agent


### ECS Task Definitions (like docker-compose.yml)




### ECR (Elastic Container Registry - like Docker Hub)
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 565447122202.dkr.ecr.eu-central-1.amazonaws.com
docker build -t demo .
docker tag demo:latest 565447122202.dkr.ecr.eu-central-1.amazonaws.com/demo:latest
docker push 565447122202.dkr.ecr.eu-central-1.amazonaws.com/demo:latest


### Actions
Create ECS cluster > check the EC2 ASG > ssh to the EC2 instance
> Create ECS Task > Run the Service 
### How to scale?
> Delete the current Service and create a new service with Application Load Balancer 
(+ configure the EC2s SGs to allow all traffic from the ABL)









