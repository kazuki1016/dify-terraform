# AWS Dify Ansible Playbook

このディレクトリには、AWS EC2インスタンス上でDifyをセットアップするためのAnsibleプレイブックが含まれています。

## 構成

- `playbook.yml` - メインのAnsibleプレイブック
- `ansible.cfg` - Ansible設定
- `hosts.ini` - インベントリファイル（Terraformで自動生成）
- `ec2_ssh_key.pem` - SSH秘密鍵（Terraformで自動生成）

## 前提条件

1. Terraform で AWS インフラが構築済み
2. Ansible 2.9以上
3. Python 3.8以上
4. 必要なAnsibleコレクション

## セットアップ

### Ansibleコレクションのインストール

```bash
ansible-galaxy collection install 'community.docker:<4.0.0'
ansible-galaxy collection install amazon.aws
```

### Python依存パッケージのインストール

```bash
pip3 install boto3 botocore
```

## 実行

### 接続テスト

```bash
ansible -i hosts.ini dify_servers -m ping
```

### プレイブックの実行

```bash
ansible-playbook -i hosts.ini playbook.yml
```

### 詳細モードで実行

```bash
ansible-playbook -i hosts.ini playbook.yml -vvv
```

## プレイブックの内容

このプレイブックは以下のタスクを実行します：

1. システムパッケージの更新
2. Docker Engine と Docker Compose のインストール
3. Dockerデータディレクトリの設定（/data/docker）
4. Difyリポジトリのクローン
5. 環境変数の設定（RDS、Redis、S3）
6. Difyコンテナの起動
7. Difyサービスの正常性確認

## 環境変数

以下の環境変数が自動的に設定されます（Terraformのuser_dataから取得）：

- `RDS_ENDPOINT` - RDSエンドポイント
- `RDS_DATABASE` - データベース名
- `RDS_USERNAME` - データベースユーザー名
- `RDS_PASSWORD` - データベースパスワード
- `REDIS_ENDPOINT` - Redisエンドポイント
- `REDIS_PORT` - Redisポート
- `S3_BUCKET` - S3バケット名
- `AWS_REGION` - AWSリージョン

## デバッグ

### Docker コンテナの確認

```bash
ansible -i hosts.ini dify_servers -a "docker ps" -b
```

### Dify ログの確認

```bash
ansible -i hosts.ini dify_servers -a "docker compose -f /opt/dify/docker/docker-compose.yml logs" -b
```

### 環境変数の確認

```bash
ansible -i hosts.ini dify_servers -a "cat /etc/environment" -b
```

## トラブルシューティング

### SSH接続エラー

鍵のパーミッションを確認：
```bash
chmod 600 ec2_ssh_key.pem
```

### Docker コンテナが起動しない

1. EC2インスタンスにSSH接続
2. ログを確認：
```bash
cd /opt/dify/docker
docker compose logs -f
```

### データベース接続エラー

環境変数が正しく設定されているか確認：
```bash
ssh -i ec2_ssh_key.pem ubuntu@<EC2_IP>
cat /etc/environment
cat /opt/dify/docker/.env | grep DB_
```

## カスタマイズ

### Dify設定のカスタマイズ

`playbook.yml`の以下のセクションで追加の環境変数を設定できます：

```yaml
- name: Configure Dify environment - Custom
  ansible.builtin.lineinfile:
    path: "{{ dify_install_dir }}/docker/.env"
    regexp: "^YOUR_VAR="
    line: "YOUR_VAR=your_value"
  become_user: ubuntu
```

### インストールディレクトリの変更

`playbook.yml`の変数セクションで変更：

```yaml
vars:
  dify_install_dir: /opt/dify  # お好みのパスに変更
  docker_data_dir: /data/docker  # お好みのパスに変更
```

## 参考リンク

- [Ansible Documentation](https://docs.ansible.com/)
- [Dify Self-Hosting Guide](https://docs.dify.ai/getting-started/install-self-hosted)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
