variable "cidr_block" {
  description = "the range of the cidr block"
}

variable "subnet1_cidr_block" {
  description = "range of subnet1 cidr block"
}

variable "subnet2_cidr_block" {
  description = "range of subnet2 cidr block"
}

variable "subnet1_az" {
  description = "availibility zone of subnet1"
}

variable "subnet2_az" {
  description = "availibility zone of subner 2"
}

variable "rt_cidr_block" {
  description = "cidr block for route table"
}

variable "ami" {
  description = "ami value"
}

variable "instance_type" {
  description = "instance type"
}

variable "s3" {
  description = "s3 bucket"
}

variable "ingeg" {
  description = "value for ingress and egress"
}