#!/bin/bash
# Исправление 413 Request Entity Too Large в nginx (лимит загрузки до 1 ГБ)
# Запускать на сервере от root

set -e
CONF="/etc/nginx/sites-available/cursospring"

if [ ! -f "$CONF" ]; then
    echo "Файл $CONF не найден."
    exit 1
fi

# Добавляем client_max_body_size в server и в location /api если ещё нет
if ! grep -q "client_max_body_size" "$CONF"; then
    sed -i '/server {/a \    client_max_body_size 1024M;' "$CONF"
    sed -i '/location \/api {/a \        client_max_body_size 1024M;' "$CONF"
    echo "Добавлен client_max_body_size 1024M"
else
    echo "Лимит уже настроен."
fi

nginx -t && systemctl reload nginx
echo "Nginx перезагружен. Загрузка файлов до 1 ГБ должна работать."
