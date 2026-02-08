import { useState, useEffect } from 'react'

const STORAGE_KEY = 'tasks-app-user'

export function useAuth() {
  const [user, setUserState] = useState<string | null>(() =>
    localStorage.getItem(STORAGE_KEY)
  )

  useEffect(() => {
    if (user) localStorage.setItem(STORAGE_KEY, user)
    else localStorage.removeItem(STORAGE_KEY)
  }, [user])

  const login = (name: string) => {
    const value = name.trim() || null
    if (value) localStorage.setItem(STORAGE_KEY, value)
    else localStorage.removeItem(STORAGE_KEY)
    setUserState(value)
  }
  const logout = () => {
    localStorage.removeItem(STORAGE_KEY)
    setUserState(null)
  }

  return { user, isLoggedIn: !!user, login, logout }
}
