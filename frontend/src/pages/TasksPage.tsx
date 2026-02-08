import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { tasksApi } from '../api/tasks'
import type { Task, CreateTaskRequest } from '../types/task'

export function TasksPage() {
  const { user, logout } = useAuth()
  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [form, setForm] = useState<CreateTaskRequest>({ title: '', description: '', completed: false })
  const [submitting, setSubmitting] = useState(false)

  const loadTasks = async () => {
    setError(null)
    try {
      const data = await tasksApi.getAll()
      setTasks(data)
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось загрузить задачи')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadTasks()
  }, [])

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault()
    const title = form.title?.trim()
    if (!title) return
    setSubmitting(true)
    setError(null)
    try {
      await tasksApi.create({
        title,
        description: form.description?.trim() || undefined,
        dueDate: form.dueDate || undefined,
        completed: form.completed ?? false,
      })
      setForm({ title: '', description: '', completed: false })
      await loadTasks()
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось создать задачу')
    } finally {
      setSubmitting(false)
    }
  }

  const handleDelete = async (id: number) => {
    if (!window.confirm('Удалить задачу?')) return
    setError(null)
    try {
      await tasksApi.delete(id)
      await loadTasks()
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось удалить')
    }
  }

  const handleToggleCompleted = async (task: Task) => {
    setError(null)
    try {
      await tasksApi.update(task.id, {
        title: task.title,
        description: task.description ?? undefined,
        dueDate: task.dueDate ?? undefined,
        completed: !task.completed,
      })
      await loadTasks()
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось обновить задачу')
    }
  }

  const formatDate = (s: string | null) => {
    if (!s) return '—'
    try {
      const d = new Date(s)
      return d.toLocaleDateString('ru-RU', { day: '2-digit', month: '2-digit', year: 'numeric' })
    } catch {
      return s
    }
  }

  return (
    <div className="tasks-wrap">
      <header className="tasks-header">
        <div className="tasks-header-inner">
          <nav className="tasks-nav">
            <Link to="/" className="tasks-nav-link tasks-nav-link-active">Задачи</Link>
            <span className="tasks-nav-sep">|</span>
            <Link to="/files" className="tasks-nav-link">Файлы</Link>
          </nav>
          <div className="tasks-user">
            <span className="tasks-username">{user}</span>
            <button type="button" onClick={() => logout()} className="tasks-logout">
              Выйти
            </button>
          </div>
        </div>
      </header>

      <main className="tasks-main">
        <section className="tasks-section tasks-form-section">
          <h2 className="section-title">Новая задача</h2>
          <form onSubmit={handleAdd} className="task-form">
            <input
              value={form.title}
              onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))}
              placeholder="Заголовок"
              className="task-input"
              required
            />
            <textarea
              value={form.description}
              onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
              placeholder="Описание (необязательно)"
              className="task-textarea"
              rows={2}
            />
            <input
              type="date"
              value={form.dueDate ?? ''}
              onChange={(e) => setForm((f) => ({ ...f, dueDate: e.target.value || undefined }))}
              className="task-input task-input-date"
            />
            <label className="task-form-completed">
              <input
                type="checkbox"
                checked={form.completed ?? false}
                onChange={(e) => setForm((f) => ({ ...f, completed: e.target.checked }))}
              />
              <span>Выполнена</span>
            </label>
            <button type="submit" disabled={submitting} className="task-submit">
              {submitting ? 'Добавляю…' : 'Добавить'}
            </button>
          </form>
        </section>

        {error && (
          <div className="tasks-error">
            {error}
          </div>
        )}

        <section className="tasks-section">
          <h2 className="section-title">Список задач</h2>
          {loading ? (
            <div className="tasks-loading">Загрузка…</div>
          ) : tasks.length === 0 ? (
            <div className="tasks-empty">Нет задач. Добавьте первую.</div>
          ) : (
            <ul className="task-list">
              {tasks.map((task) => (
                <li key={task.id} className={`task-item ${task.completed ? 'task-item-completed' : ''}`}>
                  <label className="task-item-checkbox">
                    <input
                      type="checkbox"
                      checked={!!task.completed}
                      onChange={() => handleToggleCompleted(task)}
                      className="task-checkbox-input"
                    />
                    <span className="task-checkbox-box" />
                  </label>
                  <div className="task-item-content">
                    <span className="task-item-title">{task.title}</span>
                    {task.description && (
                      <p className="task-item-desc">{task.description}</p>
                    )}
                    <div className="task-item-meta">
                      {task.dueDate && (
                        <span className="task-item-due">До: {formatDate(task.dueDate)}</span>
                      )}
                      {task.completed && <span className="task-item-done">Выполнена</span>}
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => handleDelete(task.id)}
                    className="task-item-delete"
                    title="Удалить"
                  >
                    ✕
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>

      <style>{`
        .tasks-wrap {
          min-height: 100vh;
          background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
        }
        .tasks-header {
          border-bottom: 1px solid rgba(71, 85, 105, 0.5);
          background: rgba(15, 23, 42, 0.9);
        }
        .tasks-header-inner {
          max-width: 900px;
          margin: 0 auto;
          padding: 1rem 1.5rem;
          display: flex;
          align-items: center;
          justify-content: space-between;
        }
        .tasks-nav {
          display: flex;
          align-items: center;
          gap: 0.5rem;
        }
        .tasks-nav-link {
          color: #94a3b8;
          text-decoration: none;
          font-size: 1rem;
          transition: color 0.2s;
        }
        .tasks-nav-link:hover {
          color: #e2e8f0;
        }
        .tasks-nav-link-active {
          color: #f1f5f9;
          font-weight: 600;
        }
        .tasks-nav-sep {
          color: #475569;
          font-size: 0.9rem;
        }
        .tasks-user {
          display: flex;
          align-items: center;
          gap: 1rem;
        }
        .tasks-username {
          color: #94a3b8;
          font-size: 0.9rem;
        }
        .tasks-logout {
          padding: 0.4rem 0.75rem;
          background: transparent;
          border: 1px solid #475569;
          border-radius: 8px;
          color: #94a3b8;
          font-size: 0.875rem;
          transition: border-color 0.2s, color 0.2s;
        }
        .tasks-logout:hover {
          border-color: #64748b;
          color: #e2e8f0;
        }
        .tasks-main {
          max-width: 900px;
          margin: 0 auto;
          padding: 2rem 1.5rem;
        }
        .tasks-section {
          margin-bottom: 2rem;
        }
        .tasks-form-section {
          margin-bottom: 2rem;
        }
        .section-title {
          margin: 0 0 1rem;
          font-size: 1.1rem;
          font-weight: 600;
          color: #cbd5e1;
        }
        .task-form {
          display: flex;
          flex-direction: column;
          gap: 0.75rem;
          padding: 1.5rem;
          background: rgba(30, 41, 59, 0.6);
          border: 1px solid rgba(71, 85, 105, 0.4);
          border-radius: 12px;
        }
        .task-input, .task-textarea {
          padding: 0.65rem 1rem;
          background: #1e293b;
          border: 1px solid #334155;
          border-radius: 8px;
          color: #e2e8f0;
          outline: none;
          transition: border-color 0.2s;
        }
        .task-input::placeholder, .task-textarea::placeholder {
          color: #64748b;
        }
        .task-input:focus, .task-textarea:focus {
          border-color: #6366f1;
        }
        .task-textarea {
          resize: vertical;
          min-height: 60px;
        }
        .task-input-date {
          max-width: 200px;
        }
        .task-form-completed {
          display: flex;
          align-items: center;
          gap: 0.5rem;
          cursor: pointer;
          font-size: 0.9rem;
          color: #cbd5e1;
        }
        .task-form-completed input {
          width: 18px;
          height: 18px;
        }
        .task-submit {
          align-self: flex-start;
          padding: 0.6rem 1.25rem;
          background: linear-gradient(135deg, #6366f1, #4f46e5);
          border: none;
          border-radius: 8px;
          color: #fff;
          font-weight: 600;
          font-size: 0.9rem;
          transition: opacity 0.2s;
        }
        .task-submit:hover:not(:disabled) {
          opacity: 0.9;
        }
        .task-submit:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }
        .tasks-error {
          padding: 0.75rem 1rem;
          margin-bottom: 1rem;
          background: rgba(239, 68, 68, 0.15);
          border: 1px solid rgba(239, 68, 68, 0.4);
          border-radius: 8px;
          color: #fca5a5;
          font-size: 0.9rem;
        }
        .tasks-loading, .tasks-empty {
          padding: 2rem;
          text-align: center;
          color: #94a3b8;
        }
        .task-list {
          list-style: none;
          margin: 0;
          padding: 0;
          display: flex;
          flex-direction: column;
          gap: 0.75rem;
        }
        .task-item {
          display: flex;
          align-items: flex-start;
          gap: 1rem;
          padding: 1rem 1.25rem;
          background: rgba(30, 41, 59, 0.6);
          border: 1px solid rgba(71, 85, 105, 0.4);
          border-radius: 10px;
          transition: border-color 0.2s, background 0.2s;
        }
        .task-item:hover {
          border-color: rgba(99, 102, 241, 0.4);
          background: rgba(30, 41, 59, 0.8);
        }
        .task-item-completed .task-item-title {
          text-decoration: line-through;
          color: #94a3b8;
        }
        .task-item-checkbox {
          flex-shrink: 0;
          display: flex;
          align-items: center;
          cursor: pointer;
        }
        .task-checkbox-input {
          position: absolute;
          opacity: 0;
          width: 0;
          height: 0;
        }
        .task-checkbox-box {
          width: 22px;
          height: 22px;
          border: 2px solid #475569;
          border-radius: 6px;
          background: #1e293b;
          transition: border-color 0.2s, background 0.2s;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 12px;
          color: transparent;
        }
        .task-checkbox-input:checked + .task-checkbox-box {
          background: #6366f1;
          border-color: #6366f1;
          color: #fff;
        }
        .task-checkbox-input:checked + .task-checkbox-box::after {
          content: '✓';
        }
        .task-item-content {
          flex: 1;
          min-width: 0;
        }
        .task-item-title {
          font-weight: 600;
          color: #f1f5f9;
        }
        .task-item-desc {
          margin: 0.35rem 0 0;
          font-size: 0.9rem;
          color: #94a3b8;
          line-height: 1.4;
        }
        .task-item-meta {
          margin-top: 0.5rem;
          font-size: 0.8rem;
          color: #64748b;
          display: flex;
          gap: 1rem;
        }
        .task-item-done {
          color: #34d399;
        }
        .task-item-delete {
          flex-shrink: 0;
          width: 32px;
          height: 32px;
          display: flex;
          align-items: center;
          justify-content: center;
          background: transparent;
          border: 1px solid #475569;
          border-radius: 8px;
          color: #94a3b8;
          font-size: 1rem;
          line-height: 1;
          transition: border-color 0.2s, color 0.2s, background 0.2s;
        }
        .task-item-delete:hover {
          border-color: #f87171;
          color: #f87171;
          background: rgba(248, 113, 113, 0.1);
        }
      `}</style>
    </div>
  )
}
