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
                // Разрешаем запросы с локальных хостов (dev: 5173/3000, Docker/nginx: 8080) и с удалённого сервера.
                // Паттерны позволяют не перечислять каждый порт по отдельности.
                .allowedOriginPatterns(
                    "http://localhost:*",
                    "http://127.0.0.1:*",
                    "http://91.194.3.57:*"
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
