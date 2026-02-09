#!/bin/bash
# ============================================
# Скрипт установки всех зависимостей для cursospring на Debian/Ubuntu
# Запускать от root
# ============================================

set -e  # Остановка при ошибке

echo "============================================"
echo "Установка зависимостей для cursospring"
echo "============================================"

# Обновление списка пакетов
echo ""
echo "1. Обновление списка пакетов..."
apt update

# ============================================
# Backend зависимости
# ============================================

echo ""
echo "2. Установка Java 21 JDK..."
# Java 21 доступна в Debian 12+ (bookworm) и Ubuntu 23.10+
# Для более старых версий используем альтернативный метод

if apt-cache show openjdk-21-jdk &> /dev/null; then
    echo "   Java 21 найдена в репозиториях, устанавливаю..."
    apt install -y openjdk-21-jdk
else
    echo "   Java 21 не найдена в репозиториях, использую альтернативный метод..."
    echo "   Устанавливаю через Adoptium (Eclipse Temurin)..."
    
    # Установка необходимых зависимостей
    apt install -y wget apt-transport-https ca-certificates gnupg
    
    # Добавление репозитория Adoptium
    mkdir -p /etc/apt/keyrings
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
    
    apt update
    apt install -y temurin-21-jdk
fi

echo ""
echo "3. Установка Maven..."
apt install -y maven

# ============================================
# PostgreSQL (если ещё не установлен)
# ============================================

echo ""
echo "4. Проверка PostgreSQL..."
if ! command -v psql &> /dev/null; then
    echo "   PostgreSQL не найден, устанавливаю..."
    apt install -y postgresql postgresql-contrib
    echo "   PostgreSQL установлен. Не забудьте настроить пароль для пользователя postgres!"
else
    echo "   PostgreSQL уже установлен ✓"
fi

# ============================================
# Frontend зависимости
# ============================================

echo ""
echo "5. Установка Node.js и npm..."
# Используем NodeSource репозиторий для актуальной версии Node.js
# Для Debian/Ubuntu рекомендуется Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# ============================================
# Инструменты для сборки (для нативных зависимостей npm)
# ============================================

echo ""
echo "6. Установка инструментов для сборки (build-essential)..."
apt install -y build-essential

# ============================================
# Git (для клонирования репозитория)
# ============================================

echo ""
echo "7. Установка Git..."
apt install -y git

# ============================================
# Проверка установки
# ============================================

echo ""
echo "============================================"
echo "Проверка установленных версий:"
echo "============================================"

echo ""
echo "Java:"
java -version 2>&1 | head -n 1

echo ""
echo "Maven:"
mvn -version | head -n 1

echo ""
echo "PostgreSQL:"
psql --version

echo ""
echo "Node.js:"
node --version

echo ""
echo "npm:"
npm --version

echo ""
echo "Git:"
git --version

echo ""
echo "============================================"
echo "Установка завершена!"
echo "============================================"
echo ""
echo "Следующие шаги:"
echo "1. Настройте PostgreSQL (если ещё не настроен):"
echo "   su - postgres -c \"psql\""
echo "   ALTER USER postgres PASSWORD 'ваш_пароль';"
echo ""
echo "2. Создайте базу данных (см. backend/sql/README.md)"
echo ""
echo "3. Клонируйте репозиторий:"
echo "   git clone <ваш_репозиторий>"
echo ""
echo "4. Настройте переменные окружения для подключения к БД"
echo "   export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/cursospring"
echo "   export SPRING_DATASOURCE_USERNAME=postgres"
echo "   export SPRING_DATASOURCE_PASSWORD=ваш_пароль"
echo ""
echo "5. Запустите backend:"
echo "   cd cursospring"
echo "   mvn spring-boot:run"
echo ""
echo "6. В другом терминале запустите frontend:"
echo "   cd cursospring/frontend"
echo "   npm install"
echo "   npm run dev"
echo ""
