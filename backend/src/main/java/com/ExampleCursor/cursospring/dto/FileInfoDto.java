package com.ExampleCursor.cursospring.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Информация о файле в списке: имя (как хранится на диске) и размер в байтах.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FileInfoDto {

    private String name;
    private long sizeInBytes;
}
