const BASE = '/api/files'
const credentials: RequestCredentials = 'include'

export interface FileInfo {
  name: string
  sizeInBytes: number
}

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    ...options,
    credentials,
    headers: options?.headers ?? { 'Content-Type': 'application/json' },
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

/** Загрузка файла (multipart). */
export async function uploadFile(file: File): Promise<FileInfo> {
  const form = new FormData()
  form.append('file', file)
  const res = await fetch(BASE, {
    method: 'POST',
    credentials,
    body: form,
  })
  if (!res.ok) {
    const text = await res.text()
    let msg = `HTTP ${res.status}`
    try {
      const json = JSON.parse(text)
      if (json.error) msg = String(json.error)
    } catch {
      if (text) msg = text
    }
    throw new Error(msg)
  }
  return res.json()
}

/** Список всех файлов. */
export function listFiles(): Promise<FileInfo[]> {
  return request<FileInfo[]>(BASE)
}

/** Скачать файл по имени (сохраняется через браузер). */
export async function downloadFile(name: string): Promise<void> {
  const res = await fetch(`${BASE}/${encodeURIComponent(name)}`, { credentials })
  if (!res.ok) {
    const text = await res.text()
    let msg = `HTTP ${res.status}`
    try {
      const json = JSON.parse(text)
      if (json.error) msg = String(json.error)
    } catch {
      if (text) msg = text
    }
    throw new Error(msg)
  }
  const blob = await res.blob()
  const disposition = res.headers.get('Content-Disposition')
  let filename = name
  if (disposition) {
    const match = disposition.match(/filename\*=UTF-8''(.+)/)
    if (match) filename = decodeURIComponent(match[1].trim())
  }
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  a.click()
  URL.revokeObjectURL(url)
}

/** Удалить файл по имени. */
export function deleteFile(name: string): Promise<void> {
  return request<void>(`${BASE}/${encodeURIComponent(name)}`, { method: 'DELETE' })
}
