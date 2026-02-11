# Развёртывание в Docker

Приложение собирается в **три контейнера**:

| Сервис    | Назначение |
|-----------|------------|
| **postgres** | PostgreSQL 16, база `cursospring` |
| **backend**  | Spring Boot (REST API, задачи, файлы, авторизация) |
| **frontend** | Собранный React (Vite) + nginx: статика и прокси `/api` на бэкенд |

Браузер обращается только к **frontend** (порт 8080); nginx отдаёт SPA и проксирует запросы к API на backend. БД в контейнере — для простого развёртывания «с нуля» и малого продакшена.

---

## Запуск с нуля (локально, например на Mac)

### Требования

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (или Docker Engine + Docker Compose)
- Git (если клонируете репо)

### Шаги

1. **Клонируйте репозиторий** (или откройте уже склонированный проект):
   ```bash
   cd /path/to/cursospring
   ```

2. **Опционально: настройте переменные окружения**  
   Скопируйте пример и при необходимости отредактируйте (пароль БД, логин/пароль приложения):
   ```bash
   cp env.docker.example .env
   ```
   Если не создавать `.env`, будут использованы значения по умолчанию: пароль БД `postgres`, вход в приложение `user` / `password`.

3. **Соберите образы и запустите контейнеры**:
   ```bash
   docker compose up -d --build
   ```
   Первый запуск займёт несколько минут (сборка backend и frontend).

4. **Откройте приложение в браузере**:
   ```
   http://localhost:8080
   ```
   Логин по умолчанию: **user** / **password**.

5. **Остановка**:
   ```bash
   docker compose down
   ```
   Данные БД и загруженные файлы сохраняются в томах Docker. Чтобы удалить и их:
   ```bash
   docker compose down -v
   ```

---

## Полезные команды

| Команда | Описание |
|---------|----------|
| `docker compose up -d --build` | Сборка и запуск в фоне |
| `docker compose logs -f` | Просмотр логов всех сервисов |
| `docker compose logs -f backend` | Логи только бэкенда |
| `docker compose ps` | Статус контейнеров |
| `docker compose down` | Остановка и удаление контейнеров (тома остаются) |
| `docker compose down -v` | Остановка и удаление контейнеров и томов |

---

## Как лучше деплоить на удалённый сервер

### Вариант А: Сборка образов локально (или в CI) и перенос на сервер

- **Локально (или в CI)** собираете образы, пушите в **Docker Registry** (Docker Hub, GitHub Container Registry, приватный registry). На сервере только `docker compose pull` и `docker compose up -d`.
- **Плюсы**: на сервере не нужны Java, Maven, Node.js; быстрый деплой; один и тот же образ тестируете локально и выкатываете в прод.
- **Минусы**: нужен registry (или спасение образов в файл и загрузка на сервер через `docker save`/`docker load`).

Пример с registry (образы с тегом вашего репо):
```bash
# Локально: сборка и пуш
docker compose -f docker-compose.yml -f docker-compose.prod.yml build
docker tag cursospring-frontend:latest your-registry/cursospring-frontend:latest
docker tag cursospring-backend:latest your-registry/cursospring-backend:latest
docker push your-registry/cursospring-frontend:latest
docker push your-registry/cursospring-backend:latest

# На сервере: pull и запуск (postgres можно оставить из docker-compose или вынести в отдельный сервер БД)
```

### Вариант Б: Сборка на сервере из исходников

- На сервере: `git clone` (или копирование кода), затем `docker compose up -d --build`.
- **Плюсы**: не нужен registry; всё из одного репозитория.
- **Минусы**: на сервере при сборке нужны ресурсы (память, CPU); первый деплой и пересборка дольше.

Для небольшого проекта или одного сервера оба варианта допустимы; для регулярных релизов чаще выбирают вариант А (сборка в CI + registry).

---

## БД в контейнере: когда да, когда нет

- **В контейнере (как сейчас)** — удобно для разработки и для «малого» продакшена: один `docker compose up`, всё поднимается с нуля. Данные в named volume, перезапуск контейнеров их не стирает.
- **Вне контейнера** — имеет смысл, когда БД уже есть (управляемый PostgreSQL в облаке, отдельный сервер, кластер). Тогда в `docker-compose` удаляете сервис `postgres`, в переменных окружения бэкенда задаёте `SPRING_DATASOURCE_URL` (и логин/пароль) на внешнюю БД. Том `postgres_data` не нужен.

Итого: для развёртывания «с нуля» на Mac или на одном сервере — БД в контейнере нормальный и простой вариант. Для высоконагруженного или отказоустойчивого продакшена БД обычно выносят (managed DB или отдельный сервер).

---

## Структура (напоминание)

- **backend/Dockerfile** — многопроходная сборка: Maven → JAR, затем JRE + запуск.
- **frontend/Dockerfile** — многопроходная: Node (npm build) → nginx + статика из `dist`; **frontend/nginx.conf** — раздача SPA и `proxy_pass` для `/api` на контейнер `backend`.
- **docker-compose.yml** — сервисы `postgres`, `backend`, `frontend`; тома для данных БД и каталога загрузок; порт **8080** наружу только у frontend.

Переменные окружения (пароль БД, логин/пароль приложения) задаются в `docker-compose` и при необходимости переопределяются через файл `.env` (см. `env.docker.example`).
