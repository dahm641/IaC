# create service on the cloud - launch an ec2 instance on aws
# which region
provider "aws"{

	region = "eu-west-1"
}
# MUST NOT HARD CODE ANY KEYS!
# MUST NOT PUSH ANYTHING TO GITHUB UNTIL WE HAVE CREATED A .gitignore file


# create vpc

resource "aws_vpc" "Dans-VPC" {

    cidr_block = var.vpc_cidr_block
}

# create subnet public (refers back to vpc being made)

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.Dans-VPC.id
    cidr_block = var.public_subnet_cidr_block
}

# create subnet private (refers back to vpc being made)

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.Dans-VPC.id
    cidr_block = var.private_subnet_cidr_block
}

# create security groups
# app
resource "aws_security_group" "dan-app-sg" {
  name        = var.app_sg_name
  description = var.app_sg_description
  vpc_id      = aws_vpc.Dans-VPC.id  

  # inbound rules
  dynamic "ingress" {
    for_each = var.app_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

# db
resource "aws_security_group" "dan-db-sg" {
  name        = var.db_sg_name
  description = var.db_sg_description
  vpc_id      = aws_vpc.Dans-VPC.id  

  # inbound rules
  dynamic "ingress" {
    for_each = var.db_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}


# create app instance

resource "aws_instance" "dan-app"{

# subnet (refers back to public subnet being made)
    subnet_id = aws_subnet.public_subnet.id
# which type of instance - AMI to use
	# ami = "ami-02f0341ac93c96375"
	ami = var.app_ami_id

# size - t2 micro
	instance_type = "t2.micro"

# associate public ip with instance
	associate_public_ip_address = true

# security group
    security_groups = [aws_security_group.dan-app-sg.id]

# key pair
    key_name = "tech258"
# name resource
	tags = {
		Name = "dan-terraform-tech258-app"
	}
}

# create db instance

resource "aws_instance" "dan-db"{

# subnet (refers back to private subnet being made)
    subnet_id = aws_subnet.private_subnet.id
# which type of instance - AMI to use
	ami = var.app_ami_id

# size - t2 micro
	instance_type = "t2.micro"

# associate public ip with instance
	associate_public_ip_address = true

# security group using id
    security_groups = [aws_security_group.dan-db-sg.id]

# key pair
    key_name = "tech258"
# name resource
	tags = {
		Name = "dan-terraform-tech258-db"
	}
}