import type { Task, CreateTaskRequest } from '../types/task'

const BASE = '/api/tasks'

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    ...options,
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
  delete: (id: number) =>
    request<void>(`${BASE}/${id}`, { method: 'DELETE' }),
}
