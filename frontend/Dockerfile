# ================================
# Stage 1: build frontend
# ================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

# ================================
# Stage 2: nginx + статика
# ================================
FROM nginx:alpine

# Конфиг с проксированием /api к бэкенду (имя сервиса подставится в docker-compose)
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
