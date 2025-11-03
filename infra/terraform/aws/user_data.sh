#!/bin/bash
set -e

# ログ設定
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script execution..."

# システムアップデート
apt-get update
apt-get upgrade -y

# CloudWatch Logs Agent のインストール
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# CloudWatch Logs Agent の設定
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/aws/ec2/dify-${var.environment}",
            "log_stream_name": "{instance_id}/user-data.log"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/aws/ec2/dify-${var.environment}",
            "log_stream_name": "{instance_id}/syslog"
          }
        ]
      }
    }
  }
}
EOF

# CloudWatch Logs Agent の起動
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# データボリュームのマウント
if [ ! -d "/data" ]; then
  mkfs -t ext4 /dev/nvme1n1
  mkdir -p /data
  mount /dev/nvme1n1 /data
  echo '/dev/nvme1n1 /data ext4 defaults,nofail 0 2' >> /etc/fstab
fi

# 環境変数の設定
# マネージドデータベース/キャッシュを使用しないため、S3とリージョンのみ設定
cat > /etc/environment <<EOF
S3_BUCKET=${s3_bucket}
AWS_REGION=${aws_region}
EOF

echo "User data script completed successfully!"
