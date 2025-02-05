resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet1_cidr_block
  availability_zone       = var.subnet1_az
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet2_cidr_block
  availability_zone       = var.subnet2_az
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "mysg" {
  name   = "websg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingeg
  }

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingeg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_s3_bucket" "mys3" {
  bucket = var.s3
}

resource "aws_s3_bucket_public_access_block" "s3_access" {
  bucket = aws_s3_bucket.mys3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.mys3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_access,
  ]

  bucket = aws_s3_bucket.mys3.id
  acl    = "public-read"
}

resource "aws_instance" "webserver1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.subnet1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.subnet2.id
  user_data              = base64encode(file("userdata1.sh"))
}

#to create application load balancer
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  tags = {
    Name = "myalb"
  }
}

resource "aws_lb_target_group" "alb_target" {
  name     = "mytargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "alb_attach1" {
  target_id        = aws_instance.webserver1.id
  target_group_arn = aws_lb_target_group.alb_target.arn
  port             = 80
}

resource "aws_lb_target_group_attachment" "alb_attach2" {
  target_id        = aws_instance.webserver2.id
  target_group_arn = aws_lb_target_group.alb_target.arn
  port             = 80
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.alb_target.arn
    type             = "forward"
  }
}

output "loadbalancerDNS" {
  value = aws_lb.myalb.dns_name
}