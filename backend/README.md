# Backend — DevOps Porto Get-Together

FastAPI application. Runs on port **8000**.

## Requirements

- Python 3.12+

## Run Locally

```bash
pip install -r requirements.txt
cp .env.example .env
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

Open http://localhost:8000.

API docs available at http://localhost:8000/docs.

> The database must be running on port 5432. Use `docker-compose -f docker-compose.db.yml up -d` to start only the database.

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
