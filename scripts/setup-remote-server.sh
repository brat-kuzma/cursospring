#!/bin/bash
# ============================================
# Настройка для работы с удалённым сервером
# ============================================

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"

echo "============================================"
echo "Настройка для удалённого сервера"
echo "============================================"

# Получение IP адреса сервера
SERVER_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "IP адрес сервера: $SERVER_IP"
echo ""

read -p "Введите IP адрес или домен сервера (Enter для $SERVER_IP): " CUSTOM_IP
SERVER_IP="${CUSTOM_IP:-$SERVER_IP}"

read -p "Порт бэкенда (Enter для 8080): " BACKEND_PORT
BACKEND_PORT="${BACKEND_PORT:-8080}"

read -p "Порт фронтенда (Enter для 5173): " FRONTEND_PORT
FRONTEND_PORT="${FRONTEND_PORT:-5173}"

BACKEND_URL="http://$SERVER_IP:$BACKEND_PORT"
FRONTEND_URL="http://$SERVER_IP:$FRONTEND_PORT"

echo ""
echo "Настройки:"
echo "  Бэкенд: $BACKEND_URL"
echo "  Фронтенд: $FRONTEND_URL"
echo ""

# Обновление WebConfig.java для CORS
echo "1. Обновление CORS настроек в WebConfig.java..."
WEB_CONFIG="$PROJECT_DIR/backend/src/main/java/com/ExampleCursor/cursospring/config/WebConfig.java"

if [ -f "$WEB_CONFIG" ]; then
    # Создание backup
    cp "$WEB_CONFIG" "$WEB_CONFIG.backup"
    
    # Обновление allowedOrigins
    sed -i "s|allowedOrigins(\"http://localhost:5173\", \"http://localhost:3000\", \"http://127.0.0.1:5173\", \"http://127.0.0.1:3000\")|allowedOrigins(\"http://localhost:5173\", \"http://localhost:3000\", \"http://127.0.0.1:5173\", \"http://127.0.0.1:3000\", \"$FRONTEND_URL\")|" "$WEB_CONFIG"
    
    echo "   ✅ WebConfig.java обновлён"
else
    echo "   ⚠️  WebConfig.java не найден: $WEB_CONFIG"
fi

# Обновление vite.config.ts для прокси
echo ""
echo "2. Обновление прокси в vite.config.ts..."
VITE_CONFIG="$PROJECT_DIR/frontend/vite.config.ts"

if [ -f "$VITE_CONFIG" ]; then
    # Создание backup
    cp "$VITE_CONFIG" "$VITE_CONFIG.backup"
    
    # Обновление target прокси
    sed -i "s|target: 'http://localhost:8080'|target: '$BACKEND_URL'|" "$VITE_CONFIG"
    
    # Обновление порта если нужно
    if [ "$FRONTEND_PORT" != "5173" ]; then
        sed -i "s|port: 5173|port: $FRONTEND_PORT|" "$VITE_CONFIG"
    fi
    
    echo "   ✅ vite.config.ts обновлён"
else
    echo "   ⚠️  vite.config.ts не найден: $VITE_CONFIG"
fi

echo ""
echo "============================================"
echo "Настройка завершена!"
echo "============================================"
echo ""
echo "Следующие шаги:"
echo "1. Пересоберите бэкенд:"
echo "   cd $PROJECT_DIR"
echo "   mvn clean package -DskipTests"
echo ""
echo "2. Перезапустите бэкенд:"
echo "   $PROJECT_DIR/scripts/stop-backend.sh"
echo "   $PROJECT_DIR/scripts/start-backend.sh"
echo ""
echo "3. Перезапустите фронтенд:"
echo "   cd $PROJECT_DIR/frontend"
echo "   npm run dev"
echo ""
echo "4. Откройте в браузере: $FRONTEND_URL"
echo ""
echo "5. Проверьте firewall (если нужно):"
echo "   ufw allow $BACKEND_PORT/tcp"
echo "   ufw allow $FRONTEND_PORT/tcp"
echo ""
