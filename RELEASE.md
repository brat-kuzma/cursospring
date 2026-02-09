# Release v1.0.0

## Дата релиза
2026-02-09

## Описание
Релизная версия приложения cursospring с полным функционалом управления задачами и файловым менеджером.

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

См. документацию:
- `scripts/DEPLOY.md` - подробная инструкция
- `scripts/STEP-BY-STEP.md` - пошаговая инструкция
- `scripts/REMOTE-SERVER.md` - настройка для удалённого сервера

## Скрипты

- `scripts/deploy-backend.sh` - сборка и подготовка бэкенда
- `scripts/start-backend.sh` - запуск бэкенда в фоне
- `scripts/stop-backend.sh` - остановка бэкенда
- `scripts/start-frontend-background.sh` - запуск фронтенда в фоне
- `scripts/stop-frontend.sh` - остановка фронтенда
- `scripts/check-database.sh` - проверка подключения к БД
- `scripts/fix-database.sh` - исправление проблем с БД

## Версия
v1.0.0

## Авторы
cursospring team
