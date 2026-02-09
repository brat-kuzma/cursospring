#!/bin/bash
# ============================================
# Скрипт проверки статуса фронтенда
# ============================================

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
PID_FILE="${PID_FILE:-$PROJECT_DIR/logs/frontend.pid}"
LOG_FILE="${LOG_FILE:-$PROJECT_DIR/logs/frontend.log}"

echo "============================================"
echo "Статус фронтенда"
echo "============================================"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "✅ Фронтенд запущен"
        echo "   PID: $PID"
        echo "   Логи: $LOG_FILE"
        echo ""
        
        # Проверка порта
        if netstat -tlnp 2>/dev/null | grep -q ":5173"; then
            echo "✅ Порт 5173 слушается"
            SERVER_IP=$(hostname -I | awk '{print $1}')
            echo ""
            echo "Доступ:"
            echo "   Локально: http://localhost:5173"
            echo "   Сети: http://$SERVER_IP:5173"
        else
            echo "⚠️  Порт 5173 не слушается"
        fi
        
        echo ""
        echo "Последние строки логов:"
        if [ -f "$LOG_FILE" ]; then
            tail -n 5 "$LOG_FILE"
        else
            echo "   Лог файл не найден"
        fi
    else
        echo "❌ Фронтенд не запущен (PID файл существует, но процесс не найден)"
        echo "   Удаляю старый PID файл..."
        rm -f "$PID_FILE"
    fi
else
    # Поиск процесса Vite
    VITE_PID=$(pgrep -f "vite.*5173" | head -n 1)
    
    if [ -n "$VITE_PID" ]; then
        echo "⚠️  Фронтенд запущен, но PID файл не найден"
        echo "   PID: $VITE_PID"
        echo "   Рекомендуется остановить и запустить через скрипт"
    else
        echo "❌ Фронтенд не запущен"
    fi
fi

echo ""
