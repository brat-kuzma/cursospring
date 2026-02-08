import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
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
