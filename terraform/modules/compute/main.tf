# Security Group Resource
resource "aws_security_group" "ec2_sg" {
  name        = "${var.environment}-ec2-sg"
  description = "Security group for EC2 instances in the ${var.environment} environment"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description       = ingress.value.description
      from_port         = ingress.value.from_port
      to_port           = ingress.value.to_port
      protocol          = ingress.value.protocol
      cidr_blocks       = ingress.value.cidr_blocks
      ipv6_cidr_blocks  = ingress.value.ipv6_cidr_blocks
      security_groups   = ingress.value.security_group_ids
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description       = egress.value.description
      from_port         = egress.value.from_port
      to_port           = egress.value.to_port
      protocol          = egress.value.protocol
      cidr_blocks       = egress.value.cidr_blocks
      ipv6_cidr_blocks  = egress.value.ipv6_cidr_blocks
    }
  }

  tags = merge(var.tags, { "Name" = "${var.environment}-ec2-sg" })
}

# EC2 Instance Resource
resource "aws_instance" "compute" {
  count               = var.instance_count
  ami                 = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  subnet_id           = var.subnet_id
  security_group_ids  = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = var.associate_public_ip
  user_data           = var.user_data
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge(var.tags, { "Name" = "${var.environment}-instance-${count.index + 1}" })
}
