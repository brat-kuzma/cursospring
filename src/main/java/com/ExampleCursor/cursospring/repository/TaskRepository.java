package com.ExampleCursor.cursospring.repository;

import com.ExampleCursor.cursospring.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskRepository extends JpaRepository<Task, Long> {
}
