## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        CI/CD Pipeline                        │
│              (GitHub Actions, ArgoCD - separate repo)        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌──────────────────────────────────────────────────────────────┐
│                      Docker Registry                          │
│                  (Registry credentials)                       │
└──────────────────────────────────────────────────────────────┘
           ↙                    ↓                    ↖
      ┌────────┐         ┌─────────┐         ┌──────────┐
      │Frontend │         │ Backend │         │PostgreSQL│
      │(Port   │         │(Port   │         │(Port    │
      │ 3000)  │         │ 8000)  │         │ 5432)   │
      └────────┘         └─────────┘         └──────────┘
         △                   △                    △
         │                   │                    │
      ┌──┴──────────────────┴────────────────────┴──┐
      │      Docker Compose (Local Dev)              │
      └──────────────────────────────────────────────┘


Frontend (React)              Backend (FastAPI)           Database (PostgreSQL)
├── src/                      ├── app.py               ├── schema.sql
├── package.json              ├── models.py            ├── seed.sql
├── vite.config.js            ├── test_app.py          └── init.sh
├── Dockerfile                ├── requirements.txt
├── index.html                ├── .env.example
└── src/App.jsx               └── Dockerfile
```

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | React | 18.2.0 |
| Frontend Bundler | Vite | 5.0.0 |
| Backend | FastAPI | 0.115.0 |
| Database | PostgreSQL | 15 |
| Testing (Backend) | pytest | 7.4.3 |
| Testing (Frontend) | Vitest | 1.0.0 |
| Containerization | Docker | Latest |
| Orchestration | Docker Compose | 3.8 |

## Environment Variables

### Frontend (.env)
```
REACT_APP_API_URL=http://localhost:8000
REACT_APP_ENV=development
```

### Backend (.env)
```
FLASK_ENV=development
DATABASE_URL=postgresql://workshop_user:workshop_pass@localhost:5432/workshop_db
PORT=8000
```

### Database (docker-compose.yml)
```
POSTGRES_DB=workshop_db
POSTGRES_USER=workshop_user
POSTGRES_PASSWORD=workshop_pass
```

## API Endpoints

| Method | Endpoint | Purpose | Status |
|--------|----------|---------|--------|
| GET | `/health` | Health check | ✓ Ready |
| GET | `/api/data` | Retrieve data | TODO |
| POST | `/api/data` | Create new item | TODO |
| PUT | `/api/data/{id}` | Update item | TODO |
| DELETE | `/api/data/{id}` | Delete item | TODO |

## File Structure

```
cicd-pipeline-workshop-app/
├── frontend/                 # React.js application
│   ├── src/
│   │   ├── main.jsx         # Entry point
│   │   ├── App.jsx          # Main component (TODO: implement)
│   │   ├── App.css
│   │   └── index.css
│   ├── package.json
│   ├── vite.config.js
│   ├── index.html
│   └── Dockerfile
├── backend/           # FastAPI
│   ├── app.py               # Main app (TODO: implement endpoints)
│   ├── models.py            # Data models (TODO: define)
│   ├── test_app.py          # Tests
│   ├── requirements.txt
│   ├── .env.example
│   └── Dockerfile
├── database/                 # PostgreSQL
│   ├── schema.sql           # Schema (TODO: define tables)
│   ├── seed.sql             # Seed data (TODO: add)
│   └── init.sh              # Init script
├── docker-compose.yml        # Local development stack
├── docs/
│   ├── SETUP.md
│   ├── IMPLEMENTATION.md
│   └── ARCHITECTURE.md
└── README.md
```
