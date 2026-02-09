#!/bin/bash
# ============================================
# Скрипт запуска фронтенда (dev-сервер)
# ============================================

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
FRONTEND_DIR="$PROJECT_DIR/frontend"

echo "============================================"
echo "Запуск фронтенда cursospring"
echo "============================================"

cd "$FRONTEND_DIR" || exit 1

# Проверка наличия node_modules
if [ ! -d "node_modules" ]; then
    echo ""
    echo "⚠️  Зависимости не установлены. Устанавливаю..."
    npm install
fi

echo ""
echo "Запуск dev-сервера..."
echo "Фронтенд будет доступен на: http://localhost:5173"
echo ""
echo "Для остановки нажмите Ctrl+C"
echo ""

npm run dev
