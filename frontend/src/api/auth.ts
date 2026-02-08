const API = '/api/auth'

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
      if (json.error) msg = String(json.error)
      else if (json.message) msg = String(json.message)
    } catch {
      if (text) msg = text
    }
    throw new Error(msg)
  }
  if (res.status === 204) return undefined as T
  return res.json()
}

export interface AuthMe {
  username?: string
  authenticated: boolean
}

export interface LoginRequest {
  username: string
  password: string
}

export const authApi = {
  me: () => request<AuthMe>(`${API}/me`),
  login: (data: LoginRequest) =>
    request<AuthMe>(`${API}/login`, { method: 'POST', body: JSON.stringify(data) }),
  logout: () => request<void>(`${API}/logout`, { method: 'POST' }),
}
