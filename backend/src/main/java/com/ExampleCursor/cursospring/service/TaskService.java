package com.ExampleCursor.cursospring.service;

import com.ExampleCursor.cursospring.dto.CreateTaskRequest;
import com.ExampleCursor.cursospring.dto.TaskResponse;
import com.ExampleCursor.cursospring.dto.UpdateTaskRequest;
import com.ExampleCursor.cursospring.entity.Task;
import com.ExampleCursor.cursospring.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class TaskService {

    private final TaskRepository taskRepository;

    @Transactional(readOnly = true)
    public java.util.List<TaskResponse> findAll() {
        return taskRepository.findAll().stream()
                .map(TaskResponse::fromEntity)
                .toList();
    }

    @Transactional
    public TaskResponse create(CreateTaskRequest request) {
        Task task = Task.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .dueDate(request.getDueDate())
                .completed(request.getCompleted() != null ? request.getCompleted() : false)
                .build();
        task = taskRepository.save(task);
        log.info("Created task: id={}, title={}", task.getId(), task.getTitle());
        return TaskResponse.fromEntity(task);
    }

    @Transactional
    public TaskResponse update(Long id, UpdateTaskRequest request) {
        Task task = taskRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found with id: " + id));
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setDueDate(request.getDueDate());
        if (request.getCompleted() != null) {
            task.setCompleted(request.getCompleted());
        }
        task = taskRepository.save(task);
        log.info("Updated task: id={}", id);
        return TaskResponse.fromEntity(task);
    }

    @Transactional
    public void deleteById(Long id) {
        if (!taskRepository.existsById(id)) {
            throw new ResourceNotFoundException("Task not found with id: " + id);
        }
        taskRepository.deleteById(id);
        log.info("Deleted task: id={}", id);
    }
}
