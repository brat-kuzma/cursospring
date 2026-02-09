import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: '0.0.0.0', // Слушать на всех интерфейсах для доступа с удалённых машин
    proxy: {
      '/api': {
        // Для удалённого сервера: замените localhost на IP сервера или используйте переменную окружения
        target: process.env.VITE_API_URL || 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
        configure: (proxy) => {
          proxy.on('proxyRes', (proxyRes) => {
            const setCookie = proxyRes.headers['set-cookie']
            if (Array.isArray(setCookie)) {
              proxyRes.headers['set-cookie'] = setCookie.map((c) =>
                c.replace(/;\s*Domain=[^;]+/i, '')
              )
            }
          })
        },
      },
    },
  },
})
