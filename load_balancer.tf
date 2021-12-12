resource "aws_eip" "minecraft-global-ip" {
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    Name = "minecraft-on-ecs"
  }
  depends_on = [aws_internet_gateway.minecraft-gw]
}

resource "aws_internet_gateway" "minecraft-gw" {
  vpc_id = aws_vpc.ecs-minecraft.id

  tags = {
    Name = "minecraft-on-ecs"
  }
}

resource "aws_route_table" "minecraft-public" {
  vpc_id = aws_vpc.ecs-minecraft.id
  
  tags = {
    Name = "example-rt-pub"
  }
}

resource "aws_route" "minecraft-public" {
  route_table_id         = aws_route_table.minecraft-public.id
  gateway_id             = aws_internet_gateway.minecraft-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "minecraft-public_a" {
  route_table_id = aws_route_table.minecraft-public.id
  subnet_id      = aws_subnet.ecs-minecraft.id
}

resource "aws_lb_target_group" "minecraft-ecs-target" {
  target_type = "ip"
  name        = "minecraft-ecs"
  protocol    = "TCP"
  port        = 25565
  vpc_id      = aws_vpc.ecs-minecraft.id

  health_check {
    protocol = "TCP"
  }

  tags = {
    Name = "minecraft-on-ecs"
  }
}

resource "aws_lb" "minecraft-lb" {
  load_balancer_type = "network"
  name               = "minecraft-lb"
  internal           = false
  ip_address_type    = "ipv4"

  subnet_mapping {
    subnet_id     = aws_subnet.ecs-minecraft.id
    allocation_id = aws_eip.minecraft-global-ip.id
  }

  tags = {
    Name = "minecraft-on-ecs"
  }
}

resource "aws_lb_listener" "minecraft-lb" {
  load_balancer_arn = aws_lb.minecraft-lb.id
  protocol          = "TCP"
  port              = "25565"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minecraft-ecs-target.arn
  }

  tags = {
    Name = "minecraft-on-ecs"
  }
}