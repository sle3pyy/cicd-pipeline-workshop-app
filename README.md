# Designing and implementing a CI/CD pipeline

This hands-on workshop introduces participants to the principles and practice of Continuous Integration (CI) and Continuous Deployment (CD). Working with a three-tier application (JavaScript frontend, Python backend, PostgreSQL database), participants will design and build a complete CI/CD pipeline using GitHub Actions, containerize each component with Docker, and deploy to a local Kubernetes cluster via ArgoCD.

By the end of the session, participants will have a working pipeline that automatically builds, tests, and deploys their application on every commit, gaining practical experience with the tools and workflows used in professional software teams.

## 🎯 Application Context

This workshop builds the **DevOps Porto Get-Together Manager** - a web application for organizing and managing the DevOps Porto community get-togethers. For detailed information about the application features, architecture, and requirements, see [ABOUTAPP.md](ABOUTAPP.md).

---

## 📋 What You'll Learn

- **Application Development**: Build a full-stack web application with React, FastAPI, and PostgreSQL
- **Containerization**: Package applications using Docker and Docker Compose
- **CI/CD Pipelines**: Create automated workflows with GitHub Actions
- **Infrastructure as Code**: Deploy using Kubernetes manifests
- **GitOps**: Implement continuous deployment with ArgoCD

## 🏗️ Workshop Structure

This repository contains the **application layer** with skeleton code for participants to complete. A separate repository contains Kubernetes and CI/CD configurations.

### Phase 1: Application Development (Local)
- Implement the three-tier application
- Each component has `TODO` comments for implementation
- Run locally with Docker Compose

### Phase 2: Containerization
- Work with provided Dockerfiles
- Test multi-container setup with docker-compose

### Phase 3: CI/CD & Deployment (Separate Repository)
- Create GitHub Actions workflows
- Deploy using Kubernetes
- Set up ArgoCD for GitOps

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Python 3.11+
- Docker & Docker Compose
- Git

### Run Locally

```bash
# Clone and navigate
git clone <this-repo>
cd cicd-pipeline-workshop-app

# Start the full stack
docker-compose up

# Access services
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
# API Health: http://localhost:8000/health
```

See [SETUP.md](docs/SETUP.md) for detailed setup instructions.

## 📁 Project Structure

```
cicd-pipeline-workshop-app/
├── frontend/           # React.js application (port 3000)
│   └── src/           # TODO: Complete implementation
├── backend/           # FastAPI (port 8000)
│   └── app.py         # TODO: Complete endpoints
├── database/          # PostgreSQL setup
│   └── schema.sql     # TODO: Define schema
├── docker-compose.yml # Local development stack
└── docs/
    ├── SETUP.md              # Setup & troubleshooting
    ├── IMPLEMENTATION.md     # Implementation guide
    └── ARCHITECTURE.md       # Architecture & design
```

## 📚 Documentation

- **[SETUP.md](docs/SETUP.md)** - Getting started & troubleshooting
- **[IMPLEMENTATION.md](docs/IMPLEMENTATION.md)** - Code-along guide with TODOs
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design & tech stack

## 🛠️ Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Frontend | React + Vite | 18.2.0 |
| Backend | FastAPI | 0.115.0 |
| Database | PostgreSQL | 15 |
| Container | Docker | Latest |
| Testing | pytest (backend) / Vitest (frontend) | Latest |

## 🧪 Testing

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm test
```

## 🐳 Docker Compose Services

| Service | Port | Purpose |
|---------|------|---------|
| Frontend | 3000 | React web application |
| Backend | 8000 | FastAPI REST API |
| PostgreSQL | 5432 | Database |

## 📋 Workshop TODOs

Each component has specific implementation tasks:

- [ ] **Frontend**: Implement data fetching, forms, error handling
- [ ] **Backend**: Create API endpoints, database integration
- [ ] **Database**: Define schema, add relationships, seed data

See [IMPLEMENTATION.md](docs/IMPLEMENTATION.md) for detailed tasks.

## 🔗 Related Repositories

- **Kubernetes & CI/CD**: [workshop-k8s-cicd](https://github.com/your-org/workshop-k8s-cicd)
- Contains GitHub Actions workflows, Kubernetes manifests, and ArgoCD setup

## 💡 Key Concepts

- **CI/CD**: Automated testing and deployment on every commit
- **Containerization**: Package applications with dependencies
- **Infrastructure as Code**: Define infrastructure in version control
- **GitOps**: Git as single source of truth for deployments

## 🤝 Workshop Workflow

1. **Implement** the application locally
2. **Test** each component (frontend, backend, database)
3. **Containerize** with Docker
4. **Automate** with GitHub Actions (separate repo)
5. **Deploy** to Kubernetes with ArgoCD (separate repo)

## ⚠️ Prerequisites

- Basic knowledge of web development
- Familiarity with command line
- Git basics
- Docker concepts (helpful but not required)

## 🆘 Need Help?

- Check [SETUP.md](docs/SETUP.md) for common issues
- Review TODO comments in code
- Test locally before moving to next phase
- Docker logs: `docker-compose logs [service]`

## 📝 License

See LICENSE file for details.

---

**Ready to start?** Follow the [SETUP.md](docs/SETUP.md) guide and begin implementing! 🚀

