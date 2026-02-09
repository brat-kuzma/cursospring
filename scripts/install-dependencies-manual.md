# Установка зависимостей на Debian/Ubuntu

**Примечание:** Команды для выполнения под root (без sudo)

## Быстрая установка (автоматический скрипт)

```bash
chmod +x scripts/install-dependencies-debian.sh
./scripts/install-dependencies-debian.sh
```

---

## Ручная установка (пошагово)

### 1. Обновление списка пакетов
```bash
apt update
```

### 2. Backend зависимости

#### Java 21 JDK
```bash
apt install -y openjdk-21-jdk
```

**Примечание:** Если Java 21 недоступна в вашей версии Debian/Ubuntu:
- **Debian 12+ (bookworm)** и **Ubuntu 23.10+**: Java 21 доступна из репозиториев
- Для более старых версий используйте:
  ```bash
  # Добавление репозитория для Java 21 (если нужно)
  apt install -y software-properties-common
  add-apt-repository ppa:openjdk-r/ppa
  apt update
  apt install -y openjdk-21-jdk
  ```

#### Maven
```bash
apt install -y maven
```

### 3. PostgreSQL

Если PostgreSQL ещё не установлен:
```bash
apt install -y postgresql postgresql-contrib
```

После установки настройте пароль:
```bash
su - postgres -c "psql"
ALTER USER postgres PASSWORD 'ваш_пароль';
\q
```

### 4. Frontend зависимости

#### Node.js и npm

**Вариант А — через NodeSource (рекомендуется, актуальная версия):**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
```

**Вариант Б — из репозиториев Debian/Ubuntu (может быть устаревшая версия):**
```bash
apt install -y nodejs npm
```

### 5. Инструменты для сборки

Необходимы для компиляции нативных зависимостей npm (например, node-gyp):
```bash
apt install -y build-essential
```

### 6. Git (для клонирования репозитория)

```bash
apt install -y git
```

---

## Проверка установки

```bash
# Java
java -version
# Должно показать: openjdk version "21.x.x"

# Maven
mvn -version
# Должно показать: Apache Maven 3.x.x

# PostgreSQL
psql --version
# Должно показать: psql (PostgreSQL) 14.x или выше

# Node.js
node --version
# Должно показать: v20.x.x или выше

# npm
npm --version
# Должно показать: 10.x.x или выше

# Git
git --version
# Должно показать: git version 2.x.x
```

---

## Минимальный набор команд (все сразу)

Если хотите установить всё одной командой:

```bash
apt update && \
apt install -y \
    openjdk-21-jdk \
    maven \
    postgresql postgresql-contrib \
    build-essential \
    git && \
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
apt install -y nodejs
```

---

## Альтернативные варианты установки

### Java через SDKMAN (если apt не подходит)
```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.1-tem
sdk install maven
```

### Node.js через NVM (если нужна конкретная версия)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

---

## После установки

1. **Создайте базу данных** (см. `backend/sql/README.md`)
2. **Настройте переменные окружения** для подключения к БД
3. **Клонируйте репозиторий** и запустите приложение
