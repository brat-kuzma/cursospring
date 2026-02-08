import type { Task, CreateTaskRequest, UpdateTaskRequest } from '../types/task'

const BASE = '/api/tasks'
const credentials: RequestCredentials = 'include'

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    ...options,
    credentials,
    headers: { 'Content-Type': 'application/json', ...options?.headers },
  })
  if (!res.ok) {
    const text = await res.text()
    let msg = `HTTP ${res.status}`
    try {
      const json = JSON.parse(text)
      if (json.status === 403) msg = 'Доступ запрещён. Перезайдите в систему.'
      else if (json.error) msg = String(json.error)
      else if (json.message) msg = String(json.message)
    } catch {
      if (text) msg = text
    }
    throw new Error(msg)
  }
  if (res.status === 204) return undefined as T
  return res.json()
}

export const tasksApi = {
  getAll: () => request<Task[]>(BASE),
  create: (data: CreateTaskRequest) =>
    request<Task>(BASE, { method: 'POST', body: JSON.stringify(data) }),
  update: (id: number, data: UpdateTaskRequest) =>
    request<Task>(`${BASE}/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  delete: (id: number) =>
    request<void>(`${BASE}/${id}`, { method: 'DELETE' }),
}
