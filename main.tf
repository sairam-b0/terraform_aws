resource "aws_vpc" "myVpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name= "myvpc"
  }

}

resource "aws_subnet" "myPublicSubnet1" {
  vpc_id = aws_vpc.myVpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name= "public-subnet-1"
  }

}

resource "aws_subnet" "myPublicSubnet2" {
  vpc_id = aws_vpc.myVpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name= "public-subnet-2"
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
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = aws_vpc.myVpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all_traffic" {
  security_group_id = aws_security_group.mySecurity.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_route_table" "myRoute" {
  vpc_id = aws_vpc.myVpc.id

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIgw.id
  }


  tags = {
    Name= "my-rt"
  }
}

resource "aws_internet_gateway" "myIgw" {
  tags = {
    Name= "my-igw"
  }
}

resource "aws_route_table_association" "assoociation" {
  subnet_id = aws_subnet.myPublicSubnet1.id
  route_table_id = aws_route_table.myRoute.id
}

resource "aws_internet_gateway_attachment" "attachment" {
  internet_gateway_id = aws_internet_gateway.myIgw.id
  vpc_id              = aws_vpc.myVpc.id
}



resource "aws_instance" "example" {
  ami = "ami-01d03173bef0a0a89"
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.mySecurity.id ]
  subnet_id = aws_subnet.myPublicSubnet1.id
  associate_public_ip_address = true

  tags = {
    Name= "server"
  }

}