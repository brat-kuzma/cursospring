#!/bin/bash
# ============================================
# Быстрая установка Java 21 (если openjdk-21-jdk недоступен)
# Запускать от root
# ============================================

set -e

echo "Установка Java 21 через Adoptium..."

apt update
apt install -y wget apt-transport-https ca-certificates gnupg

mkdir -p /etc/apt/keyrings
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

apt update
apt install -y temurin-21-jdk

java -version
