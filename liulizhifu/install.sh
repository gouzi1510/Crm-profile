#!/usr/bin/env bash
# ============================================================================
# 穗丰粮仓 Linux 一键部署
# 用法:
#   sudo bash liulizhifu/install.sh
#   CentOS root 密码非空: sudo MYSQL_ROOT_PWD='密码' bash liulizhifu/install.sh
#   自定义管理员密码:     sudo ADMIN_PWD='强密码' bash liulizhifu/install.sh
#   有域名:               sudo APP_DOMAIN=your.com bash liulizhifu/install.sh
#
# 设计: 仓库只含源码，不含构建产物/数据/账号。脚本优先使用随包上传的
#       产物(liulizhifu/app|web|db)，缺失时自动从源码构建(mvn / npm)。
#       管理员账号由本脚本按 ADMIN_PWD 现场创建，不入库。
# ============================================================================
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"          # .../liulizhifu
ROOT="$(cd "$HERE/.." && pwd)"                 # 仓库根
APP=/opt/liulizhifu
DB_NAME=liulizhifu
APP_DOMAIN=${APP_DOMAIN:-_}
DB_APP_PWD=${DB_APP_PWD:-Liulz_2026_Secret}    # 数据库应用账号密码
ADMIN_PWD=${ADMIN_PWD:-admin123}               # 系统管理员登录密码(现场创建)
log() { echo -e "\033[32m[deploy]\033[0m $*"; }

# ---------- 1. 依赖 ----------
if command -v dnf >/dev/null 2>&1; then PKG=dnf; OS=rhel
elif command -v yum >/dev/null 2>&1; then PKG=yum; OS=rhel
elif command -v apt-get >/dev/null 2>&1; then PKG=apt-get; OS=deb
else echo "no pkg manager"; exit 1; fi
log "安装 JDK17 / MySQL / Nginx ..."
if [ "$OS" = rhel ]; then
  $PKG install -y -q java-17-openjdk-headless nginx >/dev/null
  if ! $PKG install -y -q mysql-server >/dev/null 2>&1; then
    $PKG install -y -q mariadb-server >/dev/null; DB_SVC=mariadb; MYSQL_CLI=mysql
  else DB_SVC=mysqld; MYSQL_CLI=mysql; fi
else
  export DEBIAN_FRONTEND=noninteractive; apt-get update -qq
  apt-get install -y -qq openjdk-17-jdk-headless mysql-server nginx curl >/dev/null
  DB_SVC=mysql; MYSQL_CLI=mysql
fi
systemctl enable --now $DB_SVC nginx >/dev/null 2>&1 || true
[ -n "${MYSQL_ROOT_PWD:-}" ] && MROOT="$MYSQL_CLI -uroot -p$MYSQL_ROOT_PWD" || MROOT="$MYSQL_CLI -uroot"
for i in $(seq 1 30); do $MROOT -e "SELECT 1" >/dev/null 2>&1 && break; sleep 2; done
$MROOT -e "SELECT 1" >/dev/null 2>&1 || { echo "连不上 MySQL root，请用 MYSQL_ROOT_PWD=xxx 重试"; exit 1; }

# ---------- 2. 数据库（表结构 + 应用配置 + 账号现场创建）----------
DB_SRC="$HERE/db"; [ -f "$DB_SRC/01_schema.sql" ] || DB_SRC="$ROOT/backend/src/main/resources/db"
log "导入表结构 + 应用配置(角色/菜单) ..."
$MROOT --default-character-set=utf8mb4 < "$DB_SRC/01_schema.sql"
sed 's/^INSERT INTO/INSERT IGNORE INTO/' "$DB_SRC/03_base_config.sql" | $MROOT --default-character-set=utf8mb4 "$DB_NAME"

log "创建管理员账号 + 数据库应用账号 ..."
$MROOT "$DB_NAME" -e "SET NAMES utf8mb4;
INSERT IGNORE INTO sys_account (id,emp_id,username,password,real_name,status)
VALUES (1,1,'admin','${ADMIN_PWD}','系统管理员',1);"
$MROOT -e "CREATE USER IF NOT EXISTS 'liulizhifu'@'127.0.0.1' IDENTIFIED BY '${DB_APP_PWD}';
ALTER USER 'liulizhifu'@'127.0.0.1' IDENTIFIED BY '${DB_APP_PWD}';
GRANT SELECT,INSERT,UPDATE,DELETE ON ${DB_NAME}.* TO 'liulizhifu'@'127.0.0.1'; FLUSH PRIVILEGES;"

