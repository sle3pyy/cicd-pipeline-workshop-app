# Backend — DevOps Porto Get-Together

FastAPI application. Runs on port **8000**.

## Requirements

- Python 3.12+

## Run Locally

### 1. Start the database

The backend requires PostgreSQL running on port 5432. Start it with:

```bash
docker-compose -f docker-compose.db.yml up -d
```

### 2. Create and activate a virtual environment

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` if needed — the defaults work with the Docker database setup.

### 5. Start the server

```bash
uvicorn app:app --port 8000 --reload
```

The `--reload` flag restarts the server automatically on code changes.

### 6. Verify it is running

```bash
curl http://localhost:8000/health
```

Expected response: `{"status":"healthy","service":"DevOps Porto Get-Together Backend"}`

Interactive API docs are available at http://localhost:8000/docs.

## Available Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| `GET` | `/api/members` | List members |
| `POST` | `/api/members` | Create member |
| `GET` | `/api/get-togethers` | List events |
| `POST` | `/api/get-togethers` | Create event |

## Run Tests

```bash
pytest
pytest --cov=.
```

## Troubleshooting

**Port 8000 already in use**
```bash
lsof -i :8000
kill -9 <PID>
```

**Dependencies missing**
```bash
pip install -r requirements.txt
```

**Database connection error**
- Ensure PostgreSQL is running on port 5432
- Check `DATABASE_URL` in your `.env` file
