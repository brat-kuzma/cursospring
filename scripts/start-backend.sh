#!/bin/bash
# ============================================
# Скрипт запуска бэкенда cursospring
# Запускать от root или пользователя с правами
# ============================================

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
BACKEND_DIR="$PROJECT_DIR/backend"
JAR_FILE="$PROJECT_DIR/target/cursospring-0.0.1-SNAPSHOT.jar"
LOG_FILE="${LOG_FILE:-$PROJECT_DIR/logs/backend.log}"
PID_FILE="${PID_FILE:-$PROJECT_DIR/logs/backend.pid}"

# Создание каталога для логов
mkdir -p "$(dirname "$LOG_FILE")"

# Проверка переменных окружения
if [ -z "$SPRING_DATASOURCE_URL" ] || [ -z "$SPRING_DATASOURCE_USERNAME" ] || [ -z "$SPRING_DATASOURCE_PASSWORD" ]; then
    echo "❌ Переменные окружения для БД не заданы!"
    echo ""
    echo "Установите их:"
    echo "  export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring"
    echo "  export SPRING_DATASOURCE_USERNAME=postgres"
    echo "  export SPRING_DATASOURCE_PASSWORD=ваш_пароль"
    exit 1
fi

# Проверка, не запущен ли уже бэкенд
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "⚠️  Бэкенд уже запущен (PID: $OLD_PID)"
        echo "Остановите его перед запуском: $PROJECT_DIR/scripts/stop-backend.sh"
        exit 1
    fi
fi

cd "$PROJECT_DIR" || exit 1

echo "Запуск бэкенда..."
echo "Логи: $LOG_FILE"

# Запуск в фоне
nohup java -jar \
    -Dspring.profiles.active=prod \
    "$JAR_FILE" \
    > "$LOG_FILE" 2>&1 &

PID=$!
echo $PID > "$PID_FILE"

echo "✅ Бэкенд запущен (PID: $PID)"
echo "Проверка логов: tail -f $LOG_FILE"
echo "Остановка: $PROJECT_DIR/scripts/stop-backend.sh"
