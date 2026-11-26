resource "aws_vpc" "myVpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "myvpc"
  }

}

resource "aws_subnet" "myPublicSubnet1" {
  vpc_id     = aws_vpc.myVpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet-1"
  }

}

resource "aws_subnet" "myPublicSubnet2" {
  vpc_id     = aws_vpc.myVpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public-subnet-2"
  }

}


resource "aws_security_group" "mySecurity" {
  name        = "main"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVpc.id

  tags = {
    Name = "Launch_wizard-1"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = aws_vpc.myVpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  description = "Allow HTTP traffic"

}

resource "aws_vpc_security_group_ingress_rule" "allow_nginx" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = var.cidr_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  description = "Allow nginx traffic"

}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = var.cidr_ipv4

  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  description = "Allow SSH "
}

resource "aws_vpc_security_group_egress_rule" "all_traffic" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = var.cidr_ipv4
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

}

resource "aws_route_table" "myRoute" {
  vpc_id = aws_vpc.myVpc.id

  route {
    cidr_block = var.cidr_ipv4
    gateway_id = aws_internet_gateway.myIgw.id
  }


  tags = {
    Name = "my-rt"
  }
}

resource "aws_internet_gateway" "myIgw" {
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table_association" "assoociation" {
  subnet_id      = aws_subnet.myPublicSubnet1.id
  route_table_id = aws_route_table.myRoute.id
}

resource "aws_internet_gateway_attachment" "attachment" {
  internet_gateway_id = aws_internet_gateway.myIgw.id
  vpc_id              = aws_vpc.myVpc.id
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "MypairKey.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "aws_instance" "myInstance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.mySecurity.id]
  subnet_id                   = aws_subnet.myPublicSubnet1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
             #!/bin/bash
             sudo apt update -y
             sudo apt install nginx -y
             sudo systemctl start nginx
             EOF

  # user_data = file("./web_server.sh")

  tags = {
    Name = "Demon-server"
  }
  depends_on = [
    local_file.private_key_pem
  ]

}