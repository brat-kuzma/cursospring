#!/bin/bash
# ============================================
# Скрипт развертывания фронтенда cursospring
# Запускать от root или пользователя с правами
# ============================================

set -e

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
FRONTEND_DIR="$PROJECT_DIR/frontend"
BUILD_DIR="$FRONTEND_DIR/dist"
BACKEND_URL="${BACKEND_URL:-http://localhost:8080}"

echo "============================================"
echo "Развертывание фронтенда cursospring"
echo "============================================"

cd "$FRONTEND_DIR" || exit 1

echo ""
echo "1. Установка зависимостей npm..."
npm install

echo ""
echo "2. Сборка проекта для продакшена..."
# Если нужно указать URL бэкенда через переменную окружения
export VITE_API_URL="$BACKEND_URL"
npm run build

if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Ошибка: каталог сборки не найден!"
    exit 1
fi

echo ""
echo "✅ Сборка завершена: $BUILD_DIR"
echo ""
echo "Следующие шаги:"
echo "1. Настройте веб-сервер (nginx/apache) для раздачи статики из $BUILD_DIR"
echo "2. Или используйте встроенный сервер: cd $FRONTEND_DIR && npm run preview"
echo ""
