# SQL скрипты для создания базы данных

## Вариант 1: Через DBeaver (рекомендуется)

### Шаг 1: Создание базы данных
1. Подключитесь к PostgreSQL серверу в DBeaver
2. Правой кнопкой на сервере → **Create Database**
3. Укажите:
   - **Database name**: `cursospring`
   - **Owner**: `postgres` (или ваш пользователь)
   - **Encoding**: `UTF8`
   - **Template**: `template0` (или оставьте по умолчанию)
4. Нажмите **OK**

### Шаг 2: Создание таблицы
1. Подключитесь к созданной БД `cursospring`
2. Откройте файл `create_database_simple.sql`
3. Выполните скрипт (Ctrl+Enter или кнопка Execute)

Готово! Таблица `tasks` создана.

---

## Вариант 2: Через psql (командная строка)

Если у вас есть доступ к серверу по SSH:

```bash
# Подключитесь к PostgreSQL
sudo -u postgres psql

# Выполните скрипт
\i /путь/к/create_database.sql

# Или создайте БД вручную и выполните только часть с таблицей
CREATE DATABASE cursospring;
\c cursospring
\i /путь/к/create_database_simple.sql
```

---

## Проверка

После создания выполните в DBeaver:

```sql
-- Проверка структуры таблицы
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'tasks'
ORDER BY ordinal_position;

-- Проверка индексов
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'tasks';
```

---

## Настройка приложения

После создания БД обновите `application.properties` или переменные окружения:

```properties
spring.datasource.url=jdbc:postgresql://ваш_сервер:5432/cursospring
spring.datasource.username=postgres
spring.datasource.password=ваш_пароль
```

Или через переменные окружения:
```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://ваш_сервер:5432/cursospring
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=ваш_пароль
```

---

## Примечания

- При использовании `spring.jpa.hibernate.ddl-auto=update` Spring Boot автоматически проверит структуру таблицы и при необходимости обновит её при первом запуске
- Если таблица уже существует, скрипт не выдаст ошибку (используется `IF NOT EXISTS`)
- Индексы создаются для оптимизации запросов по `completed` и `created_at`
