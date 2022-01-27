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

# Create tempfile
data "template_file" "init" {
  template = "${file("user_data_script.sh.tpl")}"

  vars = {
    some_address = var.latest_ubuntu_version
  }
}


# Create Instance
resource "aws_instance" "Web_Ubuntu" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver_sg.id]
  user_data		 = "${data.template_file.init.rendered}"

  tags = {
    Name  = "Ubuntu_Web_Server"
    Owner = "Nikita"
  }

}

# Create Security Group
resource "aws_security_group" "my_webserver_sg" {
  name        = "my_webserver_sg"
  description = "Allow TLS inbound traffic"

  ingress { # input traffic
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # input traffic

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # input traffic
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Output traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

# Atach eip to instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.Web_Ubuntu.id
  allocation_id = "eipalloc-0f490853d4a6dff4d"
}

# Save terraform backup to S3 backet
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state-nikita"
    key            = "foo/terraform.tfstate"
    region         = "eu-central-1"
  }
}
