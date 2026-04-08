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

**Branching strategy**
- How will the team collaborate? (e.g. GitHub Flow, Gitflow, trunk-based development)
- Which branch is the source of truth for deployments?
- Should feature branches be short-lived or long-lived?
- Will you use pull requests? Who reviews them?

**Triggers**
- When should the pipeline run? (push to `main`? any branch? pull requests?)
- Should images be published on every push or only on tagged releases?

**Stages**
- What needs to happen before building a Docker image?
- Should frontend and backend be tested independently or together?
- When should images be published to the registry?

**Quality gates**
- What must pass before an image is built?
- What must pass before an image is pushed?
- Should pull requests be blocked if the pipeline fails?

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

## Task 2 — CI Workflow for the Backend ("Hello World")

A skeleton workflow already exists at `.github/workflows/ci-backend.yml`. The `test` job is already defined. Your task is to complete the `build-and-push` job.

### 2.1 — Add Docker Hub secrets to your repository

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** and add:

| Secret | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token |

> Generate a Docker Hub access token at hub.docker.com → Account Settings → Security.

### 2.2 — Add the build and push job

This job runs only after the `test` job passes and only on pushes to `main`.

```yaml
  build-and-push:
    runs-on: ubuntu-latest
    needs: [test]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
      - uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push backend image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/backend:${{ github.sha }}
```

### 2.3 — Push and observe

```bash
git add .github/workflows/ci-backend.yml
git commit -m "complete backend CI pipeline"
git push origin main
```

Go to your repository on GitHub → **Actions** tab.

**Check:**
- [ ] The `test` job runs and passes
- [ ] The `build-and-push` job starts only after `test` passes
- [ ] The `build-and-push` job is skipped on pull requests
- [ ] The backend image appears in your Docker Hub account

---

## Task 3 — CI Workflow for the Frontend

Repeat the same pattern for the frontend. Open `.github/workflows/ci-frontend.yml` and complete the `build-and-push` job.

### 3.1 — Add the build and push job

```yaml
  build-and-push:
    runs-on: ubuntu-latest
    needs: [test]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
      - uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push frontend image
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/frontend:${{ github.sha }}
```

### 3.2 — Push and observe

```bash
git add .github/workflows/ci-frontend.yml
git commit -m "complete frontend CI pipeline"
git push origin main
```

**Check:**
- [ ] The `test` job runs and passes
- [ ] The `build-and-push` job starts only after `test` passes
- [ ] The frontend image appears in your Docker Hub account

---

## Task 4 — Improve the Pipeline (stretch goals)

Pick one or more improvements to harden the pipeline.

---

### 4.1 — Image Tagging (semver + latest)

Replace the commit SHA tag with a semantic version and always update `latest`.

```yaml
- name: Build and push image
  uses: docker/build-push-action@v5
  with:
    context: ./backend
    push: true
    tags: |
      ${{ secrets.DOCKERHUB_USERNAME }}/backend:${{ github.ref_name }}
      ${{ secrets.DOCKERHUB_USERNAME }}/backend:latest
```

> Requires creating a Git tag before pushing: `git tag v1.0.0 && git push --tags`

---

### 4.2 — Code Style Enforcement

Enforce consistent formatting so style issues are caught in CI, not in code review.

**Backend (black)**
```yaml
- name: Check code style
  run: |
    pip install black
    black --check backend/
```

**Frontend (prettier)**
```yaml
- name: Check code style
  run: |
    npm ci --prefix frontend
    npx prettier --check "frontend/src/**/*.{js,jsx}"
```

---

### 4.3 — Linting

Catch code quality issues beyond formatting.

**Backend (flake8)**
```yaml
- name: Lint
  run: |
    pip install flake8
    flake8 backend/ --max-line-length=120
```

**Frontend (eslint)**
```yaml
- name: Lint
  run: npm run lint --prefix frontend
```

---

### 4.4 — Test Coverage

Fail the pipeline if coverage drops below a threshold.

**Backend**
```yaml
- name: Run tests with coverage
  run: |
    cd backend
    pytest --cov=. --cov-report=xml --cov-fail-under=80
```

**Frontend**
```yaml
- name: Run tests with coverage
  run: npm run test --prefix frontend -- --coverage
```

---

### 4.5 — Static Application Security Testing (SAST)

Scan source code for security vulnerabilities without running it.

**Backend (bandit)**
```yaml
- name: SAST — bandit
  run: |
    pip install bandit
    bandit -r backend/ -ll
```

---

### 4.6 — Dependency Analysis (Dependabot)

Enable Dependabot to automatically open pull requests when dependencies have known vulnerabilities or newer versions are available.

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: pip
    directory: /backend
    schedule:
      interval: weekly

  - package-ecosystem: npm
    directory: /frontend
    schedule:
      interval: weekly

  - package-ecosystem: docker
    directory: /backend
    schedule:
      interval: weekly

  - package-ecosystem: docker
    directory: /frontend
    schedule:
      interval: weekly

  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

---

### 4.7 — Artifact Vulnerability Scanning (Snyk)

Scan the built Docker image for known CVEs before pushing it.

```yaml
- name: Scan image for vulnerabilities
  uses: snyk/actions/docker@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    image: ${{ secrets.DOCKERHUB_USERNAME }}/backend:${{ github.sha }}
    args: --severity-threshold=high
```

> Add `SNYK_TOKEN` to your GitHub repository secrets. Get a free token at snyk.io.

---

### 4.8 — Database Pipeline

Complete the `build-and-push` job in `.github/workflows/ci-database.yml` following the same pattern used for the backend.

---

## Checklist

### Task 0 — Pipeline Design
- [ ] Branching strategy defined
- [ ] Triggers defined (push, pull_request)
- [ ] Stages identified (test → build → push)
- [ ] Quality gates decided

### Task 1 — Application
- [ ] `docker-compose up -d` starts all 3 services without errors
- [ ] `curl http://localhost:8000/health` returns `{"status": "healthy"}`
- [ ] `cd backend && pytest` passes
- [ ] `cd frontend && npm test` passes

### Task 2 — Backend CI
- [ ] `build-and-push` job added to `ci-backend.yml`
- [ ] Docker Hub secrets configured in GitHub repository
- [ ] Backend image published to Docker Hub

### Task 3 — Frontend CI
- [ ] `build-and-push` job added to `ci-frontend.yml`
- [ ] Frontend image published to Docker Hub

### Task 4 — Stretch (optional)
- [ ] Images tagged with semver and `latest`
- [ ] Code style enforcement (black / prettier)
- [ ] Linting (flake8 / eslint)
- [ ] Test coverage with minimum threshold
- [ ] SAST with bandit
- [ ] Dependabot configured for all ecosystems
- [ ] Docker image scanned with Snyk
- [ ] Database pipeline completed

---

## Troubleshooting

**Pipeline not triggering**
- Confirm the workflow file is in `.github/workflows/` at the repo root
- Check the branch name in the `on.push.branches` filter matches your branch

**Docker push fails with "unauthorized"**
- Confirm `permissions: packages: write` is set on the `build-and-push` job
- Add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` as secrets in your GitHub repository settings (Settings → Secrets → Actions)

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

When this pipeline pushes a new image to Docker Hub, ArgoCD detects the change and rolls out the new version automatically — that is the CD half of CI/CD.
