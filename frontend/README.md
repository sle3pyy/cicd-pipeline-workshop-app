# Frontend — DevOps Porto Get-Together

React application built with Vite. Runs on port **3000** and proxies `/api` requests to the backend on port **8000**.

## Requirements

- Node.js 18+

## Run Locally

```bash
npm install
npm run dev
```

Open http://localhost:3000.

> The backend must be running on port 8000 for API calls to work. See the backend README or use `docker-compose up` to start the full stack.

## Available Scripts

| Command | Description |
|---|---|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build for production (output in `dist/`) |
| `npm run preview` | Preview the production build locally |
| `npm test` | Run tests with Vitest |
| `npm run lint` | Lint source files with ESLint |

## Troubleshooting

**Port 3000 already in use**
```bash
lsof -i :3000
kill -9 <PID>
```

**Dependencies missing**
```bash
rm -rf node_modules package-lock.json
npm install
```
