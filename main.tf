###### Terraform Module to install LAMP on EC2 #######
provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "ec2-lamp" {
  ami                    = "ami-0a6dc7529cd559185" #ami-0a6dc7529cd559185
  instance_type          = "${var.instance_type}"
  subnet_id              = "subnet-f4fa969e"
  key_name               = "${var.key_pair}"
  vpc_security_group_ids = ["${aws_security_group.lamp-sec-grp.id}"]

 tags = {
    Name = "lamp-${var.name}"
  }

}


#Create Security Group
resource "aws_security_group" "lamp-sec-grp" {
  name        = "lamp Security Group"
  description = "lamp access"
  vpc_id      = "vpc-97a723fd"

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lamp Security Group"
  }

}

# Create Elastic Loadbalancer
resource "aws_elb" "web" {
name = "lamp-elb"

subnets = ["subnet-f4fa969e"]

security_groups = ["${aws_security_group.lamp-sec-grp.id}"]

listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  # The instance is registered automatically

  instances                   = ["${aws_instance.ec2-lamp.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}
