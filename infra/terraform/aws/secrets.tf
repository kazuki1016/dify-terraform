# SSH Key and Secrets Manager

# SSH Key Pair Generation
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

# Store SSH Private Key in Secrets Manager
resource "aws_secretsmanager_secret" "ssh_private_key" {
  name                    = "dify-ssh-private-key-${var.environment}"
  description             = "SSH private key for Dify EC2 instance"
  recovery_window_in_days = 7

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = tls_private_key.ssh.private_key_openssh
}

# Store SSH Public Key in Secrets Manager
resource "aws_secretsmanager_secret" "ssh_public_key" {
  name                    = "dify-ssh-public-key-${var.environment}"
  description             = "SSH public key for Dify EC2 instance"
  recovery_window_in_days = 7

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id     = aws_secretsmanager_secret.ssh_public_key.id
  secret_string = tls_private_key.ssh.public_key_openssh
}

# Save SSH Private Key locally for Ansible
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = "${path.module}/../ansible/aws/ec2_ssh_key.pem"
  file_permission = "0600"
}

# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/hosts.ini.tpl", {
    ec2_public_ip = aws_eip.ec2.public_ip
    ssh_user      = "ubuntu"
    ssh_key_path  = "./ec2_ssh_key.pem"
  })
  filename = "${path.module}/../ansible/aws/hosts.ini"

  depends_on = [
    aws_eip_association.ec2,
    local_file.private_key_pem
  ]
}
