-- ============================================
-- SQL скрипт для создания БД cursospring на PostgreSQL
-- Запускать от имени суперпользователя (postgres) или пользователя с правами CREATE DATABASE
-- ============================================

-- Создание базы данных (если не существует)
-- Если БД уже существует, команда выдаст предупреждение, но не ошибку
CREATE DATABASE cursospring
    WITH OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0;

-- Подключение к созданной БД
\c cursospring

-- ============================================
-- Таблица tasks (задачи)
-- ============================================
CREATE TABLE IF NOT EXISTS tasks (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- Комментарии к таблице и колонкам (для документации)
COMMENT ON TABLE tasks IS 'Таблица задач: заголовок, описание, дедлайн, статус выполнения, даты создания и обновления';
COMMENT ON COLUMN tasks.id IS 'Уникальный идентификатор задачи (автоинкремент)';
COMMENT ON COLUMN tasks.title IS 'Заголовок задачи (обязательное поле, до 255 символов)';
COMMENT ON COLUMN tasks.description IS 'Подробное описание задачи (необязательное, текст произвольной длины)';
COMMENT ON COLUMN tasks.due_date IS 'Дата дедлайна (необязательное)';
COMMENT ON COLUMN tasks.completed IS 'Флаг выполнения задачи (по умолчанию false)';
COMMENT ON COLUMN tasks.created_at IS 'Дата и время создания записи (заполняется автоматически при создании)';
COMMENT ON COLUMN tasks.updated_at IS 'Дата и время последнего обновления записи (обновляется автоматически при изменении)';

-- Индекс для быстрого поиска по статусу выполнения (опционально, для больших таблиц)
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);

-- Индекс для сортировки по дате создания (опционально)
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);

-- ============================================
-- Готово!
-- ============================================
-- После выполнения скрипта:
-- 1. Убедитесь, что пользователь приложения имеет права на чтение/запись в таблицу tasks
-- 2. В application.properties укажите:
--    spring.datasource.url=jdbc:postgresql://ваш_сервер:5432/cursospring
--    spring.datasource.username=ваш_пользователь
--    spring.datasource.password=ваш_пароль
-- 3. При первом запуске Spring Boot с spring.jpa.hibernate.ddl-auto=update
--    таблица будет проверена и при необходимости обновлена автоматически
