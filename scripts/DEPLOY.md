# Развертывание cursospring на сервере

В продакшене приложение работает так: **PostgreSQL** — БД, **бэкенд (Spring Boot)** — на порту 8080, **фронтенд** — собранная статика, которую раздаёт **Nginx**; Nginx же проксирует запросы `/api` на бэкенд. Для загрузки файлов до 1 ГБ в nginx задаётся `client_max_body_size 1024M;`.

## Предварительные требования

✅ Все зависимости установлены (Java 21, Maven, PostgreSQL, Node.js, Nginx для продакшена)  
✅ База данных создана (см. `backend/sql/README.md`)

---

## Шаг 1: Клонирование репозитория

```bash
cd /opt
git clone <ваш_репозиторий> cursospring
cd cursospring
```

Или скопируйте проект на сервер через scp/sftp.

---

## Шаг 2: Настройка переменных окружения для БД

### Вариант А: Переменные окружения (для текущей сессии)

```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=ваш_пароль
export APP_UPLOAD_DIR=/opt/cursospring/data/uploads
```

### Вариант Б: Файл .env (рекомендуется)

Создайте файл `/opt/cursospring/.env`:

```bash
cd /opt/cursospring
cat > .env << EOF
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=ваш_пароль
APP_UPLOAD_DIR=/opt/cursospring/data/uploads
EOF
```

Затем загрузите переменные:
```bash
set -a
source .env
set +a
```

### Вариант В: application-local.properties (для разработки)

```bash
cd /opt/cursospring/backend/src/main/resources
cp application-local.properties.example application-local.properties
# Отредактируйте файл и укажите пароль БД
```

---

## Шаг 3: Развертывание бэкенда

### Автоматически (скрипт)

```bash
cd /opt/cursospring
chmod +x scripts/*.sh

# Установите переменные окружения (см. Шаг 2)
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=ваш_пароль

# Сборка и подготовка
./scripts/deploy-backend.sh

# Запуск
./scripts/start-backend.sh
```

### Вручную

```bash
cd /opt/cursospring

# Сборка
mvn clean package -DskipTests

# Создание каталога для загрузок
mkdir -p data/uploads

# Запуск
java -jar target/cursospring-0.0.1-SNAPSHOT.jar
```

Бэкенд будет доступен на **http://localhost:8080**

---

## Шаг 4: Развертывание фронтенда (Nginx)

В продакшене фронт **собирается** и раздаётся через **Nginx** (статика + прокси `/api` на бэкенд).

### Сборка фронтенда

```bash
cd /opt/cursospring/frontend
npm install
npm run build
# Результат в frontend/dist/
```

### Конфигурация Nginx

Создайте или отредактируйте конфиг (например `/etc/nginx/sites-available/cursospring`):

```nginx
server {
    listen 80 default_server;
    server_name ваш_домен.com;

    root /usr/share/nginx/html/cursospring;   # или /opt/cursospring/frontend/dist
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
```

Подключите сайт и перезагрузите nginx:
```bash
ln -sf /etc/nginx/sites-available/cursospring /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

### Вариант: Dev-сервер (только для тестирования)

```bash
cd /opt/cursospring/frontend
npm install
npm run dev
```

Фронтенд будет доступен на **http://localhost:5173**

---

## Шаг 5: Проверка работы

1. **Проверка бэкенда:**
   ```bash
   curl http://localhost:8080/api/auth/me
   # Должен вернуть {"authenticated":false}
   ```

2. **Проверка фронтенда:**
   - Откройте браузер: http://ваш_сервер:5173 (dev) или http://ваш_домен.com (prod)
   - Войдите: user / password
   - Проверьте работу задач и файлового менеджера

---

## Управление бэкендом

### Остановка
```bash
/opt/cursospring/scripts/stop-backend.sh
```

### Просмотр логов
```bash
tail -f /opt/cursospring/logs/backend.log
```

### Перезапуск
```bash
/opt/cursospring/scripts/stop-backend.sh
/opt/cursospring/scripts/start-backend.sh
```

---

## Автозапуск через systemd (опционально)

Создайте файл `/etc/systemd/system/cursospring.service`:

```ini
[Unit]
Description=Cursospring Backend
After=network.target postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/cursospring
Environment="SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring"
Environment="SPRING_DATASOURCE_USERNAME=postgres"
Environment="SPRING_DATASOURCE_PASSWORD=ваш_пароль"
Environment="APP_UPLOAD_DIR=/opt/cursospring/data/uploads"
ExecStart=/usr/bin/java -jar /opt/cursospring/target/cursospring-0.0.1-SNAPSHOT.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Активация:
```bash
systemctl daemon-reload
systemctl enable cursospring
systemctl start cursospring
systemctl status cursospring
```

---

## Структура каталогов после развертывания

```
/opt/cursospring/
├── backend/              # Исходники бэкенда
├── frontend/             # Исходники фронтенда
│   └── dist/             # Собранный фронтенд (копируется в каталог nginx)
├── target/               # Собранный JAR бэкенда
├── data/
│   └── uploads/          # Загруженные файлы
├── logs/
│   ├── backend.log       # Логи бэкенда (если запуск через скрипт)
│   └── backend.pid       # PID файл
├── scripts/              # Скрипты развертывания
└── .env                  # Переменные окружения (опционально)

На сервере (Nginx):
/etc/nginx/sites-available/cursospring   # Конфиг: статика + прокси /api, client_max_body_size 1024M
/usr/share/nginx/html/cursospring/       # Статика фронта (если деплой через deploy-ubuntu22-minimal.sh)
```

---

## Troubleshooting

### Бэкенд не запускается
1. Проверьте переменные окружения: `echo $SPRING_DATASOURCE_URL`
2. Проверьте подключение к БД: `psql -U postgres -d cursospring`
3. Проверьте логи: `tail -f logs/backend.log`

### Фронтенд не подключается к бэкенду
1. Проверьте CORS в `WebConfig.java`
2. Убедитесь, что бэкенд запущен: `curl http://localhost:8080/api/auth/me`
3. Проверьте конфиг nginx: `location /api` должен проксировать на `http://127.0.0.1:8080`

### 413 при загрузке файла (Request Entity Too Large)
В конфиге nginx добавьте `client_max_body_size 1024M;` в блок `server` и в блок `location /api`, затем `nginx -t && systemctl reload nginx`. Подробнее — в `scripts/DEPLOY-UBUNTU22.md`.

### Файлы не сохраняются
1. Проверьте права на каталог: `ls -la data/uploads`
2. Проверьте переменную `APP_UPLOAD_DIR`
3. Убедитесь, что каталог существует: `mkdir -p data/uploads`
