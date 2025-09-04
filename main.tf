# Fetch your public IP dynamically
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

# Create Key Pair
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save private key locally (use with caution)
resource "local_file" "private_key" {
  filename = "${path.module}/my-ec2-key.pem"
  content  = tls_private_key.key_pair.private_key_pem
  file_permission = "0600"
}

# Security Group allowing SSH only from your IP
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH from my IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get default VPC for simplicity
data "aws_vpc" "default" {
  default = true
}
 
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# EC2 Instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-0b016c703b95ecbe4" # Amazon Linux 2 (Free Tier eligible)
  instance_type = "t3.micro"
  subnet_id     = element(data.aws_subnets.default.ids, 0)
  key_name      = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name        = "MyEC2Instance"
    Application = "MyApp"
    OS          = "Amazon Linux 2"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_ec2.public_ip
}
