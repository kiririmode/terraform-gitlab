locals {
  ebs_path = "/dev/sdh"
}

# セキュリティグループの作成
resource "aws_security_group" "gitlab" {
  name        = "gitlab-security-group"
  description = "Security group for GitLab server"
  vpc_id      = var.vpc_id

  # HTTPSアクセス
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # HTTPアクセス
  # TODO: 必要性を確認する
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # # SSHアクセス
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = [var.admin_cidr_blocks]
  #   description = "SSH access"
  # }

  # アウトバウンドトラフィック
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "gitlab-sg"
    Environment = var.environment
  }
}

# IAMロールの作成
resource "aws_iam_role" "gitlab_role" {
  name = "GitLab-Instance-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "gitlab-role"
    Environment = var.environment
  }
}

# IAMインスタンスプロファイルの作成
resource "aws_iam_instance_profile" "gitlab_profile" {
  name = "gitlab-instance-profile"
  role = aws_iam_role.gitlab_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.gitlab_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EBSボリュームの作成
resource "aws_ebs_volume" "gitlab_data" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name        = "gitlab-data"
    Environment = var.environment
  }
}

# Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # AmazonのAMI所有者ID

  filter {
    name = "name"
    # Amazon Linux 2023 AMIの名前パターン。minimumを除外する
    values = ["al2023-ami-2023*-kernel-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# EC2インスタンスの作成
resource "aws_instance" "gitlab" {
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  subnet_id         = var.subnet_id
  ami               = data.aws_ami.amazon_linux.id

  ebs_optimized = true

  vpc_security_group_ids = [aws_security_group.gitlab.id]
  iam_instance_profile   = aws_iam_instance_profile.gitlab_profile.name
  #  key_name               = var.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }

  # 障害発生時は自動的に再起動
  maintenance_options {
    auto_recovery = "default"
  }

  user_data = templatefile("${path.module}/userdata.sh.tmpl", {
    domain_name = var.domain_name
    ebs_path    = local.ebs_path
  })

  tags = {
    Name        = "gitlab-server"
    Environment = var.environment
  }
}

# EBSボリュームのアタッチ
resource "aws_volume_attachment" "gitlab_data_attachment" {
  device_name = local.ebs_path
  volume_id   = aws_ebs_volume.gitlab_data.id
  instance_id = aws_instance.gitlab.id
}
