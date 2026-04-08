# CI/CD Workshop Requirements

## System Requirements

### Operating System
- macOS 11+ (Intel or Apple Silicon)
- Linux (Ubuntu 20.04+ recommended)
- Windows 10+ with WSL 2

### Required Accounts

- **GitHub account** — https://github.com/join
- **Docker Hub account** — https://hub.docker.com/signup

### Required Software

| Software | Version | Download |
|----------|---------|----------|
| Git | 2.30+ | https://git-scm.com |
| Docker Desktop | 20.10+ | https://www.docker.com/products/docker-desktop |
| Docker Compose | latest stable | https://docs.docker.com/compose/ |
| ArgoCD | latest stable | https://argo-cd.readthedocs.io/en/stable/getting_started/ |
| minikube | latest stable | https://minikube.sigs.k8s.io/docs/start/ |
| kind | latest stable | https://kind.sigs.k8s.io/docs/user/quick-start/ |
| kubectl | latest stable | https://kubernetes.io/docs/tasks/tools/ |
| Node.js | 18.0+ | https://nodejs.org |
| Python | 3.11+ | https://www.python.org |


### Recommended IDE

- **Visual Studio Code** - https://code.visualstudio.com/

### Optional (for local development without Docker)

| Software | Version | Purpose |
|----------|---------|---------|
| PostgreSQL | 15+ | Local database |
| DBeaver | Latest stable | Database GUI and query tool |
| Postman | Latest stable | API testing and inspection |

## Disk Space

- **Minimum**: 10 GB free
- **Recommended**: 20 GB free

Docker images and dependencies require:
- Node.js deps: ~500 MB
- Python deps: ~200 MB
- Docker images: ~2 GB
- Database data: variable

## Network Requirements

- Stable internet connection
- Access to Docker Hub (for pulling images)
- npm registry (for frontend packages)
- PyPI (for backend packages)

## System Specifications

### Minimum
- 2 CPU cores
- 4 GB RAM

### Recommended
- 4 CPU cores
- 8 GB RAM

## Pre-Workshop Checklist

Before the workshop, verify your setup:

```bash
# Check Git
git --version

# Check Docker
docker --version
docker-compose --version

# Check Node.js
node --version
npm --version

# Check Python
python --version
pip --version

# Verify Docker functionality
docker run hello-world
```

## Logging In

### Docker Hub (Optional)

If pulling large images:

```bash
docker login
# Enter username and password
```

## Ports Required

Ensure these ports are available:
- **3000**: Frontend (React)
- **8000**: Backend (FastAPI)
- **5432**: PostgreSQL

### Checking Available Ports

```bash
# macOS/Linux
lsof -i :3000
lsof -i :8000
lsof -i :5432

# Windows
netstat -ano | findstr :3000
```

If ports are in use, you can modify them in `docker-compose.yml`


## Post-Workshop Cleanup

To free up disk space after the workshop:

```bash
# Remove workshop images
docker-compose down -v

# Clean Docker system
docker system prune -a

# Remove node modules
rm -rf frontend/node_modules

# Remove Python cache
rm -rf backend/__pycache__
```
