import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import * as filesApi from '../api/files'
import type { FileInfo } from '../api/files'

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} Б`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} КБ`
  if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} МБ`
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} ГБ`
}

export function FileManagerPage() {
  const { user, logout } = useAuth()
  const [files, setFiles] = useState<FileInfo[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [uploading, setUploading] = useState(false)
  const [selectedFile, setSelectedFile] = useState<File | null>(null)

  const loadFiles = async () => {
    setError(null)
    try {
      const data = await filesApi.listFiles()
      setFiles(data)
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось загрузить список файлов')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadFiles()
  }, [])

  const handleUpload = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!selectedFile) return
    setUploading(true)
    setError(null)
    try {
      await filesApi.uploadFile(selectedFile)
      setSelectedFile(null)
      await loadFiles()
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось загрузить файл')
    } finally {
      setUploading(false)
    }
  }

  const handleDelete = async (name: string) => {
    if (!window.confirm(`Удалить файл «${name}»?`)) return
    setError(null)
    try {
      await filesApi.deleteFile(name)
      await loadFiles()
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось удалить файл')
    }
  }

  const handleDownload = async (name: string) => {
    setError(null)
    try {
      await filesApi.downloadFile(name)
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось скачать файл')
    }
  }

  return (
    <div className="files-wrap">
      <header className="files-header">
        <div className="files-header-inner">
          <nav className="files-nav">
            <Link to="/" className="files-nav-link">Задачи</Link>
            <span className="files-nav-sep">|</span>
            <Link to="/files" className="files-nav-link files-nav-link-active">Файлы</Link>
          </nav>
          <div className="files-user">
            <span className="files-username">{user}</span>
            <button type="button" onClick={() => logout()} className="files-logout">
              Выйти
            </button>
          </div>
        </div>
      </header>

      <main className="files-main">
        <section className="files-section files-form-section">
          <h1 className="files-title">Файловый менеджер</h1>
          <h2 className="section-title">Загрузить файл</h2>
          <form onSubmit={handleUpload} className="file-form">
            <input
              type="file"
              onChange={(e) => setSelectedFile(e.target.files?.[0] ?? null)}
              className="file-input"
              disabled={uploading}
            />
            <button type="submit" disabled={uploading || !selectedFile} className="file-submit">
              {uploading ? 'Загрузка…' : 'Загрузить'}
            </button>
          </form>
          <p className="files-hint">Максимальный размер файла: 1 ГБ. Файлы сохраняются на сервере и доступны после перезапуска.</p>
        </section>

        {error && (
          <div className="files-error">
            {error}
          </div>
        )}

        <section className="files-section">
          <h2 className="section-title">Загруженные файлы</h2>
          {loading ? (
            <div className="files-loading">Загрузка…</div>
          ) : files.length === 0 ? (
            <div className="files-empty">Нет файлов. Загрузите первый.</div>
          ) : (
            <ul className="file-list">
              {files.map((f) => (
                <li key={f.name} className="file-item">
                  <div className="file-item-info">
                    <span className="file-item-name" title={f.name}>{f.name}</span>
                    <span className="file-item-size">{formatSize(f.sizeInBytes)}</span>
                  </div>
                  <div className="file-item-actions">
                    <button
                      type="button"
                      onClick={() => handleDownload(f.name)}
                      className="file-item-download"
                      title="Скачать"
                    >
                      Скачать
                    </button>
                    <button
                      type="button"
                      onClick={() => handleDelete(f.name)}
                      className="file-item-delete"
                      title="Удалить"
                    >
                      ✕
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>

      <style>{`
        .files-wrap {
          min-height: 100vh;
          background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
        }
        .files-header {
          border-bottom: 1px solid rgba(71, 85, 105, 0.5);
          background: rgba(15, 23, 42, 0.9);
        }
        .files-header-inner {
          max-width: 900px;
          margin: 0 auto;
          padding: 1rem 1.5rem;
          display: flex;
          align-items: center;
          justify-content: space-between;
        }
        .files-nav {
          display: flex;
          align-items: center;
          gap: 0.5rem;
        }
        .files-nav-link {
          color: #94a3b8;
          text-decoration: none;
          font-size: 1rem;
          transition: color 0.2s;
        }
        .files-nav-link:hover {
          color: #e2e8f0;
        }
        .files-nav-link-active {
          color: #f1f5f9;
          font-weight: 600;
        }
        .files-nav-sep {
          color: #475569;
          font-size: 0.9rem;
        }
        .files-title {
          margin: 0 0 1.5rem;
          font-size: 1.75rem;
          font-weight: 700;
          color: #f1f5f9;
        }
        .files-user {
          display: flex;
          align-items: center;
          gap: 1rem;
        }
        .files-username {
          color: #94a3b8;
          font-size: 0.9rem;
        }
        .files-logout {
          padding: 0.4rem 0.75rem;
          background: transparent;
          border: 1px solid #475569;
          border-radius: 8px;
          color: #94a3b8;
          font-size: 0.875rem;
          transition: border-color 0.2s, color 0.2s;
        }
        .files-logout:hover {
          border-color: #64748b;
          color: #e2e8f0;
        }
        .files-main {
          max-width: 900px;
          margin: 0 auto;
          padding: 2rem 1.5rem;
        }
        .files-section {
          margin-bottom: 2rem;
        }
        .files-form-section {
          margin-bottom: 2rem;
        }
        .section-title {
          margin: 0 0 1rem;
          font-size: 1.1rem;
          font-weight: 600;
          color: #cbd5e1;
        }
        .file-form {
          display: flex;
          align-items: center;
          gap: 1rem;
          flex-wrap: wrap;
          padding: 1.5rem;
          background: rgba(30, 41, 59, 0.6);
          border: 1px solid rgba(71, 85, 105, 0.4);
          border-radius: 12px;
        }
        .file-input {
          flex: 1;
          min-width: 200px;
          padding: 0.5rem;
          background: #1e293b;
          border: 1px solid #334155;
          border-radius: 8px;
          color: #e2e8f0;
          font-size: 0.9rem;
        }
        .file-input::file-selector-button {
          margin-right: 0.75rem;
          padding: 0.35rem 0.65rem;
          background: #334155;
          border: none;
          border-radius: 6px;
          color: #cbd5e1;
          font-size: 0.85rem;
          cursor: pointer;
        }
        .file-submit {
          padding: 0.6rem 1.25rem;
          background: linear-gradient(135deg, #6366f1, #4f46e5);
          border: none;
          border-radius: 8px;
          color: #fff;
          font-weight: 600;
          font-size: 0.9rem;
          transition: opacity 0.2s;
        }
        .file-submit:hover:not(:disabled) {
          opacity: 0.9;
        }
        .file-submit:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }
        .files-hint {
          margin: 0.75rem 0 0;
          font-size: 0.85rem;
          color: #64748b;
        }
        .files-error {
          padding: 0.75rem 1rem;
          margin-bottom: 1rem;
          background: rgba(239, 68, 68, 0.15);
          border: 1px solid rgba(239, 68, 68, 0.4);
          border-radius: 8px;
          color: #fca5a5;
          font-size: 0.9rem;
        }
        .files-loading, .files-empty {
          padding: 2rem;
          text-align: center;
          color: #94a3b8;
        }
        .file-list {
          list-style: none;
          margin: 0;
          padding: 0;
          display: flex;
          flex-direction: column;
          gap: 0.75rem;
        }
        .file-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 1rem;
          padding: 1rem 1.25rem;
          background: rgba(30, 41, 59, 0.6);
          border: 1px solid rgba(71, 85, 105, 0.4);
          border-radius: 10px;
          transition: border-color 0.2s, background 0.2s;
        }
        .file-item:hover {
          border-color: rgba(99, 102, 241, 0.4);
          background: rgba(30, 41, 59, 0.8);
        }
        .file-item-info {
          flex: 1;
          min-width: 0;
          display: flex;
          align-items: baseline;
          gap: 0.75rem;
        }
        .file-item-name {
          font-weight: 500;
          color: #f1f5f9;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
        .file-item-size {
          flex-shrink: 0;
          font-size: 0.85rem;
          color: #64748b;
        }
        .file-item-actions {
          display: flex;
          align-items: center;
          gap: 0.5rem;
        }
        .file-item-download {
          padding: 0.4rem 0.75rem;
          background: transparent;
          border: 1px solid #475569;
          border-radius: 8px;
          color: #94a3b8;
          font-size: 0.875rem;
          transition: border-color 0.2s, color 0.2s;
        }
        .file-item-download:hover {
          border-color: #6366f1;
          color: #a5b4fc;
        }
        .file-item-delete {
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
        .file-item-delete:hover {
          border-color: #f87171;
          color: #f87171;
          background: rgba(248, 113, 113, 0.1);
        }
      `}</style>
    </div>
  )
}
