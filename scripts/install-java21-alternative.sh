#!/bin/bash
# ============================================
# Альтернативная установка Java 21 на Debian/Ubuntu
# Используется, если openjdk-21-jdk недоступен в репозиториях
# Запускать от root
# ============================================

set -e

echo "============================================"
echo "Установка Java 21 через Adoptium (Eclipse Temurin)"
echo "============================================"

# Обновление списка пакетов
apt update

# Установка необходимых зависимостей
echo ""
echo "1. Установка зависимостей..."
apt install -y wget apt-transport-https ca-certificates gnupg

# Добавление репозитория Adoptium
echo ""
echo "2. Добавление репозитория Adoptium..."
mkdir -p /etc/apt/keyrings
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

# Обновление и установка Java 21
echo ""
echo "3. Установка Java 21..."
apt update
apt install -y temurin-21-jdk

# Проверка установки
echo ""
echo "============================================"
echo "Проверка установки Java:"
echo "============================================"
java -version

echo ""
echo "Java 21 успешно установлена!"
