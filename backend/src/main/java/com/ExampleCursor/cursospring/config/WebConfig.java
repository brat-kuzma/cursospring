package com.ExampleCursor.cursospring.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Общая веб-конфигурация (CORS и при необходимости другие настройки MVC).
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * CORS (Cross-Origin Resource Sharing): с каких доменов браузер может вызывать наш API.
     * Фронт на localhost:5173 (Vite) или :3000 (React dev) — другой "origin", без CORS браузер блокирует запросы.
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                // Разрешаем запросы с этих адресов (локальная разработка и удалённый сервер).
                // Для удалённого сервера добавьте IP адрес или домен в этот список.
                // Пример: "http://192.168.1.100:5173" или "http://your-domain.com:5173"
                // Разрешаем запросы с этих адресов. Для удалённого сервера добавьте IP адрес в список ниже.
                // Пример: "http://192.168.1.100:5173" или "http://your-domain.com:5173"
                .allowedOrigins(
                    "http://localhost:5173", 
                    "http://localhost:3000", 
                    "http://127.0.0.1:5173", 
                    "http://127.0.0.1:3000"
                )
                // Какие HTTP-методы разрешены с другого origin.
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                // Разрешаем любые заголовки (в т.ч. Authorization, Content-Type).
                .allowedHeaders("*")
                // allowCredentials(true) — можно отправлять куки (JSESSIONID) с cross-origin запросами.
                // Нужно, если логинимся через /api/auth/login и потом ходим с той же сессией с фронта.
                .allowCredentials(true);
    }
}
