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

![Alt text](https://github.com/katsuyukishimbo/minecraft_with_terraform/blob/main/structure.png "Aws structure")


## Requirement
- Terraform v1.0.11
- hashicorp/aws v3.68.0
  - https://registry.terraform.io/providers/hashicorp/aws/latest

## Demo

| variable | input |
| --- | --- |
| aws-availability-zone | ap-northeast-1a |
| aws-ecs-task-name | mincraft |
| aws-region| ap-northeast-1 |


## Install

```
brew install terraform
```

## How it works

Set own aws account.
https://github.com/katsuyukishimbo/minecraft_with_terraform/blob/main/provider.tf#L13


```
terraform init
```

```
terraform plan
```

```
terraform apply
```

Setting done.
Access AWS Management Console and then check Elastic IPs.([Network & Security] → [Elastic IPs])
Enter that IP in the server address of Minecraft and start it！