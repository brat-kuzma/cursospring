package com.ExampleCursor.cursospring.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.nio.file.Path;

/**
 * Путь к каталогу, где хранятся загруженные файлы (настраивается в application.properties).
 * Файлы сохраняются на диск и остаются после перезапуска приложения.
 */
@Component
@ConfigurationProperties(prefix = "app.file")
@Getter
@Setter
public class FileStorageProperties {

    /**
     * Директория для загрузок, например ./data/uploads или ${user.home}/cursospring-uploads.
     */
    private String uploadDir = "./data/uploads";

    public Path getUploadPath() {
        return Path.of(uploadDir).toAbsolutePath().normalize();
    }
}
