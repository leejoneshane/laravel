import { defineConfig } from 'vite'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'
import laravel from 'vite-plugin-laravel'

export default defineConfig({
	plugins: [
		laravel({
			postcss: [
				tailwindcss(),
				autoprefixer(),
			],
		}),
	],
	server: {
		// we need a strict port to match on PHP side
		// change freely, but update on PHP to match the same port
		// tip: choose a different port per project to run them at the same time
		strictPort: true,
		port: 5173
	},
})
