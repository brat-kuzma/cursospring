#!/bin/bash
# ============================================
# Проверка доступности фронтенда
# ============================================

echo "============================================"
echo "Проверка доступности фронтенда"
echo "============================================"

# Получение IP адреса
SERVER_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "IP адрес сервера: $SERVER_IP"

# Проверка порта 5173
echo ""
echo "1. Проверка порта 5173:"
if netstat -tlnp 2>/dev/null | grep -q ":5173"; then
    echo "   ✅ Порт 5173 слушается"
    netstat -tlnp 2>/dev/null | grep ":5173"
else
    echo "   ❌ Порт 5173 не слушается"
fi

# Проверка firewall
echo ""
echo "2. Проверка firewall (ufw):"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | grep -i "Status:" | awk '{print $2}')
    echo "   UFW статус: $UFW_STATUS"
    if [ "$UFW_STATUS" = "active" ]; then
        if ufw status | grep -q "5173"; then
            echo "   ✅ Порт 5173 разрешён в ufw"
        else
            echo "   ⚠️  Порт 5173 не разрешён в ufw"
            echo "   Выполните: ufw allow 5173/tcp"
        fi
    fi
else
    echo "   ⚠️  ufw не установлен"
fi

# Проверка iptables
echo ""
echo "3. Проверка iptables:"
if iptables -L -n 2>/dev/null | grep -q "5173"; then
    echo "   ✅ Порт 5173 есть в правилах iptables"
else
    echo "   ⚠️  Порт 5173 может быть заблокирован в iptables"
fi

# Проверка процесса Vite
echo ""
echo "4. Проверка процесса Vite:"
if pgrep -f "vite" > /dev/null; then
    echo "   ✅ Процесс Vite запущен"
    ps aux | grep vite | grep -v grep
else
    echo "   ❌ Процесс Vite не найден"
fi

# Проверка локального подключения
echo ""
echo "5. Проверка локального подключения:"
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "   ✅ Локальное подключение работает"
else
    echo "   ❌ Локальное подключение не работает"
fi

# Проверка внешнего подключения
echo ""
echo "6. Проверка внешнего подключения:"
if curl -s --connect-timeout 3 http://$SERVER_IP:5173 > /dev/null 2>&1; then
    echo "   ✅ Внешнее подключение работает"
else
    echo "   ⚠️  Внешнее подключение не работает (может быть firewall)"
fi

echo ""
echo "============================================"
echo "Рекомендации:"
echo "============================================"
echo ""
echo "1. Откройте в браузере: http://$SERVER_IP:5173"
echo "   или http://91.194.3.57:5173"
echo ""
echo "2. Если не открывается, проверьте:"
echo "   - Firewall: ufw allow 5173/tcp"
echo "   - Проверьте консоль браузера (F12) на наличие ошибок"
echo "   - Проверьте, что Vite слушает на 0.0.0.0 (не только localhost)"
echo ""
echo "3. Проверьте логи Vite в терминале, где запущен npm run dev"
echo ""
