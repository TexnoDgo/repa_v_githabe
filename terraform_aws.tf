provider "aws" {
  region     = "eu-central-1"
}

resource "aws_instance" "Web_Ubuntu" {
  ami                    = "ami-0d527b8c289b4af7f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver_sg.id]
  user_data              = <<EOF
#!/bin/bash
# Update system
sudo apt update
# Install docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
# Install docker_compose
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Docker pull image
docker pull texnodgo/apache2-image
# Docker run
sudo docker run -d -p 80:80 texnodgo/apache2-image:latest
EOF


  tags = {
    Name  = "Ubuntu_Web_Server"
    Owner = "Nikita"
  }

}

resource "aws_security_group" "my_webserver_sg" {
  name        = "my_webserver_sg"
  description = "Allow TLS inbound traffic"

  ingress { # приходящий трафик
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # приходящий трафик
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # приходящий трафик
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # уходящий трафик
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

#resource "aws_eip_association" "eip_assoc" {
#  instance_id   = aws_instance.Web_Ubuntu.id
#  allocation_id = eipalloc-0c49fdfe9affb3dd3
#}


terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state-nikita"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks-nikita"
    encrypt        = true
  }
}
