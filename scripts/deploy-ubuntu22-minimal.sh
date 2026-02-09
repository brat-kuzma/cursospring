#!/bin/bash
# ============================================
# Минимальное развёртывание cursospring на Ubuntu 22
# Включает: PostgreSQL, бэкенд, фронт (сборка + nginx)
# БЕЗОПАСНОСТЬ: перед включением firewall всегда разрешаем SSH (22)
# Запуск: root на чистом сервере Ubuntu 22
# ============================================

set -e

# Рекомендация: запускать в screen/tmux, чтобы не потерять сессию при обрыве
if [ -z "$STY" ] && [ -z "$TMUX" ]; then
    echo "Рекомендуется: запустите скрипт в screen или tmux (screen -S deploy или tmux new -s deploy)"
    echo "Нажмите Enter для продолжения или Ctrl+C для выхода..."
    read -r
fi

APP_DIR="${APP_DIR:-/opt/cursospring}"
DB_NAME="${DB_NAME:-cursospring}"
DB_USER="${DB_USER:-postgres}"
# Пароль БД — задайте переменной окружения или введите при запросе
DB_PASS="${POSTGRES_PASSWORD:-}"

echo "=============================================="
echo "  Cursospring — минимальный деплой (Ubuntu 22)"
echo "=============================================="

# ---- 1. БЕЗОПАСНЫЙ FIREWALL (не потерять SSH) ----
echo ""
echo "[1/8] Firewall: сначала разрешаем SSH (22)..."
if command -v ufw &>/dev/null; then
    ufw --force reset 2>/dev/null || true
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP frontend'
    ufw allow 8080/tcp comment 'Backend API'
    ufw --force enable
    echo "   ufw включён: разрешены 22, 80, 8080"
else
    echo "   ufw не найден, пропускаем"
fi

# ---- 2. Обновление и минимальные пакеты ----
echo ""
echo "[2/8] Обновление пакетов и базовая установка..."
apt update
apt install -y curl wget ca-certificates gnupg

# ---- 3. PostgreSQL ----
echo ""
echo "[3/8] PostgreSQL..."
if ! command -v psql &>/dev/null; then
    apt install -y postgresql postgresql-contrib
    systemctl enable postgresql
    systemctl start postgresql
fi

if [ -z "$DB_PASS" ]; then
    read -sp "Пароль пользователя postgres (БД): " DB_PASS
    echo
fi
sudo -u postgres psql -c "ALTER USER ${DB_USER} PASSWORD '${DB_PASS}';" 2>/dev/null || true
sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}';" | grep -q 1 || sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME};"

# Таблица tasks (если есть SQL-файл)
if [ -f "${APP_DIR}/backend/sql/create_database_simple.sql" ]; then
    sudo -u postgres psql -d "${DB_NAME}" -f "${APP_DIR}/backend/sql/create_database_simple.sql" 2>/dev/null || true
fi

# ---- 4. Java 21 (минимум: JRE для запуска не нужен, только для сборки; ставим JDK) ----
echo ""
echo "[4/8] Java 21..."
if apt-cache show openjdk-21-jdk &>/dev/null; then
    apt install -y openjdk-21-jdk
else
    apt install -y wget
    mkdir -p /etc/apt/keyrings
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc >/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(. /etc/os-release && echo $VERSION_CODENAME) main" | tee /etc/apt/sources.list.d/adoptium.list
    apt update
    apt install -y temurin-21-jdk
fi

# ---- 5. Maven ----
echo ""
echo "[5/8] Maven..."
apt install -y maven

# ---- 6. Node (только для сборки фронта) ----
echo ""
echo "[6/8] Node.js (для сборки фронта)..."
if ! command -v node &>/dev/null; then
    apt install -y build-essential
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

# ---- 7. Сборка приложения (если каталог уже есть) ----
echo ""
echo "[7/8] Сборка приложения..."
if [ ! -d "${APP_DIR}" ]; then
    echo "   Каталог ${APP_DIR} не найден. Клонируйте репозиторий или скопируйте проект в ${APP_DIR} и запустите скрипт снова."
    exit 1
fi

export SPRING_DATASOURCE_URL="jdbc:postgresql://localhost:5432/${DB_NAME}"
export SPRING_DATASOURCE_USERNAME="${DB_USER}"
export SPRING_DATASOURCE_PASSWORD="${DB_PASS}"
export APP_UPLOAD_DIR="${APP_DIR}/data/uploads"

mkdir -p "${APP_DIR}/data/uploads"
cd "${APP_DIR}"

# Backend
mvn clean package -DskipTests -q
JAR=$(ls target/cursospring-*.jar 2>/dev/null | head -1)
if [ -z "$JAR" ]; then
    echo "   Ошибка: JAR не найден после сборки"
    exit 1
fi

# Frontend: сборка и nginx
cd "${APP_DIR}/frontend"
npm ci --prefer-offline --no-audit 2>/dev/null || npm install
npm run build

apt install -y nginx
FRONT_ROOT="/usr/share/nginx/html/cursospring"
mkdir -p "$FRONT_ROOT"
cp -r dist/* "$FRONT_ROOT/"

# Конфиг nginx: статика + прокси /api (лимит загрузки 1 ГБ для файлового менеджера)
cat > /etc/nginx/sites-available/cursospring << 'NGINX'
server {
    listen 80 default_server;
    root /usr/share/nginx/html/cursospring;
    index index.html;
    client_max_body_size 1024M;
    location / {
        try_files $uri $uri/ /index.html;
    }
    location /api {
        client_max_body_size 1024M;
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/cursospring /etc/nginx/sites-enabled/
nginx -t && systemctl enable nginx && systemctl reload nginx

# ---- 8. Запуск бэкенда (фоновый процесс + systemd для автозапуска) ----
echo ""
echo "[8/8] Запуск бэкенда..."
mkdir -p "${APP_DIR}/logs"

# Systemd unit
cat > /etc/systemd/system/cursospring.service << UNIT
[Unit]
Description=Cursospring Backend
After=network.target postgresql.service

[Service]
Type=simple
WorkingDirectory=${APP_DIR}
Environment=SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
Environment=SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
Environment=SPRING_DATASOURCE_PASSWORD=${DB_PASS}
Environment=APP_UPLOAD_DIR=${APP_UPLOAD_DIR}
ExecStart=/usr/bin/java -jar ${JAR}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable cursospring
systemctl start cursospring

echo ""
echo "=============================================="
echo "  Готово."
echo "=============================================="
echo "  Frontend:  http://<IP_СЕРВЕРА>/"
echo "  Backend:   http://<IP_СЕРВЕРА>:8080/"
echo "  Логин:     user / password"
echo ""
echo "  Логи бэкенда: journalctl -u cursospring -f"
echo "  Остановка:    systemctl stop cursospring"
echo "  Перезапуск:   systemctl restart cursospring"
echo "=============================================="
