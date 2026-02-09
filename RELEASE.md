# Release v1.1.0

## Дата релиза
2026-02-09

## Описание
Релиз с деплоем через Nginx: один скрипт для Ubuntu 22 (PostgreSQL + бэкенд + фронт), обновлённая документация, исправление 413 при загрузке файлов.

## Функционал

### Backend
- ✅ REST API для управления задачами (CRUD)
- ✅ REST API для файлового менеджера (загрузка, список, скачивание, удаление)
- ✅ Spring Security с сессионной аутентификацией и HTTP Basic Auth
- ✅ PostgreSQL база данных
- ✅ Поддержка файлов до 1 ГБ
- ✅ Хранение файлов на диске (персистентность после перезапуска)

### Frontend
- ✅ React + TypeScript + Vite
- ✅ Страница управления задачами
- ✅ Страница файлового менеджера
- ✅ Авторизация через сессию
- ✅ Навигация между страницами

## Технологии

- **Backend**: Java 21, Spring Boot 4.0.2, PostgreSQL
- **Frontend**: React 18, TypeScript, Vite 5
- **Build**: Maven, npm

## Развертывание

- **Продакшен:** Nginx раздаёт фронт и проксирует `/api` на бэкенд; лимит загрузки файлов `client_max_body_size 1024M`.
- `scripts/DEPLOY.md` — общая инструкция (в т.ч. конфиг Nginx)
- `scripts/DEPLOY-UBUNTU22.md` — один скрипт для Ubuntu 22 (PostgreSQL, Java, Maven, Node, Nginx, systemd)
- `scripts/STEP-BY-STEP.md` — пошаговая инструкция
- `scripts/REMOTE-SERVER.md` — настройка для удалённого сервера

## Скрипты

- `scripts/deploy-ubuntu22-minimal.sh` — полный деплой на Ubuntu 22 (включая Nginx и лимит 1 ГБ)
- `scripts/fix-nginx-413.sh` — исправление 413 при загрузке файлов в Nginx
- `scripts/deploy-backend.sh`, `start-backend.sh`, `stop-backend.sh` — бэкенд
- `scripts/start-frontend-background.sh`, `stop-frontend.sh` — фронт в фоне (dev)
- `scripts/check-database.sh`, `fix-database.sh` — БД

## Версия
v1.1.0

## Авторы
cursospring team
