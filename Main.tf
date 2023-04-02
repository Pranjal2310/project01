provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA4FOICSYCXQSUQXXB"
  secret_key = "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"
  
}
resource "aws_vpc" "project" {                # Creating VPC here
   cidr_block       = "10.0.0.0/16"           ## Defining the CIDR block use 10.0.0.0/24 for demo
   instance_tenancy = "default"

   tags = {
    Name = "project"
  }
}


resource "aws_subnet" "privatesubnet" {
   vpc_id =  aws_vpc.project.id
   cidr_block = "10.0.1.0/24"             # CIDR block of private subnets
   tags = {
    Name = "private"
  }
 }

resource "aws_route_table" "PrivateRT" {    # Creating RT for Private Subnet
   vpc_id = aws_vpc.project.id
   route {
   cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
   #nat_gateway_id = aws_nat_gateway.NATgw.id
   }
   tags = {
    Name = "privaRT"
  }
 }

resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnet.id
    route_table_id = aws_route_table.PrivateRT.id
 }

 # security group
resource "aws_security_group" "sec_grp" {
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.project.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.project.cidr_block]
   
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks      = [aws_vpc.project.cidr_block]
   
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "sec_grp"
  }
}

resource "aws_lambda_function" "suyog_lambda" {
  filename         = "xyz_lambda.zip"
  function_name    = "suyog_lambda"
  handler          = "abc_lambda.handler"
  runtime          = "python3.8"
  role             = aws_iam_role.example_lambda.arn
  source_code_hash = filebase64sha256("xyz_lambda.zip")
