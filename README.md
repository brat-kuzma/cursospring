# Cursospring — хранилище задач

Веб-приложение для управления задачами: бэкенд на Spring Boot, фронтенд на React. Авторизация через Spring Security (логин/пароль, сессия).

---

## Технологии

### Backend
| Технология | Назначение |
|------------|------------|
| **Java 21** | Язык |
| **Spring Boot 4.x** | Каркас приложения |
| **Spring Web MVC** | REST API |
| **Spring Data JPA** | Работа с БД |
| **Spring Security** | Авторизация (сессия, in-memory пользователь) |
| **Spring Validation** | Валидация DTO (Bean Validation) |
| **PostgreSQL** | БД (драйвер `postgresql`) |
| **Lombok** | Уменьшение шаблонного кода |
| **Maven** | Сборка и зависимости |

### Frontend
| Технология | Назначение |
|------------|------------|
| **React 18** | UI |
| **TypeScript** | Типизация |
| **Vite 5** | Сборка и dev-сервер, прокси к API |
| **React Router 6** | Маршрутизация (логин / список задач) |

### Инфраструктура
- **CORS** — доступ к API с фронта (localhost:5173).
- **Сессия** — JSESSIONID в cookie после логина, сохранение контекста в Spring Security 6.

---

## Модуль создания задач

Реализован в бэкенде и на фронте.

### Backend
- **Таблица** `tasks`: id, title, description, due_date, completed, created_at, updated_at.
- **Entity** `Task` (JPA), **Repository** `TaskRepository` (JpaRepository).
- **Сервис** `TaskService`: создание, обновление (в т.ч. флаг `completed`), удаление, получение списка.
- **REST API** (все эндпоинты требуют авторизации):
  - `GET /api/tasks` — список задач
  - `POST /api/tasks` — создание (тело: title, description?, dueDate?, completed?)
  - `PUT /api/tasks/{id}` — обновление (title, description, dueDate, completed)
  - `DELETE /api/tasks/{id}` — удаление
- **DTO**: CreateTaskRequest, UpdateTaskRequest, TaskResponse; валидация через Bean Validation.
- **Обработка ошибок**: GlobalExceptionHandler (404, 400, 401).

### Frontend
- **Форма «Новая задача»**: заголовок, описание, дата дедлайна, чекбокс «Выполнена». Отправка — `POST /api/tasks`.
- **Список задач**: загрузка через `GET /api/tasks`, отображение с чекбоксом «выполнена» (переключение через `PUT /api/tasks/{id}`) и кнопкой удаления (`DELETE`).
- Запросы к API идут с `credentials: 'include'` (сессионная cookie).

---

## Запуск

### 1. Пароль БД (обязательно)

Без пароля к PostgreSQL приложение не запустится (ошибка *no password was provided*). Секреты в репозиторий не кладём — задайте их одним из способов.

**Способ А — переменные окружения:**
```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/postgres
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=ваш_пароль
```

**Способ Б — локальный файл (удобно для разработки):**
```bash
cd backend/src/main/resources
cp application-local.properties.example application-local.properties
# Откройте application-local.properties и укажите spring.datasource.password=ваш_пароль
```
Файл `application-local.properties` в `.gitignore` — в Git он не попадёт.

### 2. Backend
```bash
# из корня проекта
mvn spring-boot:run
```
Приложение: http://localhost:8080  
Логин по умолчанию (in-memory): **user** / **password**

### 3. Frontend
```bash
cd frontend
npm install
npm run dev
```
Приложение: http://localhost:5173 (прокси `/api` → http://localhost:8080).

---

## Структура проекта

```
cursospring/
├── backend/src/main/java/.../     # Spring Boot (entity, dto, controller, service, config)
├── backend/src/main/resources/
│   ├── application.properties     # без секретов, значения из env
│   └── application-local.properties  # локальные секреты (в .gitignore)
├── frontend/                      # React + Vite
├── pom.xml                        # Maven, sourceDirectory → backend
└── README.md
```

---

## Безопасность

- Пароли БД и прочие секреты задаются только через переменные окружения или `application-local.properties`.
- Файлы `.env`, `application-local.properties` и аналоги добавлены в `.gitignore` и не коммитятся в GitHub.
