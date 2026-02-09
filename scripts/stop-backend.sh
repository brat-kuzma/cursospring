#!/bin/bash
# ============================================
# Скрипт остановки бэкенда cursospring
# ============================================

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
PID_FILE="${PID_FILE:-$PROJECT_DIR/logs/backend.pid}"

if [ ! -f "$PID_FILE" ]; then
    echo "⚠️  PID файл не найден. Бэкенд может быть не запущен."
    exit 1
fi

PID=$(cat "$PID_FILE")

if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "⚠️  Процесс с PID $PID не найден. Удаляю PID файл."
    rm -f "$PID_FILE"
    exit 1
fi

echo "Остановка бэкенда (PID: $PID)..."
kill "$PID"

# Ждём завершения процесса
for i in {1..10}; do
    if ! ps -p "$PID" > /dev/null 2>&1; then
        echo "✅ Бэкенд остановлен"
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

# Если не остановился, принудительно
echo "⚠️  Процесс не остановился, принудительное завершение..."
kill -9 "$PID"
rm -f "$PID_FILE"
echo "✅ Бэкенд остановлен принудительно"
