# Настройка для удалённого сервера

## Быстрая настройка

```bash
cd /opt/cursospring
chmod +x scripts/setup-remote-server.sh
./scripts/setup-remote-server.sh
```

Скрипт автоматически:
- Определит IP адрес сервера
- Обновит CORS настройки в `WebConfig.java`
- Обновит прокси в `vite.config.ts`
- Даст инструкции по пересборке и перезапуску

---

## Ручная настройка

### 1. Узнайте IP адрес сервера

```bash
hostname -I
# или
ip addr show
```

### 2. Обновите CORS в WebConfig.java

Откройте `backend/src/main/java/com/ExampleCursor/cursospring/config/WebConfig.java`:

```java
.allowedOrigins(
    "http://localhost:5173", 
    "http://localhost:3000", 
    "http://127.0.0.1:5173", 
    "http://127.0.0.1:3000",
    "http://ВАШ_IP:5173",  // Добавьте эту строку
    "http://ВАШ_ДОМЕН:5173" // Или домен, если есть
)
```

### 3. Обновите прокси в vite.config.ts

Откройте `frontend/vite.config.ts`:

```typescript
server: {
  port: 5173,
  host: '0.0.0.0', // Добавьте эту строку для доступа снаружи
  proxy: {
    '/api': {
      target: 'http://ВАШ_IP:8080', // Замените localhost на IP
      changeOrigin: true,
      secure: false,
      // ... остальное
    },
  },
}
```

### 4. Пересоберите и перезапустите

```bash
# Бэкенд
cd /opt/cursospring
mvn clean package -DskipTests
./scripts/stop-backend.sh
./scripts/start-backend.sh

# Фронтенд
cd /opt/cursospring/frontend
npm run dev
```

---

## Настройка firewall

Если используется ufw:

```bash
# Разрешить порты
ufw allow 8080/tcp  # Бэкенд
ufw allow 5173/tcp  # Фронтенд (dev)

# Проверка статуса
ufw status
```

Если используется iptables:

```bash
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 5173 -j ACCEPT
```

---

## Доступ к приложению

После настройки откройте в браузере:

- **Фронтенд**: `http://ВАШ_IP:5173`
- **Бэкенд API**: `http://ВАШ_IP:8080/api/auth/me`

---

## Проверка работы

### 1. Проверка бэкенда

```bash
# С сервера
curl http://localhost:8080/api/auth/me

# С вашего компьютера
curl http://ВАШ_IP:8080/api/auth/me
```

### 2. Проверка фронтенда

Откройте в браузере: `http://ВАШ_IP:5173`

Если видите страницу логина — всё работает!

---

## Продакшен (nginx + статика)

Для продакшена лучше использовать nginx:

1. Соберите фронтенд: `cd frontend && npm run build`
2. Настройте nginx (см. `scripts/DEPLOY.md`)
3. Откройте только порт 80/443 в firewall

---

## Troubleshooting

### Фронтенд не подключается к бэкенду

1. Проверьте CORS настройки в `WebConfig.java`
2. Проверьте прокси в `vite.config.ts`
3. Проверьте firewall: `ufw status`

### Браузер блокирует запросы

1. Убедитесь, что IP адрес добавлен в `allowedOrigins`
2. Проверьте, что используется `http://` (не `https://`) если нет SSL

### Порт недоступен извне

1. Проверьте firewall: `ufw status` или `iptables -L`
2. Проверьте, что сервис слушает на `0.0.0.0`, а не `127.0.0.1`:
   ```bash
   netstat -tlnp | grep -E '8080|5173'
   ```
