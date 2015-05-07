provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

# CF-specific subnets

resource "aws_subnet" "lb" {
	vpc_id = "${var.aws_vpc_id}"
	cidr_block = "${var.network}.${var.offset}2.0/24"
	availability_zone = "${var.aws_subnet_cfruntime-2a_availability_zone}"
	tags {
		Name = "lb"
	}
}

output "aws_subnet_lb_id" {
  value = "${aws_subnet.lb.id}"
}

output "aws_subnet_lb_availability_zone" {
  value = "${var.aws_subnet_cfruntime-2a_availability_zone}"
}

# Routing table for public subnets

resource "aws_route_table" "public" {
	vpc_id = "${var.aws_vpc_id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${var.aws_internet_gateway_id}"
	}
}

resource "aws_route_table_association" "lb-public" {
	subnet_id = "${aws_subnet.lb.id}"
	route_table_id = "${var.aws_route_table_public_id}"
}

# Private subsets

resource "aws_subnet" "cfruntime-2a" {
	vpc_id = "${var.aws_vpc_id}"
	cidr_block = "${var.network}.${var.offset}3.0/24"
	availability_zone = "${var.aws_subnet_cfruntime-2a_availability_zone}"
	tags {
		Name = "cf1"
	}
}

output "aws_subnet_cfruntime-2a_id" {
  value = "${aws_subnet.cfruntime-2a.id}"
}

output "aws_subnet_cfruntime-2a_availability_zone" {
  value = "${aws_subnet.cfruntime-2a.availability_zone}"
}

resource "aws_subnet" "cfruntime-2b" {
	vpc_id = "${var.aws_vpc_id}"
	cidr_block = "${var.network}.${var.offset}4.0/24"
	availability_zone = "${var.aws_subnet_cfruntime-2b_availability_zone}"
	tags {
		Name = "cf2"
	}
}

output "aws_subnet_cfruntime-2b_id" {
  value = "${aws_subnet.cfruntime-2b.id}"
}

output "aws_subnet_cfruntime-2b_availability_zone" {
  value = "${aws_subnet.cfruntime-2b.availability_zone}"
}

resource "aws_subnet" "docker" {
	vpc_id = "${var.aws_vpc_id}"
	cidr_block = "${var.network}.${var.offset}5.0/24"
	availability_zone = "${aws_subnet.lb.availability_zone}"
	tags {
		Name = "docker"
	}
}

output "aws_subnet_docker_id" {
  value = "${aws_subnet.docker.id}"
}

output "aws_subnet_docker_availability_zone" {
  value = "${aws_subnet.docker.availability_zone}"
}

# Routing table for private subnets

resource "aws_route_table_association" "cfruntime-2a-private" {
	subnet_id = "${aws_subnet.cfruntime-2a.id}"
	route_table_id = "${var.aws_route_table_private_id}"
}

resource "aws_route_table_association" "cfruntime-2b-private" {
	subnet_id = "${aws_subnet.cfruntime-2b.id}"
	route_table_id = "${var.aws_route_table_private_id}"
}

resource "aws_route_table_association" "docker" {
	subnet_id = "${aws_subnet.docker.id}"
	route_table_id = "${var.aws_route_table_private_id}"
}

resource "aws_security_group" "cf" {
	name = "cf-${var.offset}-${var.aws_vpc_id}"
	description = "CF security groups"
	vpc_id = "${var.aws_vpc_id}"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = 4443
		to_port = 4443
		protocol = "tcp"
	}

	ingress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = 4222
		to_port = 25777
		protocol = "tcp"
	}

	ingress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = -1
		to_port = -1
		protocol = "icmp"
	}

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		self = "true"
	}

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "udp"
		self = "true"
	}

	tags {
		Name = "cf-${var.offset}-${var.aws_vpc_id}"
	}

}

output "aws_security_group_cf_name" {
  value = "${aws_security_group.cf.name}"
}

output "aws_security_group_cf_id" {
  value = "${aws_security_group.cf.id}"
}

resource "aws_eip" "cf" {
	vpc = true
}

output "aws_eip_cf_public_ip" {
  value = "${aws_eip.cf.public_ip}"
}
