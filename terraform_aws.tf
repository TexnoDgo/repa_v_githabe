#Inizialisation AWS provider
provider "aws" {
  region     = "eu-central-1"
}

# Search last version Ubuntu AMI
data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Output last version  ubuntu ami
output "test" {
  value = data.aws_ami.latest_ubuntu
}

# Create Instance
resource "aws_instance" "Web_Ubuntu" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver_sg.id]
  user_data              = file("user_data.sh")


  tags = {
    Name  = "Ubuntu_Web_Server"
    Owner = "Nikita"
  }

}

# Create Security Group
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

# Save terraform backup to S3 backet
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
