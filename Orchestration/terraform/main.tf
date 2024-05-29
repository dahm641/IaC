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

      egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
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

# user data

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              touch test.txt
              sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

              sudo DEBIAN_FRONTEND=noninteractive apt install nginx -y

              sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default.bak

              sudo sed -i '51s/.*/\t        proxy_pass http:\/\/localhost:3000;/' /etc/nginx/sites-available/default

              sudo systemctl restart nginx

              sudo systemctl enable nginx

              sudo apt install git -y


              cd /

              sudo git clone https://github.com/dahm641/tech258_sparta_test_app

              cd /tech258_sparta_test_app/app

              curl -fsSL https://deb.nodesource.com/setup_20.x | sudo DEBIAN_FRONTEND=noninteractive -E bash - && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

              export DB_HOST=mongodb://${aws_instance.dan-db.private_ip}:27017/posts

              cd /tech258_sparta_test_app/app

              sudo -E npm install
              sudo -E npm install -g pm2
              sudo pm2 kill
              sudo -E pm2 start app.js
              sudo -E pm2 restart app.js
              EOF


# security group
    security_groups = [aws_security_group.dan-app-sg.id]

# key pair
    key_name = "tech258-joshg"
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
	ami = var.db_ami_id

# size - t2 micro
	instance_type = "t2.micro"

# associate public ip with instance
	associate_public_ip_address = false

# security group using id
    security_groups = [aws_security_group.dan-db-sg.id]

# key pair
    key_name = "tech258-joshg"
# name resource
	tags = {
		Name = "dan-terraform-tech258-db"
	}
}

provider "github" {
	token = var.github_token
}

resource "github_repository" "IaC-github-automated-repo" {
	name        = "IaC-github-automated-repo"
	description = "This is an example repository created using Terraform"
	private     = false
}

## ========INTERNET GATEWAY========
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.Dans-VPC.id
}

## ========ROUTE TABLE========
resource "aws_route_table" "app-route-table" {
    vpc_id = aws_vpc.Dans-VPC.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "route_table"
    }
}
## ========ASSOCIATE SUBNET WITH ROUTE TABLE========
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.app-route-table.id
}


# terraform {
#   backend "s3" {
#     bucket = "tech258-dan-terraform-bucket"
#     key = "dev/terraform.tfstate"
#     region = "eu-west-1"
#   }
# }