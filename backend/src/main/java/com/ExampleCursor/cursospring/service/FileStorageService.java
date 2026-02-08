package com.ExampleCursor.cursospring.service;

import com.ExampleCursor.cursospring.config.FileStorageProperties;
import com.ExampleCursor.cursospring.dto.FileInfoDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.stream.Stream;

/**
 * Сохранение и чтение файлов на диск в каталог app.file.upload-dir.
 * Файлы переживают перезапуск приложения. Имена санитизируются (без пути и опасных символов).
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class FileStorageService {

    private final FileStorageProperties storageProperties;

    /**
     * Возвращает корневой каталог загрузок и создаёт его при первом обращении.
     */
    private Path getUploadRoot() throws IOException {
        Path root = storageProperties.getUploadPath();
        Files.createDirectories(root);
        return root;
    }

    /**
     * Очищает имя файла: только базовое имя, без ".." и разделителей пути.
     */
    private String sanitizeFileName(String originalName) {
        if (!StringUtils.hasText(originalName)) {
            return "unnamed";
        }
        String name = Path.of(originalName).getFileName().toString();
        name = name.replaceAll("[\\\\/]", "");
        if (name.isBlank()) {
            return "unnamed";
        }
        return name;
    }

    /**
     * Уникальное имя в каталоге: если файл с таким именем есть — добавляем _1, _2 и т.д.
     */
    private Path uniquePath(Path root, String baseName) throws IOException {
        Path target = root.resolve(baseName);
        if (!Files.exists(target)) {
            return target;
        }
        int dot = baseName.lastIndexOf('.');
        String prefix = dot > 0 ? baseName.substring(0, dot) : baseName;
        String suffix = dot > 0 ? baseName.substring(dot) : "";
        for (int i = 1; ; i++) {
            String candidate = prefix + "_" + i + suffix;
            target = root.resolve(candidate);
            if (!Files.exists(target)) {
                return target;
            }
        }
    }

    /**
     * Проверяет, что path находится внутри root (защита от path traversal).
     */
    private void ensureInsideRoot(Path root, Path path) {
        Path normalized = path.normalize().toAbsolutePath();
        Path rootAbs = root.toAbsolutePath().normalize();
        if (!normalized.startsWith(rootAbs)) {
            throw new IllegalArgumentException("Invalid file name");
        }
    }

    /**
     * Сохраняет загруженный файл на диск. Возвращает имя и размер сохранённого файла.
     */
    public FileInfoDto store(MultipartFile file) throws IOException {
        if (file == null || file.getOriginalFilename() == null || file.getOriginalFilename().isBlank()) {
            throw new IllegalArgumentException("File name is required");
        }
        Path root = getUploadRoot();
        String baseName = sanitizeFileName(file.getOriginalFilename());
        Path target = uniquePath(root, baseName);

        try (InputStream in = file.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
        long size = Files.size(target);
        log.info("Stored file: {} ({} bytes)", target.getFileName(), size);
        return FileInfoDto.builder()
                .name(target.getFileName().toString())
                .sizeInBytes(size)
                .build();
    }

    /**
     * Список всех файлов в каталоге загрузок (имя + размер).
     */
    public List<FileInfoDto> listAll() throws IOException {
        Path root = getUploadRoot();
        try (Stream<Path> stream = Files.list(root)) {
            return stream
                    .filter(Files::isRegularFile)
                    .map(p -> FileInfoDto.builder()
                            .name(p.getFileName().toString())
                            .sizeInBytes(p.toFile().length())
                            .build())
                    .toList();
        }
    }

    /**
     * Возвращает ресурс для скачивания по имени файла. Имя должно быть санитизированным (без пути).
     */
    public Resource loadAsResource(String fileName) throws IOException {
        Path root = getUploadRoot();
        Path file = root.resolve(fileName).normalize();
        ensureInsideRoot(root, file);
        if (!Files.exists(file) || !Files.isRegularFile(file)) {
            throw new ResourceNotFoundException("File not found: " + fileName);
        }
        Resource resource = new UrlResource(file.toUri());
        if (!resource.exists() || !resource.isReadable()) {
            throw new ResourceNotFoundException("Cannot read file: " + fileName);
        }
        return resource;
    }

    /**
     * Удаляет файл по имени. Имя должно быть санитизированным.
     */
    public void delete(String fileName) throws IOException {
        Path root = getUploadRoot();
        Path file = root.resolve(fileName).normalize();
        ensureInsideRoot(root, file);
        if (!Files.exists(file) || !Files.isRegularFile(file)) {
            throw new ResourceNotFoundException("File not found: " + fileName);
        }
        Files.delete(file);
        log.info("Deleted file: {}", fileName);
    }
}
