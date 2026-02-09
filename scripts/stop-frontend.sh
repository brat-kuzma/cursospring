#!/bin/bash
# ============================================
# Скрипт остановки фронтенда
# ============================================

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
PID_FILE="${PID_FILE:-$PROJECT_DIR/logs/frontend.pid}"

echo "============================================"
echo "Остановка фронтенда"
echo "============================================"

if [ ! -f "$PID_FILE" ]; then
    echo "⚠️  PID файл не найден. Поиск процесса Vite..."
    
    # Поиск процесса Vite
    VITE_PID=$(pgrep -f "vite.*5173" | head -n 1)
    
    if [ -n "$VITE_PID" ]; then
        echo "Найден процесс Vite (PID: $VITE_PID)"
        kill "$VITE_PID"
        echo "✅ Фронтенд остановлен"
    else
        echo "⚠️  Процесс Vite не найден. Фронтенд может быть не запущен."
        exit 1
    fi
else
    PID=$(cat "$PID_FILE")
    
    if ! ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  Процесс с PID $PID не найден. Удаляю PID файл."
        rm -f "$PID_FILE"
        exit 1
    fi
    
    echo "Остановка фронтенда (PID: $PID)..."
    
    # Остановка процесса и всех дочерних процессов (npm и node)
    pkill -P "$PID" 2>/dev/null
    kill "$PID" 2>/dev/null
    
    # Ждём завершения процесса
    for i in {1..10}; do
        if ! ps -p "$PID" > /dev/null 2>&1; then
            echo "✅ Фронтенд остановлен"
            rm -f "$PID_FILE"
            exit 0
        fi
        sleep 1
    done
    
    # Если не остановился, принудительно
    echo "⚠️  Процесс не остановился, принудительное завершение..."
    kill -9 "$PID" 2>/dev/null
    pkill -9 -P "$PID" 2>/dev/null
    rm -f "$PID_FILE"
    echo "✅ Фронтенд остановлен принудительно"
fi
