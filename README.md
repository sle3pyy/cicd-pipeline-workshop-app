# Designing and implementing a CI/CD pipeline workshop

A hands-on workshop where participants design and implement a CI/CD pipeline for a real 3-tier web application using GitHub Actions, Docker, and ArgoCD.

---

## 🎯 Goal

The **DevOps Porto Get-Together** application (v0.0.1) is already built and running. Your job is to automate its build, test, and delivery process — designing and implementing a CI/CD pipeline from scratch.

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for the workshop tasks.

---

## 🏗️ Workshop Structure

### This repository — Application + CI Pipeline
The application is provided as a working starting point. Participants implement the CI pipeline using GitHub Actions to automatically build, test, and publish Docker images on every commit.

### Separate repository — Kubernetes + CD
A companion repository contains Kubernetes manifests and ArgoCD configuration. ArgoCD watches for new image tags published by this pipeline and deploys them automatically.

```
This repo                          Companion repo
─────────────────────────────      ──────────────────────────
App code (v0.0.1, pre-built)  →   Kubernetes manifests
GitHub Actions CI pipeline     →   ArgoCD (GitOps CD)
Docker images → ghcr.io        →   Deployed to cluster
```

---

## 📋 What You'll Learn

- How to design a CI/CD pipeline for a multi-tier application
- Implementing CI workflows with GitHub Actions
- Building and publishing Docker images to a container registry
- Continuous deployment with ArgoCD and GitOps principles

---

## 🚀 Quick Start

**Prerequisites:** Docker & Docker Compose, Git, Node.js 18+, Python 3.12+

```bash
# Clone and start the full stack
git clone <this-repo>
cd cicd-pipeline-workshop-app
docker-compose up -d
```

| Service | URL |
|---|---|
| Frontend | http://localhost:3000 |
| Backend | http://localhost:8000 |
| API Health | http://localhost:8000/health |
| API Docs | http://localhost:8000/docs |

```bash
docker-compose down   # stop
```

For running services individually see [frontend/README.md](frontend/README.md) and [backend/README.md](backend/README.md).

---

## 📁 Project Structure

```
cicd-pipeline-workshop-app/
├── frontend/               # React application (port 3000)
│   ├── src/                # Application source
│   ├── Dockerfile
│   └── README.md           # Frontend local dev instructions
├── backend/                # FastAPI application (port 8000)
│   ├── app.py              # API endpoints
│   ├── test_app.py         # Tests
│   ├── Dockerfile
│   └── README.md           # Backend local dev instructions
├── database/               # PostgreSQL + Flyway
│   ├── migrations/         # Versioned SQL migration files
│   ├── flyway-init.sh      # Runs migrations on container startup
│   └── Dockerfile
├── docs/
│   ├── CONTRIBUTING.md     # Workshop tasks
│   ├── ARCHITECTURE.md     # Architecture & tech stack
│   ├── FLYWAY.md           # Database migration guide
│   ├── ABOUTAPP.md         # Application context and features
│   ├── PIPELINE.md         # Pipeline anatomy reference
│   └── REQUIREMENTS.md     # System prerequisites
├── docker-compose.yml      # Full stack for local development
└── docker-compose.db.yml   # Database only
```

---

## 🛠️ Tech Stack

| Component | Technology | Version |
|---|---|---|
| Frontend | React + Vite | 18.2.0 |
| Backend | FastAPI | 0.115.0 |
| Database | PostgreSQL | 15 |
| Migrations | Flyway | 9.22.3 |
| Testing | pytest / Vitest | — |
| CI | GitHub Actions | — |
| CD | ArgoCD | — |

---

## 📚 Documentation

- [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) — Workshop tasks
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — System design & tech stack
- [frontend/README.md](frontend/README.md) — Frontend local dev
- [backend/README.md](backend/README.md) — Backend local dev

---

## 📝 License

See LICENSE file for details.
