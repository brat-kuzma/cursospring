# Развёртывание на Ubuntu 22 (минимум ресурсов)

Один скрипт ставит PostgreSQL, собирает бэкенд и фронт, поднимает nginx. SSH не блокируется: перед включением firewall всегда разрешается порт 22.

## Требования

- Сервер Ubuntu 22 (доступ по SSH под root или sudo)
- Проект уже скопирован в `/opt/cursospring` (git clone или scp)

## Шаг 1: Скопировать проект на сервер

С вашего компьютера:

```bash
# Вариант А: клонирование
ssh root@IP_СЕРВЕРА "mkdir -p /opt && git clone YOUR_REPO /opt/cursospring"

# Вариант Б: через scp (если нет git на сервере)
scp -r /путь/к/cursospring root@IP_СЕРВЕРА:/opt/
```

## Шаг 2: Задать пароль БД (опционально)

Если не задать, скрипт спросит при запуске.

```bash
ssh root@IP_СЕРВЕРА
export POSTGRES_PASSWORD='ваш_надёжный_пароль'
```

## Шаг 3: Запустить деплой

**Важно:** лучше запускать в `screen` или `tmux`, чтобы при обрыве SSH процесс не убился.

```bash
ssh root@IP_СЕРВЕРА

# Установить screen, если нет
apt install -y screen

# Запуск в screen (сессия переживёт обрыв SSH)
screen -S deploy
cd /opt/cursospring
chmod +x scripts/deploy-ubuntu22-minimal.sh
./scripts/deploy-ubuntu22-minimal.sh
```

Отсоединиться от screen: `Ctrl+A`, затем `D`.  
Вернуться: `screen -r deploy`.

## Шаг 4: Проверить

- Frontend: http://IP_СЕРВЕРА/
- Backend API: http://IP_СЕРВЕРА:8080/
- Логин: **user** / **password**

## Что делает скрипт

1. **Firewall (ufw):** сбрасывает правила, разрешает **22 (SSH)**, 80, 8080, включает ufw — SSH остаётся доступен.
2. Ставит: PostgreSQL, Java 21 (или Adoptium), Maven, Node.js 20, nginx.
3. Настраивает PostgreSQL: пароль postgres, БД `cursospring`, при необходимости создаёт таблицу из `backend/sql/create_database_simple.sql`.
4. Собирает бэкенд (Maven), фронт (npm build).
5. Раздаёт фронт через nginx (статика + прокси `/api` на 8080).
6. Создаёт systemd-сервис `cursospring` и запускает бэкенд.

## Минимум ресурсов

- Один процесс Java (бэкенд), PostgreSQL, nginx. Node.js используется только на этапе сборки.
- Фронт отдаётся как статика, без dev-сервера.

## Если проект ещё не в /opt/cursospring

Скрипт проверяет наличие каталога. Если его нет — выведет сообщение и выйдет. Сначала скопируйте или клонируйте проект в `/opt/cursospring`, затем снова запустите скрипт.

## Полезные команды после деплоя

```bash
# Логи бэкенда
journalctl -u cursospring -f

# Статус
systemctl status cursospring nginx postgresql

# Перезапуск бэкенда
systemctl restart cursospring

# Остановка
systemctl stop cursospring
```

## Безопасность SSH

- Скрипт первым делом добавляет правило `ufw allow 22/tcp` и только потом включает ufw.
- Всё равно держите вторую SSH-сессию открытой во время первого запуска или используйте screen/tmux.
