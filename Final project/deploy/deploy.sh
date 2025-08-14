set -euo pipefail

DOCKER_IMAGE=${DOCKER_IMAGE:?}
APP_NAME=${APP_NAME:-app}
HOST_PORT=${HOST_PORT:-80}
CONTAINER_PORT=${CONTAINER_PORT:-3000}
BUILD_NUMBER="${1:-latest}"

echo "[deploy] Image=$DOCKER_IMAGE Build=$BUILD_NUMBER App=$APP_NAME"

# Install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
  echo "[deploy] Installing Docker..."
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf -y update
    sudo dnf -y install docker
    sudo systemctl enable --now docker
  else
    curl -fsSL https://get.docker.com | sh
    sudo systemctl enable --now docker
  fi
fi

# Pull image (prefer exact build tag, fallback to latest)
sudo docker pull "${DOCKER_IMAGE}:${BUILD_NUMBER}" || sudo docker pull "${DOCKER_IMAGE}:latest"

# Prepare logs dir
sudo mkdir -p /var/log/${APP_NAME}

# Stop & remove existing container if exists
if sudo docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
  echo "[deploy] Removing old container ${APP_NAME}"
  sudo docker rm -f ${APP_NAME} || true
fi

# Run new container
sudo docker run -d \
  --name ${APP_NAME} \
  --restart unless-stopped \
  -p ${HOST_PORT}:${CONTAINER_PORT} \
  -v /var/log/${APP_NAME}:/usr/src/app/logs \
  "${DOCKER_IMAGE}:${BUILD_NUMBER}" || \
  sudo docker run -d \
    --name ${APP_NAME} \
    --restart unless-stopped \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v /var/log/${APP_NAME}:/usr/src/app/logs \
    "${DOCKER_IMAGE}:latest"

echo "[deploy] Deployed ${APP_NAME} on port ${HOST_PORT}"