#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-forRecord}"
REPO_URL="${REPO_URL:-https://github.com/doubley318/forRecord.git}"
DEPLOY_DIR="${DEPLOY_DIR:-/var/www/${APP_NAME}}"
NGINX_CONF="${NGINX_CONF:-/etc/nginx/sites-available/${APP_NAME}}"
DOMAIN="${1:-${DOMAIN:-_}}"
BACKEND_UPSTREAM="${BACKEND_UPSTREAM:-http://127.0.0.1:2523}"
CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"
CERT_FULLCHAIN="${CERT_DIR}/fullchain.pem"
CERT_PRIVKEY="${CERT_DIR}/privkey.pem"

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

write_http_site_config() {
  cat > "${NGINX_CONF}" <<NGINX
server {
    listen 80;
    server_name ${DOMAIN};

    root ${DEPLOY_DIR};
    index index.html;

    location /moneybook/api/v1/ {
        proxy_pass ${BACKEND_UPSTREAM}/moneybook/api/v1/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX
}

write_https_site_config() {
  cat > "${NGINX_CONF}" <<NGINX
server {
    listen 80;
    server_name ${DOMAIN};

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    ssl_certificate ${CERT_FULLCHAIN};
    ssl_certificate_key ${CERT_PRIVKEY};

    root ${DEPLOY_DIR};
    index index.html;

    location /moneybook/api/v1/ {
        proxy_pass ${BACKEND_UPSTREAM}/moneybook/api/v1/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX
}

if [[ -f "${CERT_FULLCHAIN}" && -f "${CERT_PRIVKEY}" ]]; then
  write_https_site_config
  echo "已检测到 HTTPS 证书，将同时部署网页和小程序 API 反向代理。"
else
  write_http_site_config
  echo "未检测到 ${DOMAIN} 的 HTTPS 证书，仅部署 HTTP；申请证书后再次执行本脚本即可启用 HTTPS。" >&2
fi

ln -sf "${NGINX_CONF}" "/etc/nginx/sites-enabled/${APP_NAME}"
nginx -t
systemctl enable nginx
systemctl reload nginx

echo "部署完成：${DEPLOY_DIR}"
echo "当前绑定域名：${DOMAIN}"
echo "如果你有域名，请用 sudo bash deploy.sh 你的域名 执行。"
