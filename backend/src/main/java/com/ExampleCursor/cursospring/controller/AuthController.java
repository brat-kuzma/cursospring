package com.ExampleCursor.cursospring.controller;

import com.ExampleCursor.cursospring.dto.AuthResponse;
import com.ExampleCursor.cursospring.dto.LoginRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.web.bind.annotation.*;

/**
 * Эндпоинты для входа/выхода и проверки "кто сейчас залогинен".
 * Логин сохраняет авторизацию в сессию (кука JSESSIONID), дальше запросы с этой кукой считаются авторизованными.
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    /** Проверяет логин/пароль по UserDetailsService и при успехе возвращает объект Authentication. */
    private final AuthenticationManager authenticationManager;
    /** Сохраняет/достаёт SecurityContext из HTTP-сессии (нужно из-за requireExplicitSave(true) в SecurityConfig). */
    private final SecurityContextRepository securityContextRepository;

    /**
     * Вход по логину и паролю из JSON.
     * 1) Создаём "токен" с креденшалами и отдаём AuthenticationManager — он сравнивает с user/password из памяти.
     * 2) Если ок — создаём SecurityContext, кладём в него Authentication и сохраняем в сессию через repository.
     * 3) Сервер отдаёт в ответе Set-Cookie: JSESSIONID=... — браузер/REST-клиент при следующих запросах шлёт эту куку,
     *    и Spring Security уже считает пользователя залогиненным.
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse) {
        Authentication token = new UsernamePasswordAuthenticationToken(
                request.getUsername(), request.getPassword());
        Authentication auth = authenticationManager.authenticate(token);
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(auth);
        SecurityContextHolder.setContext(context);
        securityContextRepository.saveContext(context, httpRequest, httpResponse);

        return ResponseEntity.ok(AuthResponse.builder()
                .username(auth.getName())
                .authenticated(true)
                .build());
    }

    /**
     * Выход: очищаем SecurityContext и сохраняем пустой контекст в сессию, затем инвалидируем саму сессию.
     * После этого JSESSIONID больше не привязан к пользователю.
     */
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(HttpServletRequest request, HttpServletResponse response) {
        SecurityContextHolder.clearContext();
        securityContextRepository.saveContext(SecurityContextHolder.createEmptyContext(), request, response);
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return ResponseEntity.noContent().build();
    }

    /**
     * "Кто я?" — не требует авторизации (permitAll). Если в запросе есть валидная сессия или Basic Auth,
     * Spring подставит Authentication, и мы вернём username и authenticated: true; иначе authenticated: false.
     */
    @GetMapping("/me")
    public ResponseEntity<AuthResponse> me(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.ok(AuthResponse.builder().authenticated(false).build());
        }
        return ResponseEntity.ok(AuthResponse.builder()
                .username(authentication.getName())
                .authenticated(true)
                .build());
    }
}
