#!/bin/bash
# ============================================
# Скрипт развертывания бэкенда cursospring
# Запускать от root или пользователя с правами на каталог проекта
# ============================================

set -e

PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
BACKEND_DIR="$PROJECT_DIR/backend"
JAR_FILE="$BACKEND_DIR/target/cursospring-0.0.1-SNAPSHOT.jar"

echo "============================================"
echo "Развертывание бэкенда cursospring"
echo "============================================"

# Проверка переменных окружения
if [ -z "$SPRING_DATASOURCE_URL" ] || [ -z "$SPRING_DATASOURCE_USERNAME" ] || [ -z "$SPRING_DATASOURCE_PASSWORD" ]; then
    echo ""
    echo "⚠️  ВНИМАНИЕ: Переменные окружения для БД не заданы!"
    echo ""
    echo "Установите их перед запуском:"
    echo "  export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring"
    echo "  export SPRING_DATASOURCE_USERNAME=postgres"
    echo "  export SPRING_DATASOURCE_PASSWORD=ваш_пароль"
    echo ""
    echo "Или создайте файл $PROJECT_DIR/.env с содержимым:"
    echo "  SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring"
    echo "  SPRING_DATASOURCE_USERNAME=postgres"
    echo "  SPRING_DATASOURCE_PASSWORD=ваш_пароль"
    echo ""
    exit 1
fi

# Переход в каталог проекта
cd "$PROJECT_DIR" || exit 1

echo ""
echo "1. Сборка проекта (Maven)..."
cd "$PROJECT_DIR"
mvn clean package -DskipTests

if [ ! -f "$JAR_FILE" ]; then
    echo "❌ Ошибка: JAR файл не найден после сборки!"
    exit 1
fi

echo ""
echo "✅ Сборка завершена: $JAR_FILE"

echo ""
echo "2. Создание каталога для загрузок..."
mkdir -p "$PROJECT_DIR/data/uploads"
chmod 755 "$PROJECT_DIR/data/uploads"

echo ""
echo "============================================"
echo "Бэкенд готов к запуску!"
echo "============================================"
echo ""
echo "Запуск бэкенда:"
echo "  cd $PROJECT_DIR"
echo "  java -jar $JAR_FILE"
echo ""
echo "Или используйте скрипт запуска:"
echo "  $PROJECT_DIR/scripts/start-backend.sh"
echo ""
