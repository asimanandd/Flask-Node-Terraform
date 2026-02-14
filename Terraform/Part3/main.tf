provider "aws" {
  region = var.region
}

# ---------------- ECR ----------------

resource "aws_ecr_repository" "backend_repo" {
  name = "flask-backend-repo"
}

resource "aws_ecr_repository" "frontend_repo" {
  name = "node-frontend-repo"
}

# ---------------- IAM ----------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRolePart3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------- ECS Cluster ----------------

resource "aws_ecs_cluster" "main" {
  name = "part3-ecs-cluster"
}

# ---------------- NETWORK ----------------

resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "ecs_subnet_1" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ecs_subnet_2" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
}

resource "aws_route_table" "ecs_rt" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }
}

resource "aws_route_table_association" "ecs_assoc_1" {
  subnet_id      = aws_subnet.ecs_subnet_1.id
  route_table_id = aws_route_table.ecs_rt.id
}

resource "aws_route_table_association" "ecs_assoc_2" {
  subnet_id      = aws_subnet.ecs_subnet_2.id
  route_table_id = aws_route_table.ecs_rt.id
}

# ---------------- SECURITY GROUP ----------------

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- TASK DEFINITIONS ----------------

resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "backend"
    image = "616812762117.dkr.ecr.ap-south-1.amazonaws.com/flask-backend-repo:latest"

    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]
  }])
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "frontend"
    image = "616812762117.dkr.ecr.ap-south-1.amazonaws.com/node-frontend-repo:latest"

    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]

    environment = [{
      name  = "BACKEND_HOST"
      value = "localhost"
    }]
  }])
}

# ---------------- SERVICES ----------------

resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
