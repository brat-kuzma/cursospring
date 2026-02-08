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
    throw new Error(text || `HTTP ${res.status}`)
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