# ---------- 3. 构建产物（优先随包，缺失则从源码构建）----------
mkdir -p $APP/app $APP/web /etc/liulizhifu
JAR_NAME=liulizhifu-backend-1.0.0.jar
if [ -f "$HERE/app/$JAR_NAME" ]; then
  log "使用随包 jar ..."
  cp -f "$HERE/app/$JAR_NAME" $APP/app/
else
  log "现场构建后端 (mvn package) ..."
  command -v mvn >/dev/null 2>&1 || { $PKG install -y -q maven >/dev/null 2>&1 || $PKG install -y -q -e maven >/dev/null; }
  ( cd "$ROOT/backend" && mvn -q -DskipTests package )
  cp -f "$ROOT/backend/target/$JAR_NAME" $APP/app/
fi
if [ -d "$HERE/web" ] && [ -f "$HERE/web/index.html" ]; then
  log "使用随包前端 dist ..."
  rm -rf $APP/web/*; cp -rf "$HERE/web/." $APP/web/
else
  log "现场构建前端 (npm ci + vite build) ..."
  command -v node >/dev/null 2>&1 || { [ "$OS" = deb ] && apt-get install -y -qq nodejs npm >/dev/null || $PKG install -y -q nodejs npm >/dev/null; }
  ( cd "$ROOT/frontend" && { npm ci 2>/dev/null || npm install; } && node node_modules/vite/bin/vite.js build )
  rm -rf $APP/web/*; cp -rf "$ROOT/frontend/dist/." $APP/web/
fi
chmod -R a+rX $APP/web
id -u liulizhifu >/dev/null 2>&1 || useradd -r -s /sbin/nologin liulizhifu
chown -R liulizhifu:liulizhifu $APP

# ---------- 4. 配置 ----------
log "写运行配置 ..."
cat > /etc/liulizhifu/env <<EOF
SPRING_DATASOURCE_URL=jdbc:mysql://127.0.0.1:3306/${DB_NAME}?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
SPRING_DATASOURCE_USERNAME=liulizhifu
SPRING_DATASOURCE_PASSWORD=${DB_APP_PWD}
TZ=Asia/Shanghai
EOF
chmod 600 /etc/liulizhifu/env

cat > /etc/systemd/system/liulizhifu.service <<'EOF'
[Unit]
Description=Liulizhifu Backend (Spring Boot)
After=network.target mysqld.service mariadb.service
[Service]
User=liulizhifu
EnvironmentFile=/etc/liulizhifu/env
ExecStart=/usr/bin/java -jar /opt/liulizhifu/app/liulizhifu-backend-1.0.0.jar
Restart=always
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then
  setsebool -P httpd_can_network_connect 1 2>/dev/null || true
fi
mkdir -p /etc/nginx/conf.d
cat > /etc/nginx/conf.d/liulizhifu.conf <<EOF
server {
    listen 80 default_server;
    server_name ${APP_DOMAIN};
    root /opt/liulizhifu/web;
    index index.html;
    gzip on; gzip_min_length 1k; gzip_comp_level 5;
    gzip_types text/css application/javascript application/json image/svg+xml;
    location /api/ {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    location /assets/ { expires 7d; }
    location / { try_files \$uri \$uri/ /index.html; }
}
EOF
rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
# 禁用其他抢占 80 的站点：Ubuntu 用 include sites-enabled/*，改名 .disabled 仍会加载，必须移出目录
mkdir -p /root/nginx-backup
for f in /etc/nginx/conf.d/*.conf /etc/nginx/sites-enabled/*; do
  [ "$f" = "/etc/nginx/conf.d/liulizhifu.conf" ] && continue
  [ -e "$f" ] || continue
  grep -qE "listen[[:space:]]+80([;[:space:]]|$)" "$f" 2>/dev/null && mv "$f" /root/nginx-backup/ 2>/dev/null && echo "已移出抢占 80 的站点: $f"
done
nginx -t && systemctl restart nginx

systemctl daemon-reload
systemctl enable liulizhifu >/dev/null 2>&1
systemctl restart liulizhifu

if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-service=http >/dev/null && firewall-cmd --reload >/dev/null
elif command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q active; then
  ufw allow 80/tcp >/dev/null || true
fi

sleep 5
log "✅ 完成: http://$(hostname -I 2>/dev/null | awk '{print $1}')/  登录 admin / ${ADMIN_PWD}"
echo "   日志: journalctl -u liulizhifu -f   重启: systemctl restart liulizhifu"
