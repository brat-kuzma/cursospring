# Быстрый старт развертывания

## 1. Настройка переменных окружения

```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=ваш_пароль
export APP_UPLOAD_DIR=/opt/cursospring/data/uploads
```

## 2. Развертывание бэкенда

```bash
cd /opt/cursospring
./scripts/deploy-backend.sh
./scripts/start-backend.sh
```

Проверка: `curl http://localhost:8080/api/auth/me`

## 3. Развертывание фронтенда

### Вариант А: Dev-сервер (для тестирования)
```bash
cd /opt/cursospring/frontend
npm install
npm run dev
```
Откройте: http://localhost:5173

### Вариант Б: Продакшен (сборка + nginx)
```bash
cd /opt/cursospring/frontend
npm install
npm run build
# Настройте nginx (см. DEPLOY.md)
```

## 4. Управление

```bash
# Остановка бэкенда
/opt/cursospring/scripts/stop-backend.sh

# Просмотр логов
tail -f /opt/cursospring/logs/backend.log

# Перезапуск
/opt/cursospring/scripts/stop-backend.sh && /opt/cursospring/scripts/start-backend.sh
```

Подробная инструкция: `scripts/DEPLOY.md`
