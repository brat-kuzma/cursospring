package com.ExampleCursor.cursospring.controller;

import com.ExampleCursor.cursospring.dto.FileInfoDto;
import com.ExampleCursor.cursospring.service.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * API файлового менеджера: загрузка, список, скачивание и удаление файлов.
 * Файлы хранятся на диске (каталог app.file.upload-dir) и доступны после перезапуска.
 */
@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    private final FileStorageService fileStorageService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<FileInfoDto> upload(@RequestParam("file") MultipartFile file) throws IOException {
        FileInfoDto info = fileStorageService.store(file);
        return ResponseEntity.ok(info);
    }

    @GetMapping
    public ResponseEntity<List<FileInfoDto>> listAll() throws IOException {
        return ResponseEntity.ok(fileStorageService.listAll());
    }

    @GetMapping("/{fileName}")
    public ResponseEntity<Resource> download(@PathVariable String fileName) throws IOException {
        Resource resource = fileStorageService.loadAsResource(fileName);
        String encodedName = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedName)
                .body(resource);
    }

    @DeleteMapping("/{fileName}")
    public ResponseEntity<Void> delete(@PathVariable String fileName) throws IOException {
        fileStorageService.delete(fileName);
        return ResponseEntity.noContent().build();
    }
}
