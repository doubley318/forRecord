#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-forRecord}"
REPO_URL="${REPO_URL:-https://github.com/doubley318/forRecord.git}"
DEPLOY_DIR="${DEPLOY_DIR:-/var/www/${APP_NAME}}"
NGINX_CONF="${NGINX_CONF:-/etc/nginx/sites-available/${APP_NAME}}"
DOMAIN="${1:-${DOMAIN:-_}}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "请使用 root 运行：sudo bash deploy.sh"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  apt-get update
  apt-get install -y git
fi

if ! command -v nginx >/dev/null 2>&1; then
  apt-get update
  apt-get install -y nginx
fi

mkdir -p "${DEPLOY_DIR}"

if [[ -d "${DEPLOY_DIR}/.git" ]]; then
  git -C "${DEPLOY_DIR}" pull --ff-only
else
  rm -rf "${DEPLOY_DIR:?}/"*
  git clone "${REPO_URL}" "${DEPLOY_DIR}"
fi

cat > "${NGINX_CONF}" <<NGINX
server {
    listen 80;
    server_name ${DOMAIN};

    root ${DEPLOY_DIR};
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX

ln -sf "${NGINX_CONF}" "/etc/nginx/sites-enabled/${APP_NAME}"
nginx -t
systemctl enable nginx
systemctl reload nginx

echo "部署完成：${DEPLOY_DIR}"
echo "当前绑定域名：${DOMAIN}"
echo "如果你有域名，请用 sudo bash deploy.sh 你的域名 执行。"
