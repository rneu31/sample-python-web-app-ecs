# sample-python-web-app-ecs


# Things Consciously Skipped Over / Done Imperfectly
- ECR configured to allow tag mutability
- ECR scanning turned off
- Logging and monitoring is half set up, pretty easy to fix
- Just using public subnets, instead of private subnet with a NAT gateway
- HTTP, no cert on the LB
- plaintext database password in the ssm parameter TF block



# Docker Notes
Docker Log In to ECR Locally
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 977173093032.dkr.ecr.us-east-1.amazonaws.com/playdotstakehome

docker build -t playdotsapp .

docker tag playdotsapp:latest 977173093032.dkr.ecr.us-east-1.amazonaws.com/playdotstakehome:v0.0.1

docker push 977173093032.dkr.ecr.us-east-1.amazonaws.com/playdotstakehome:v0.0.1



