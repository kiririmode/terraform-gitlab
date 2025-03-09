output "instance_id" {
  description = "ID of the GitLab EC2 instance"
  value       = aws_instance.gitlab.id
}

output "instance_private_ip" {
  description = "Private IP address of the GitLab instance"
  value       = aws_instance.gitlab.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the GitLab instance"
  value       = aws_instance.gitlab.public_ip
}

output "security_group_id" {
  description = "ID of the GitLab security group"
  value       = aws_security_group.gitlab.id
}

output "ebs_volume_id" {
  description = "ID of the GitLab data EBS volume"
  value       = aws_ebs_volume.gitlab_data.id
}

output "iam_role_name" {
  description = "Name of the IAM role used by GitLab instance"
  value       = aws_iam_role.gitlab_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by GitLab instance"
  value       = aws_iam_role.gitlab_role.arn
}
