import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';
import { VitePWA } from 'vite-plugin-pwa';

// GitHub Pages serves the app under /<repo>/ — set BASE_PATH in CI.
const base = process.env.BASE_PATH ?? '/';

export default defineConfig({
  base,
  plugins: [
    preact(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['fonts/*.ttf', 'icons/*.png'],
      manifest: {
        name: 'jaal',
        short_name: 'jaal',
        description: 'no wifi? no problem. a social network that runs on people, not towers.',
        start_url: base,
        scope: base,
        display: 'standalone',
        background_color: '#f4f1e8',
        theme_color: '#c6ff00',
        icons: [
          { src: 'icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: 'icons/icon-512.png', sizes: '512x512', type: 'image/png' },
          { src: 'icons/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
      },
      workbox: {
        // Everything the app needs offline, fonts included.
        globPatterns: ['**/*.{js,css,html,ttf,png,svg}'],
        maximumFileSizeToCacheInBytes: 5 * 1024 * 1024,
      },
    }),
  ],
});
