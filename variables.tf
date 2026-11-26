variable "aws" {
  type    = string
  default = "ap-south-1"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "ami" {
  type    = string
  default = "ami-01d03173bef0a0a89"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "cidr_ipv4" {
  type    = string
  default = "0.0.0.0/0"
}

# variable "key_name" {
#   type    = string
#   default = "private-key"
# }