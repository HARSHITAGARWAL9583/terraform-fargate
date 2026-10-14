# ─── Data Source: Latest Amazon Linux 2023 AMI ────────────────────────────────
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ─── Security Group for NAT Instance ──────────────────────────────────────────
resource "aws_security_group" "nat" {
  name        = "${var.project_name}-nat-sg"
  description = "Security group for NAT instance - allows outbound traffic from private subnets"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic from private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    description = "Allow all outbound internet traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-nat-sg"
  }
}

# ─── EC2 NAT Instance ─────────────────────────────────────────────────────────
resource "aws_instance" "nat" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.nat.id]

  # REQUIRED: Disable source/destination check so instance can route packets
  source_dest_check = false

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # 1. Enable IPv4 forwarding in kernel
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ip-forward.conf
    sysctl -p /etc/sysctl.d/99-ip-forward.conf

    # 2. Dynamically determine default network interface (e.g. eth0 or ens5)
    PRIMARY_IF=$(ip -4 route list 0/0 | awk '{print $5; exit}')
    if [ -z "$PRIMARY_IF" ]; then
      PRIMARY_IF="eth0"
    fi

    # 3. Install iptables services and configure masquerading
    dnf install -y iptables-services || yum install -y iptables-services
    iptables -t nat -F
    iptables -t nat -A POSTROUTING -o "$PRIMARY_IF" -j MASQUERADE

    # 4. Save and enable across reboots
    service iptables save || iptables-save > /etc/sysconfig/iptables
    systemctl enable iptables
    systemctl restart iptables
  EOF

  tags = {
    Name = "${var.project_name}-nat-instance"
  }
}

# ─── Elastic IP for NAT Instance ──────────────────────────────────────────────
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_eip_association" "nat" {
  instance_id   = aws_instance.nat.id
  allocation_id = aws_eip.nat.id
}

# ─── Private Route Table ──────────────────────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Route all outbound 0.0.0.0/0 traffic from private subnets through the NAT instance
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id

  depends_on = [aws_eip_association.nat]
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}
