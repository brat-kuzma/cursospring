#!/bin/bash
# ============================================
# Скрипт проверки подключения к базе данных
# ============================================

echo "============================================"
echo "Проверка подключения к базе данных"
echo "============================================"

# Проверка переменных окружения
echo ""
echo "1. Проверка переменных окружения:"
if [ -z "$SPRING_DATASOURCE_URL" ]; then
    echo "   ❌ SPRING_DATASOURCE_URL не задан"
else
    echo "   ✅ SPRING_DATASOURCE_URL=$SPRING_DATASOURCE_URL"
fi

if [ -z "$SPRING_DATASOURCE_USERNAME" ]; then
    echo "   ❌ SPRING_DATASOURCE_USERNAME не задан"
else
    echo "   ✅ SPRING_DATASOURCE_USERNAME=$SPRING_DATASOURCE_USERNAME"
fi

if [ -z "$SPRING_DATASOURCE_PASSWORD" ]; then
    echo "   ❌ SPRING_DATASOURCE_PASSWORD не задан"
else
    echo "   ✅ SPRING_DATASOURCE_PASSWORD=*** (скрыт)"
fi

# Извлечение параметров из URL
if [ -n "$SPRING_DATASOURCE_URL" ]; then
    DB_HOST=$(echo "$SPRING_DATASOURCE_URL" | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
    DB_PORT=$(echo "$SPRING_DATASOURCE_URL" | sed -n 's/.*:\/\/[^:]*:\([0-9]*\)\/.*/\1/p')
    DB_NAME=$(echo "$SPRING_DATASOURCE_URL" | sed -n 's/.*:\/\/[^:]*:[0-9]*\/\([^?]*\).*/\1/p')
    
    echo ""
    echo "2. Параметры подключения:"
    echo "   Host: ${DB_HOST:-localhost}"
    echo "   Port: ${DB_PORT:-5432}"
    echo "   Database: ${DB_NAME:-cursospring}"
    echo "   Username: ${SPRING_DATASOURCE_USERNAME:-postgres}"
fi

# Проверка статуса PostgreSQL
echo ""
echo "3. Проверка статуса PostgreSQL:"
if systemctl is-active --quiet postgresql; then
    echo "   ✅ PostgreSQL запущен"
elif pg_isready > /dev/null 2>&1; then
    echo "   ✅ PostgreSQL доступен (через pg_isready)"
else
    echo "   ❌ PostgreSQL не запущен или недоступен"
    echo ""
    echo "   Попробуйте запустить:"
    echo "   systemctl start postgresql"
    echo "   или"
    echo "   service postgresql start"
fi

# Проверка подключения через psql
echo ""
echo "4. Проверка подключения через psql:"
if [ -n "$SPRING_DATASOURCE_USERNAME" ] && [ -n "$SPRING_DATASOURCE_PASSWORD" ]; then
    export PGPASSWORD="$SPRING_DATASOURCE_PASSWORD"
    
    if psql -h "${DB_HOST:-localhost}" -p "${DB_PORT:-5432}" -U "$SPRING_DATASOURCE_USERNAME" -d "${DB_NAME:-cursospring}" -c "SELECT 1;" > /dev/null 2>&1; then
        echo "   ✅ Подключение успешно!"
        
        # Проверка существования таблицы tasks
        echo ""
        echo "5. Проверка таблицы tasks:"
        if psql -h "${DB_HOST:-localhost}" -p "${DB_PORT:-5432}" -U "$SPRING_DATASOURCE_USERNAME" -d "${DB_NAME:-cursospring}" -c "\dt tasks" > /dev/null 2>&1; then
            echo "   ✅ Таблица tasks существует"
        else
            echo "   ⚠️  Таблица tasks не найдена"
            echo "   Создайте её: см. backend/sql/create_database_simple.sql"
        fi
    else
        echo "   ❌ Не удалось подключиться к базе данных"
        echo ""
        echo "   Возможные причины:"
        echo "   - База данных '${DB_NAME:-cursospring}' не существует"
        echo "   - Неверный пароль"
        echo "   - Пользователь '$SPRING_DATASOURCE_USERNAME' не имеет прав доступа"
        echo ""
        echo "   Попробуйте создать БД:"
        echo "   su - postgres -c \"psql -c 'CREATE DATABASE ${DB_NAME:-cursospring};'\""
    fi
    unset PGPASSWORD
else
    echo "   ⚠️  Переменные окружения не заданы, пропускаю проверку"
fi

echo ""
echo "============================================"
