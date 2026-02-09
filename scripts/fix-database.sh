#!/bin/bash
# ============================================
# Скрипт исправления проблем с базой данных
# ============================================

set -e

echo "============================================"
echo "Исправление проблем с базой данных"
echo "============================================"

# Проверка переменных окружения
if [ -z "$SPRING_DATASOURCE_URL" ] || [ -z "$SPRING_DATASOURCE_USERNAME" ] || [ -z "$SPRING_DATASOURCE_PASSWORD" ]; then
    echo ""
    echo "❌ Переменные окружения не заданы!"
    echo ""
    echo "Установите их:"
    echo "  export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring"
    echo "  export SPRING_DATASOURCE_USERNAME=postgres"
    echo "  export SPRING_DATASOURCE_PASSWORD=ваш_пароль"
    exit 1
fi

# Извлечение имени БД из URL
DB_NAME=$(echo "$SPRING_DATASOURCE_URL" | sed -n 's/.*:\/\/[^:]*:[0-9]*\/\([^?]*\).*/\1/p')
DB_NAME="${DB_NAME:-cursospring}"
DB_USER="${SPRING_DATASOURCE_USERNAME:-postgres}"

echo ""
echo "1. Проверка статуса PostgreSQL..."
if ! systemctl is-active --quiet postgresql && ! pg_isready > /dev/null 2>&1; then
    echo "   Запуск PostgreSQL..."
    systemctl start postgresql || service postgresql start
    sleep 2
fi

echo ""
echo "2. Проверка существования базы данных '$DB_NAME'..."
export PGPASSWORD="$SPRING_DATASOURCE_PASSWORD"

if psql -h localhost -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "   ✅ База данных '$DB_NAME' существует"
else
    echo "   ⚠️  База данных '$DB_NAME' не найдена, создаю..."
    su - postgres -c "psql -c \"CREATE DATABASE $DB_NAME;\""
    echo "   ✅ База данных создана"
fi

echo ""
echo "3. Проверка таблицы tasks..."
if psql -h localhost -U "$DB_USER" -d "$DB_NAME" -c "\dt tasks" > /dev/null 2>&1; then
    echo "   ✅ Таблица tasks существует"
else
    echo "   ⚠️  Таблица tasks не найдена, создаю..."
    
    PROJECT_DIR="${PROJECT_DIR:-/opt/cursospring}"
    SQL_FILE="$PROJECT_DIR/backend/sql/create_database_simple.sql"
    
    if [ -f "$SQL_FILE" ]; then
        psql -h localhost -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE"
        echo "   ✅ Таблица tasks создана"
    else
        echo "   ❌ SQL файл не найден: $SQL_FILE"
        echo "   Создайте таблицу вручную (см. backend/sql/create_database_simple.sql)"
    fi
fi

unset PGPASSWORD

echo ""
echo "============================================"
echo "Проверка подключения..."
echo "============================================"

export PGPASSWORD="$SPRING_DATASOURCE_PASSWORD"
if psql -h localhost -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Подключение к базе данных работает!"
    echo ""
    echo "Теперь можно запустить бэкенд:"
    echo "  /opt/cursospring/scripts/start-backend.sh"
else
    echo "❌ Не удалось подключиться к базе данных"
    echo "Проверьте логи выше на наличие ошибок"
fi
unset PGPASSWORD
