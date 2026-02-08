import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'

export function LoginPage() {
  const [name, setName] = useState('')
  const { login } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const trimmed = name.trim()
    if (!trimmed) return
    login(trimmed)
    navigate('/', { replace: true })
  }

  return (
    <div className="login-wrap">
      <div className="login-card">
        <h1 className="login-title">Хранилище задач</h1>
        <p className="login-subtitle">Введите имя для входа</p>
        <form onSubmit={handleSubmit} className="login-form">
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Ваше имя"
            className="login-input"
            autoFocus
          />
          <button type="submit" className="login-btn">
            Войти
          </button>
        </form>
      </div>
      <style>{`
        .login-wrap {
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 1rem;
          background: linear-gradient(145deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
        }
        .login-card {
          width: 100%;
          max-width: 380px;
          padding: 2.5rem;
          background: rgba(30, 41, 59, 0.8);
          border: 1px solid rgba(71, 85, 105, 0.5);
          border-radius: 16px;
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }
        .login-title {
          margin: 0 0 0.5rem;
          font-size: 1.75rem;
          font-weight: 700;
          color: #f1f5f9;
          text-align: center;
        }
        .login-subtitle {
          margin: 0 0 1.5rem;
          color: #94a3b8;
          font-size: 0.95rem;
          text-align: center;
        }
        .login-form {
          display: flex;
          flex-direction: column;
          gap: 1rem;
        }
        .login-input {
          padding: 0.75rem 1rem;
          background: #1e293b;
          border: 1px solid #334155;
          border-radius: 10px;
          color: #e2e8f0;
          outline: none;
          transition: border-color 0.2s, box-shadow 0.2s;
        }
        .login-input::placeholder {
          color: #64748b;
        }
        .login-input:focus {
          border-color: #6366f1;
          box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }
        .login-btn {
          padding: 0.75rem 1.5rem;
          background: linear-gradient(135deg, #6366f1, #4f46e5);
          border: none;
          border-radius: 10px;
          color: #fff;
          font-weight: 600;
          transition: opacity 0.2s, transform 0.1s;
        }
        .login-btn:hover {
          opacity: 0.95;
        }
        .login-btn:active {
          transform: scale(0.98);
        }
      `}</style>
    </div>
  )
}
