# Workshop Tasks — DevOps Porto CI/CD Pipeline

## Goal

Design and implement a CI/CD pipeline for the **DevOps Porto Get-Together** application.

The application (React frontend, FastAPI backend, PostgreSQL database) is provided as **v0.0.1** — a working initial version, not a finished product. It is the starting point, and further development will be needed over time. Your job is to automate its **build, test, and delivery** using GitHub Actions, producing Docker images ready for deployment via ArgoCD and Kubernetes.

A good CI/CD pipeline is what makes evolving that application safe and sustainable.

---

## Application Overview

Before building the pipeline, make sure you understand what you're automating.

```
frontend (React)  →  backend (FastAPI)  →  database (PostgreSQL)
    :3000                :8000                 :5432
```

**Key endpoints:**
```bash
GET  /health             # Backend health check
GET  /api/members        # List members
GET  /api/get-togethers  # List events
```

**Existing tests:**
- Backend: `backend/test_app.py` (pytest)
- Frontend: `frontend/` (vitest)

---

## Task 0 — Design the Pipeline

On paper or a whiteboard, sketch the pipeline before writing any code.

Answer these questions:

**Triggers**
- When should the pipeline run? (push to `main`? any branch? pull requests?)

**Stages**
- What needs to happen before building a Docker image?
- Should frontend and backend be tested independently or together?
- When should images be published to the registry?

**Quality gates**
- What must pass before an image is built?
- What must pass before an image is pushed?

**Expected pipeline shape:**

```
push / pull_request
        │
        ├── test-backend ──┐
        │                  ├── build & push images
        └── test-frontend ─┘
```

---

## Task 1 — Run the Application Locally

Verify the scaffolding works before you automate it.

```bash
# Start all services
docker-compose up -d

# Confirm all 3 services are healthy
curl http://localhost:8000/health
curl http://localhost:8000/api/members
curl http://localhost:3000
```

Run the existing tests locally:

```bash
# Backend
cd backend && pytest

# Frontend
cd frontend && npm test
```

**Checkpoint:** all services respond and tests pass before moving on.

---

## Task 2 — Create the CI Workflow

Create the GitHub Actions workflow file:

```bash
mkdir -p .github/workflows
touch .github/workflows/ci.yml
```

### 2.1 — Define triggers and structure

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  # jobs go here
```

### 2.2 — Add the backend test job

```yaml
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install -r backend/requirements.txt

      - name: Run tests
        run: |
          cd backend
          pytest --cov=. --cov-report=xml
```

### 2.3 — Add the frontend test job

```yaml
  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: "18"
          cache: "npm"
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        run: npm ci --prefix frontend

      - name: Run tests
        run: npm test --prefix frontend
```

### 2.4 — Add the build and push job

This job runs only after both test jobs pass and only on pushes to `main`.

```yaml
  build-and-push:
    runs-on: ubuntu-latest
    needs: [test-backend, test-frontend]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push backend image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ghcr.io/${{ github.repository }}/backend:${{ github.sha }}

      - name: Build and push frontend image
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ghcr.io/${{ github.repository }}/frontend:${{ github.sha }}
```

---

## Task 3 — Trigger and Observe the Pipeline

Push your workflow to GitHub and watch it run.

```bash
git add .github/workflows/ci.yml
git commit -m "add CI pipeline"
git push origin main
```

Go to your repository on GitHub → **Actions** tab.

**Check:**
- [ ] Both test jobs run in parallel
- [ ] The build job only starts after both tests pass
- [ ] Images appear in your GitHub Container Registry (`ghcr.io`)
- [ ] The pipeline fails correctly if a test breaks (try breaking one on purpose)

---

## Task 4 — Improve the Pipeline (stretch goals)

If you have time, pick one or more improvements:

**Image tagging strategy**
- Tag images with both the commit SHA and `latest`
- Tag release images with a semantic version

**Add a lint step**
```yaml
- name: Lint backend
  run: |
    pip install flake8
    flake8 backend/ --max-line-length=120
```

**Build only changed services**
- Use path filters to skip the backend job if only frontend files changed (and vice versa)

**Cache dependencies**
- Add pip dependency caching to speed up the backend job

**Add a pull request summary**
- Post a comment on PRs with test results or coverage

---

## Checklist

### Task 0 — Pipeline Design
- [ ] Triggers defined (push, pull_request)
- [ ] Stages identified (test → build → push)
- [ ] Quality gates decided

### Task 1 — Application
- [ ] `docker-compose up -d` starts all 3 services without errors
- [ ] `curl http://localhost:8000/health` returns `{"status": "healthy"}`
- [ ] `cd backend && pytest` passes
- [ ] `cd frontend && npm test` passes

### Task 2 — CI Workflow
- [ ] `.github/workflows/ci.yml` created
- [ ] Backend test job defined
- [ ] Frontend test job defined
- [ ] Build and push job defined, gated on test jobs

### Task 3 — Validate
- [ ] Pipeline runs on push to `main`
- [ ] Test jobs run in parallel
- [ ] Build job is skipped on pull requests
- [ ] Docker images published to `ghcr.io`

### Task 4 — Stretch (optional)
- [ ] Images tagged with `latest` in addition to SHA
- [ ] Lint step added
- [ ] Dependency caching added

---

## Troubleshooting

**Pipeline not triggering**
- Confirm the workflow file is in `.github/workflows/` at the repo root
- Check the branch name in the `on.push.branches` filter matches your branch

**Docker push fails with "unauthorized"**
- Confirm `permissions: packages: write` is set on the `build-and-push` job
- `GITHUB_TOKEN` is provided automatically — no manual secret needed for GHCR

**Test job fails locally but not in CI (or vice versa)**
```bash
# Check Python version matches CI
python --version  # should be 3.11

# Check Node version matches CI
node --version    # should be 18.x
```

**Services not starting**
```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs db
```

**Port already in use**
```bash
# macOS / Linux
lsof -i :8000
kill -9 <PID>
```

**Database connection issues**
```bash
# Check PostgreSQL is running
docker-compose ps

# Test connection
psql postgresql://workshop_user:workshop_pass@localhost:5432/workshop_db -c "SELECT 1"
```

---

## What Comes Next

The images pushed by this pipeline are consumed by the deployment repository, which contains:
- Kubernetes manifests for each service
- ArgoCD application definitions that watch for new image tags
- Environment-specific configuration (dev, staging, production)

When this pipeline pushes a new image to `ghcr.io`, ArgoCD detects the change and rolls out the new version automatically — that is the CD half of CI/CD.
