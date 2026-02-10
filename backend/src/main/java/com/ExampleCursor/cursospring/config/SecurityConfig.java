package com.ExampleCursor.cursospring.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;

/**
 * Конфигурация Spring Security: кто может заходить на какие URL и как мы проверяем логин/пароль.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${app.security.user.name:user}")
    private String securityUserName;

    @Value("${app.security.user.password:password}")
    private String securityUserPassword;

    /**
     * Главный бин: цепочка фильтров безопасности для каждого HTTP-запроса.
     * Здесь задаётся: отключить CSRF, включить Basic Auth, правила доступа по URL и т.д.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Отключаем проверку CSRF-токена. Для REST API без браузерных форм часто отключают,
                // иначе POST/PUT/DELETE без специального токена будут получать 403.
                .csrf(AbstractHttpConfigurer::disable)
                // CORS настраиваем отдельно в WebConfig; здесь просто "использовать дефолт".
                .cors(cors -> {})
                // Включаем HTTP Basic Auth: запросы с заголовком "Authorization: Basic base64(user:password)"
                // автоматически считаются авторизованными. Нужно для .http файлов и простых REST-клиентов.
                .httpBasic(basic -> {})
                // SecurityContext (кто залогинен) не сохраняется автоматически — только через наш
                // SecurityContextRepository (в сессию). Нужно для кастомного логина в AuthController.
                .securityContext(sec -> sec.requireExplicitSave(true))
                // Сессия создаётся только когда реально нужна (например после логина через /api/auth/login).
                // IF_REQUIRED = не создавать сессию просто так, только если мы сами её сохранили.
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
                // Правила доступа: какие URL кому доступны.
                .authorizeHttpRequests(auth -> auth
                        // Логин и /me можно вызывать без авторизации (чтобы вообще войти и проверить сессию).
                        .requestMatchers("/api/auth/login", "/api/auth/me").permitAll()
                        // Всё под /api/* (в т.ч. /api/tasks) — только для авторизованных.
                        .requestMatchers("/api/**").authenticated()
                        // Всё остальное (например статика, Swagger) — разрешено без входа.
                        .anyRequest().permitAll());
        return http.build();
    }

    /**
     * Репозиторий контекста безопасности: где хранить "кто залогинен" между запросами.
     * HttpSessionSecurityContextRepository = в HTTP-сессии (кука JSESSIONID). После логина
     * контекст сохраняется сюда, и следующие запросы с той же кукой считаются авторизованными.
     */
    @Bean
    public SecurityContextRepository securityContextRepository() {
        return new HttpSessionSecurityContextRepository();
    }

    /**
     * AuthenticationManager — тот, кто по логину/паролю проверяет пользователя (сравнивает с UserDetailsService).
     * Нужен в AuthController для ручного вызова authenticate() при POST /api/auth/login.
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * Кодировщик паролей. Пароли в БД/памяти хранятся только в виде хеша (BCrypt), никогда в открытом виде.
     * encoder.encode("password") даёт хеш; encoder.matches(rawPassword, encodedPassword) проверяет пароль.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Источник пользователей: кто вообще может войти. Сейчас — один пользователь в памяти;
     * логин и пароль берутся из app.security.user.name и app.security.user.password
     * (или переменных окружения APP_SECURITY_USER_NAME, APP_SECURITY_USER_PASSWORD).
     * Пароль хранится в виде BCrypt-хеша. В проде обычно подменяют на репозиторий из БД.
     */
    @Bean
    public UserDetailsService userDetailsService(PasswordEncoder encoder) {
        var user = User.builder()
                .username(securityUserName)
                .password(encoder.encode(securityUserPassword))
                .roles("USER")
                .build();
        return new InMemoryUserDetailsManager(user);
    }
}
