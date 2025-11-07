#!/bin/bash
set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 引数のチェック
ENVIRONMENT=${1:-dev}
AWS_REGION=${2:-ap-northeast-1}

echo -e "${YELLOW}=== AWS リソースクリーンアップスクリプト ===${NC}"
echo "Environment: ${ENVIRONMENT}"
echo "Region: ${AWS_REGION}"
echo ""

# Terraform で管理されているリソースを削除
cleanup_terraform_resources() {
    echo -e "${YELLOW}[1/3] Terraform リソースの削除...${NC}"

    cd "$(dirname "$0")/../infra/terraform/aws"

    if [ ! -d ".terraform" ]; then
        echo "Terraform を初期化しています..."
        terraform init
    fi

    echo "Terraform destroy を実行しています..."
    terraform destroy \
        -var="environment=${ENVIRONMENT}" \
        -var="aws_region=${AWS_REGION}" \
        -auto-approve || {
        echo -e "${RED}Terraform destroy に失敗しました。手動でリソースを確認してください。${NC}"
        return 1
    }

    echo -e "${GREEN}✓ Terraform リソースの削除完了${NC}"
}

# Secrets Manager のシークレットを強制削除
cleanup_secrets_manager() {
    echo -e "${YELLOW}[2/3] Secrets Manager のクリーンアップ...${NC}"

    SECRETS=(
        "dify-ssh-private-key-${ENVIRONMENT}"
        "dify-ssh-public-key-${ENVIRONMENT}"
    )

    for SECRET_NAME in "${SECRETS[@]}"; do
        echo "シークレットを確認中: ${SECRET_NAME}"

        # シークレットが存在するか確認
        if aws secretsmanager describe-secret \
            --secret-id "${SECRET_NAME}" \
            --region "${AWS_REGION}" \
            &>/dev/null; then

            echo "  削除中: ${SECRET_NAME}"
            aws secretsmanager delete-secret \
                --secret-id "${SECRET_NAME}" \
                --region "${AWS_REGION}" \
                --force-delete-without-recovery || {
                echo -e "${YELLOW}  ⚠ ${SECRET_NAME} の削除に失敗（既に削除済みの可能性）${NC}"
            }
        else
            echo "  ${SECRET_NAME} は存在しません（スキップ）"
        fi
    done

    echo -e "${GREEN}✓ Secrets Manager のクリーンアップ完了${NC}"
}

# 孤立したリソースの確認
verify_cleanup() {
    echo -e "${YELLOW}[3/3] 残存リソースの確認...${NC}"

    # EC2 インスタンスの確認
    echo "EC2 インスタンスを確認中..."
    INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Environment,Values=${ENVIRONMENT}" \
                  "Name=tag:System,Values=Dify" \
                  "Name=instance-state-name,Values=running,pending,stopping,stopped" \
        --region "${AWS_REGION}" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)

    if [ -n "$INSTANCES" ]; then
        echo -e "${RED}⚠ 実行中のEC2インスタンスが見つかりました: ${INSTANCES}${NC}"
    else
        echo -e "${GREEN}✓ EC2インスタンスなし${NC}"
    fi

    # NAT Gateway の確認
    echo "NAT Gatewayを確認中..."
    NAT_GATEWAYS=$(aws ec2 describe-nat-gateways \
        --filter "Name=tag:Environment,Values=${ENVIRONMENT}" \
                 "Name=tag:System,Values=Dify" \
                 "Name=state,Values=pending,available" \
        --region "${AWS_REGION}" \
        --query 'NatGateways[].NatGatewayId' \
        --output text)

    if [ -n "$NAT_GATEWAYS" ]; then
        echo -e "${RED}⚠ アクティブなNAT Gatewayが見つかりました: ${NAT_GATEWAYS}${NC}"
    else
        echo -e "${GREEN}✓ NAT Gatewayなし${NC}"
    fi

    # Elastic IP の確認
    echo "Elastic IPを確認中..."
    EIPS=$(aws ec2 describe-addresses \
        --filters "Name=tag:Environment,Values=${ENVIRONMENT}" \
                  "Name=tag:System,Values=Dify" \
        --region "${AWS_REGION}" \
        --query 'Addresses[].AllocationId' \
        --output text)

    if [ -n "$EIPS" ]; then
        echo -e "${YELLOW}⚠ 未解放のElastic IPが見つかりました: ${EIPS}${NC}"
        echo "  (Terraform destroy で削除されるはずですが、手動確認を推奨)"
    else
        echo -e "${GREEN}✓ Elastic IPなし${NC}"
    fi

    echo ""
    echo -e "${GREEN}=== クリーンアップ完了 ===${NC}"
}

# メイン処理
main() {
    # 確認プロンプト
    read -p "Environment '${ENVIRONMENT}' のリソースを削除しますか? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "キャンセルされました。"
        exit 0
    fi

    cleanup_terraform_resources
    cleanup_secrets_manager
    verify_cleanup

    echo ""
    echo -e "${GREEN}✓ すべてのクリーンアップが完了しました！${NC}"
    echo ""
    echo "注意:"
    echo "- S3バケット 'dify-terraform-state' は保持されています（Terraformステート用）"
    echo "- 削除されたリソースがAWSコンソールから消えるまで数分かかる場合があります"
}

main
