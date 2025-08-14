set -euo pipefail

S3_BUCKET=${S3_BUCKET:?}
AWS_REGION=${AWS_REGION:?}
APP_NAME=${APP_NAME:-app}
TIMESTAMP=$(date +%Y-%m-%dT%H-%M-%S)
SRC_DIR="/var/log/${APP_NAME}"

# Install AWS CLI if missing
if ! command -v aws >/dev/null 2>&1; then
  echo "[backup] Installing AWS CLI..."
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf -y install awscli
  else
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
  fi
fi

if [ -d "$SRC_DIR" ]; then
  echo "[backup] Syncing $SRC_DIR to s3://$S3_BUCKET/${APP_NAME}/logs/${TIMESTAMP}/"
  aws s3 sync "$SRC_DIR" "s3://${S3_BUCKET}/${APP_NAME}/logs/${TIMESTAMP}/" --region "$AWS_REGION"
else
  echo "[backup] No logs directory at $SRC_DIR"
fi