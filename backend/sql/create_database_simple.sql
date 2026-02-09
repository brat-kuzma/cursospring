-- ============================================
-- Упрощённый SQL скрипт для DBeaver
-- Создаёт БД и таблицу tasks
-- ============================================

-- 1. Сначала создайте БД вручную через DBeaver (правой кнопкой на PostgreSQL → Create Database)
--    Имя: cursospring
--    Owner: postgres (или ваш пользователь)
--    Encoding: UTF8
--
-- 2. Затем подключитесь к БД cursospring и выполните этот скрипт

-- Создание таблицы tasks
CREATE TABLE IF NOT EXISTS tasks (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- Индексы для оптимизации запросов
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);
