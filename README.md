# minecraft_with_terraform
Create minecraft on aws to learn how to use terraform.

## Description
Build a minecraft server using terraform.
Architecture
- Create one VPC and one subnet
- Set up a static IP using Elastic IP and NLB.
- The target of NLB is the entire VPC.
- Both NLB listener and target are open only on the microcontroller port
- Select Fargate for the ECS cluster
- The container image is https://github.com/itzg/docker-minecraft-server

## Requirement
- Terraform v1.0.11

## Install