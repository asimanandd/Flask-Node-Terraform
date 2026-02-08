provider "aws" {
  region = var.region
}

resource "aws_security_group" "flask_node_sg" {
  name = "flask-node-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.flask_node_sg.name]

  user_data = <<-EOF
        #!/bin/bash
        apt update -y

        # Install Python
        apt install python3 python3-pip -y
        pip3 install flask

        # Install Node
        apt install nodejs npm -y

        # Install Git
        apt install git -y

        # Clone repo
        git clone https://github.com/asimanandd/Flask-Node-Terraform.git

        cd Flask-Node-Terraform/Backend
        pip3 install -r requirements.txt
        nohup python3 app.py &

        cd ../Frontend
        npm install
        nohup node server.js &
        EOF


  tags = {
    Name = "Flask-Node-Single-EC2"
  }
}
