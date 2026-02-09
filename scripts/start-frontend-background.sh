#!/bin/bash
# ============================================
# Скрипт запуска фронтенда в фоне
# Терминал остаётся свободным
# ============================================

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
FRONTEND_DIR="$PROJECT_DIR/frontend"
LOG_FILE="${LOG_FILE:-$PROJECT_DIR/logs/frontend.log}"
PID_FILE="${PID_FILE:-$PROJECT_DIR/logs/frontend.pid}"

echo "============================================"
echo "Запуск фронтенда в фоне"
echo "============================================"

# Создание каталога для логов
mkdir -p "$(dirname "$LOG_FILE")"

# Проверка, не запущен ли уже фронтенд
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "⚠️  Фронтенд уже запущен (PID: $OLD_PID)"
        echo "Остановите его перед запуском: $PROJECT_DIR/scripts/stop-frontend.sh"
        exit 1
    else
        echo "⚠️  Старый PID файл найден, но процесс не запущен. Удаляю PID файл."
        rm -f "$PID_FILE"
    fi
fi

cd "$FRONTEND_DIR" || exit 1

# Проверка наличия node_modules
if [ ! -d "node_modules" ]; then
    echo ""
    echo "⚠️  Зависимости не установлены. Устанавливаю..."
    npm install
fi

echo ""
echo "Запуск фронтенда в фоне..."
echo "Логи: $LOG_FILE"
echo "PID файл: $PID_FILE"

# Запуск в фоне через nohup
cd "$FRONTEND_DIR"
nohup npm run dev > "$LOG_FILE" 2>&1 &

PID=$!
echo $PID > "$PID_FILE"

# Небольшая задержка для проверки, что процесс запустился
sleep 2

if ps -p "$PID" > /dev/null 2>&1; then
    echo "✅ Фронтенд запущен в фоне (PID: $PID)"
    echo ""
    echo "Доступ:"
    echo "  - Локально: http://localhost:5173"
    echo "  - Сети: http://$(hostname -I | awk '{print $1}'):5173"
    echo ""
    echo "Управление:"
    echo "  Просмотр логов: tail -f $LOG_FILE"
    echo "  Остановка: $PROJECT_DIR/scripts/stop-frontend.sh"
    echo "  Статус: ps -p $PID"
else
    echo "❌ Ошибка запуска фронтенда"
    echo "Проверьте логи: tail -f $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi
