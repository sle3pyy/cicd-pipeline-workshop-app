#!/usr/bin/env bash
# =============================================================================
# CI/CD Workshop — Prerequisites Verification Script
# Stack: JS frontend · Python backend · PostgreSQL · Docker · minikube or kind · ArgoCD
#
# WINDOWS USERS — read this before running:
#   This script requires a Bash environment. It does NOT run in PowerShell
#   or Command Prompt. You must run it inside WSL2.
#
#   Steps:
#     1. Open the Start menu and launch "Ubuntu" (or your WSL2 distro)
#     2. Navigate to this file, e.g.: cd /mnt/c/Users/YourName/Downloads
#     3. Run: chmod +x verify-workshop-reqs.sh
#     4. Run: ./verify-workshop-reqs.sh
#
#   If WSL2 is not installed yet, open PowerShell as Administrator and run:
#     wsl --install
#   Then restart your machine and re-open Ubuntu before running this script.
# =============================================================================

set -euo pipefail

# ── Windows / PowerShell guard ────────────────────────────────────────────────
# Detect if accidentally run outside of a proper Bash environment
if [ -z "${BASH_VERSION:-}" ]; then
  echo ""
  echo "ERROR: This script must be run with Bash, not sh or another shell."
  echo "Run it as:  bash verify-workshop-prereqs.sh"
  exit 1
fi

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Counters ─────────────────────────────────────────────────────────────────
PASS=0
WARN=0
FAIL=0
SKIP=0

# ── Helpers ──────────────────────────────────────────────────────────────────
pass() { echo -e "  ${GREEN}✔${RESET}  $1"; PASS=$((PASS + 1)); }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $1"; WARN=$((WARN + 1)); }
fail() { echo -e "  ${RED}✘${RESET}  $1"; FAIL=$((FAIL + 1)); }
skip() { echo -e "  ${CYAN}–${RESET}  $1 ${CYAN}(skipped)${RESET}"; SKIP=$((SKIP + 1)); }
info() { echo -e "  ${BLUE}ℹ${RESET}  $1"; }
section() {
  echo ""
  echo -e "${BOLD}${BLUE}▶ $1${RESET}"
  echo -e "  ${BLUE}$(printf '%.0s─' {1..54})${RESET}"
}

# Version comparison: returns 0 if $1 >= $2 (both as x.y.z)
version_gte() {
  printf '%s\n%s' "$2" "$1" | sort -C -V
}

# Extract first version-looking string from a command's output
get_version() {
  "$@" 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || true
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║       CI/CD Workshop — Prerequisites Check           ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo -e "  OS   : $(uname -s) $(uname -m)"
echo -e "  Date : $(date '+%Y-%m-%d %H:%M')"

# =============================================================================
# K8S TOOL SELECTION
# =============================================================================
echo ""
echo -e "${BOLD}  Which local Kubernetes tool are you using?${RESET}"
echo -e "  ${CYAN}1)${RESET} minikube  — more features, heavier (recommended for most students)"
echo -e "  ${CYAN}2)${RESET} kind      — lighter, faster, runs entirely inside Docker"
echo ""
read -rp "  Enter 1 or 2 [default: 1]: " K8S_CHOICE
K8S_CHOICE="${K8S_CHOICE:-1}"
case "$K8S_CHOICE" in
  2) K8S_TOOL="kind"     ;;
  *) K8S_TOOL="minikube" ;;
esac
echo -e "  ${BLUE}ℹ${RESET}  Checking for: ${BOLD}${K8S_TOOL}${RESET}"

# =============================================================================
# 1. OPERATING SYSTEM NOTES
# =============================================================================
section "Operating system"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    pass "macOS detected"
    if [[ "$ARCH" == "arm64" ]]; then
      warn "Apple Silicon (arm64) — ensure Docker Desktop uses native arm64 images"
      info "minikube: use --driver=docker   |   kind: works out of the box with Docker"
    else
      pass "Intel x86_64 — no architecture caveats"
    fi
    ;;
  Linux)
    pass "Linux detected"
    if grep -qi microsoft /proc/version 2>/dev/null; then
      pass "WSL2 environment detected — correct way to run this script on Windows"
      info "Ensure Docker Desktop is set to use the WSL2 backend (Settings → Resources → WSL Integration)"
    fi
    ;;
  MINGW*|CYGWIN*|MSYS*)
    echo ""
    echo -e "${RED}${BOLD}  ERROR: You are running this script in a Windows shell (Git Bash / MSYS / Cygwin).${RESET}"
    echo -e "${RED}  This script must be run inside WSL2, not in PowerShell, CMD, or Git Bash.${RESET}"
    echo ""
    echo -e "${YELLOW}  How to fix:${RESET}"
    echo -e "  1. Open the Start menu and launch ${BOLD}Ubuntu${RESET} (or your WSL2 distro)"
    echo -e "  2. Navigate to this file:  cd /mnt/c/Users/YourName/Downloads"
    echo -e "  3. Run:  chmod +x verify-workshop-prereqs.sh"
    echo -e "  4. Run:  ./verify-workshop-prereqs.sh"
    echo ""
    echo -e "  If WSL2 is not installed, open PowerShell as Administrator and run:"
    echo -e "    ${CYAN}wsl --install${RESET}"
    echo -e "  Then restart your machine before trying again."
    echo ""
    exit 1
    ;;
  *)
    warn "Unrecognised OS: $OS"
    ;;
esac

# =============================================================================
# 2. GIT
# =============================================================================
section "Git"

if command -v git &>/dev/null; then
  GIT_VER=$(get_version git --version)
  if version_gte "$GIT_VER" "2.40.0"; then
    pass "git $GIT_VER (required: 2.40+)"
  else
    warn "git $GIT_VER is below recommended 2.40 — consider upgrading"
  fi

  GIT_USER=$(git config --global user.name 2>/dev/null || true)
  GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)
  [[ -n "$GIT_USER" ]]  && pass "git user.name  = \"$GIT_USER\""  || warn "git user.name not set — run: git config --global user.name \"Your Name\""
  [[ -n "$GIT_EMAIL" ]] && pass "git user.email = \"$GIT_EMAIL\"" || warn "git user.email not set — run: git config --global user.email \"you@example.com\""
else
  fail "git not found — install from https://git-scm.com"
fi

# =============================================================================
# 3. NODE.JS & FRONTEND TOOLING
# =============================================================================
section "Node.js & frontend tooling"

if command -v node &>/dev/null; then
  NODE_VER=$(get_version node --version)
  if version_gte "$NODE_VER" "18.0.0"; then
    pass "node $NODE_VER (required: 18+, recommended: 20 LTS)"
  else
    fail "node $NODE_VER is too old — install Node 20 LTS from https://nodejs.org"
  fi
else
  fail "node not found — install Node 20 LTS from https://nodejs.org"
fi

if command -v npm &>/dev/null; then
  NPM_VER=$(get_version npm --version)
  pass "npm $NPM_VER"
else
  fail "npm not found — it ships with Node.js, check your installation"
fi

if command -v npx &>/dev/null; then
  # Check Jest is accessible (project-level — just check npx works)
  pass "npx available (Jest will be installed via package.json)"
else
  warn "npx not found — included with npm 5.2+, update npm"
fi

# =============================================================================
# 4. PYTHON & BACKEND TOOLING
# =============================================================================
section "Python & backend tooling"

PYTHON_CMD=""
for cmd in python3 python; do
  if command -v "$cmd" &>/dev/null; then
    PY_VER=$(get_version "$cmd" --version)
    if version_gte "$PY_VER" "3.11.0"; then
      pass "$cmd $PY_VER (required: 3.11+)"
      PYTHON_CMD="$cmd"
      break
    else
      warn "$cmd $PY_VER found but < 3.11 — install Python 3.11+ from https://python.org"
    fi
  fi
done
[[ -z "$PYTHON_CMD" ]] && fail "Python 3.11+ not found — install from https://python.org"

if command -v pip3 &>/dev/null || command -v pip &>/dev/null; then
  PIP_CMD=$(command -v pip3 || command -v pip)
  PIP_VER=$(get_version "$PIP_CMD" --version)
  pass "pip $PIP_VER"
else
  fail "pip not found — install via: $PYTHON_CMD -m ensurepip --upgrade"
fi

# Check pytest
if command -v pytest &>/dev/null; then
  PT_VER=$(get_version pytest --version)
  pass "pytest $PT_VER"
else
  warn "pytest not found globally — will be installed via requirements.txt (acceptable)"
fi

# Check flake8
if command -v flake8 &>/dev/null; then
  FL_VER=$(get_version flake8 --version)
  pass "flake8 $FL_VER"
else
  warn "flake8 not found globally — will be installed via requirements.txt (acceptable)"
fi

# =============================================================================
# 5. DOCKER
# =============================================================================
section "Docker"

if command -v docker &>/dev/null; then
  DOCKER_VER=$(get_version docker --version)
  if version_gte "$DOCKER_VER" "24.0.0"; then
    pass "docker $DOCKER_VER (required: 24+)"
  else
    warn "docker $DOCKER_VER — recommended 24+, consider upgrading Docker Desktop"
  fi

  # Check daemon is running
  if docker info &>/dev/null 2>&1; then
    pass "Docker daemon is running"

    # Check available memory for Docker
    DOCKER_MEM=$(docker info 2>/dev/null | grep "Total Memory" | grep -oE '[0-9]+(\.[0-9]+)?' | head -1 || true)
    if [[ -n "$DOCKER_MEM" ]]; then
      # Docker reports in GiB; check >= 4
      MEM_INT=${DOCKER_MEM%.*}
      if [[ "$MEM_INT" -ge 4 ]]; then
        pass "Docker memory allocation: ~${DOCKER_MEM} GiB (required: 4+ GiB)"
      else
        fail "Docker memory allocation: ~${DOCKER_MEM} GiB — increase to at least 4 GiB in Docker Desktop → Settings → Resources"
      fi
    fi
  else
    fail "Docker daemon is NOT running — start Docker Desktop and try again"
  fi

  # Docker Compose v2
  if docker compose version &>/dev/null 2>&1; then
    DC_VER=$(docker compose version 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || true)
    pass "docker compose $DC_VER (v2 plugin)"
  elif command -v docker-compose &>/dev/null; then
    DC_VER=$(get_version docker-compose --version)
    warn "docker-compose $DC_VER (v1 standalone) — recommend upgrading to Docker Compose v2 plugin"
  else
    warn "docker compose not found — install Docker Desktop which includes Compose v2"
  fi
else
  fail "docker not found — install Docker Desktop from https://docker.com/products/docker-desktop"
fi

# Docker Hub login check
section "Docker Hub"

if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  DH_CONFIG="$HOME/.docker/config.json"
  if [[ -f "$DH_CONFIG" ]] && grep -q "docker.io\|index.docker.io" "$DH_CONFIG" 2>/dev/null; then
    pass "Docker Hub credentials found in docker config"
  else
    warn "Not logged in to Docker Hub — run: docker login"
    info "You will also need to store credentials as GitHub Actions secrets:"
    info "  DOCKERHUB_USERNAME  and  DOCKERHUB_TOKEN"
  fi
else
  skip "Docker Hub check skipped — Docker not available"
fi

# =============================================================================
# 6. KUBERNETES — minikube or kind, plus kubectl
# =============================================================================
section "Kubernetes (${K8S_TOOL} + kubectl)"

if [[ "$K8S_TOOL" == "minikube" ]]; then
  if command -v minikube &>/dev/null; then
    MK_VER=$(get_version minikube version)
    if version_gte "$MK_VER" "1.32.0"; then
      pass "minikube $MK_VER (required: 1.32+)"
    else
      warn "minikube $MK_VER — recommended 1.32+, run: minikube update-check"
    fi

    MK_STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")
    if [[ "$MK_STATUS" == "Running" ]]; then
      pass "minikube cluster is running"

      MK_MEM=$(minikube config get memory 2>/dev/null || echo "0")
      if [[ "$MK_MEM" -ge 4096 ]]; then
        pass "minikube memory: ${MK_MEM} MB (required: 4096+)"
      else
        warn "minikube memory: ${MK_MEM} MB — start with: minikube start --memory=4096 --cpus=4"
      fi

      MK_CPUS=$(minikube config get cpus 2>/dev/null || echo "0")
      if [[ "$MK_CPUS" -ge 4 ]]; then
        pass "minikube CPUs: $MK_CPUS (recommended: 4+)"
      else
        warn "minikube CPUs: $MK_CPUS — recommended 4 for ArgoCD + 3-tier app"
      fi
    else
      warn "minikube cluster is not running"
      info "Start with: minikube start --driver=docker --memory=4096 --cpus=4"
    fi
  else
    fail "minikube not found — install from https://minikube.sigs.k8s.io/docs/start"
  fi

else
  # ── kind ────────────────────────────────────────────────────────────────────
  if command -v kind &>/dev/null; then
    KIND_VER=$(get_version kind version)
    if version_gte "$KIND_VER" "0.22.0"; then
      pass "kind $KIND_VER (required: 0.22+)"
    else
      warn "kind $KIND_VER — recommended 0.22+, run: go install sigs.k8s.io/kind@latest"
    fi

    # Check if a kind cluster exists
    KIND_CLUSTERS=$(kind get clusters 2>/dev/null || true)
    if [[ -n "$KIND_CLUSTERS" ]]; then
      pass "kind cluster(s) found: $KIND_CLUSTERS"
      info "kind loads images differently from minikube — use: kind load docker-image <image>"
    else
      warn "No kind cluster running"
      info "Create one with: kind create cluster --name workshop"
      info "Note: allocate resources via a config file (see workshop repo for kind-config.yaml)"
    fi
  else
    fail "kind not found — install from https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    info "macOS:  brew install kind"
    info "Linux:  curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && chmod +x kind && sudo mv kind /usr/local/bin/"
  fi
fi

# ── kubectl (required regardless of K8s tool) ─────────────────────────────────
if command -v kubectl &>/dev/null; then
  KB_VER=$(get_version kubectl version --client)
  if version_gte "$KB_VER" "1.29.0"; then
    pass "kubectl $KB_VER (required: 1.29+)"
  else
    warn "kubectl $KB_VER — recommended 1.29+, update via your package manager"
  fi

  if kubectl cluster-info &>/dev/null 2>&1; then
    CTX=$(kubectl config current-context 2>/dev/null || echo "unknown")
    pass "kubectl connected to cluster — context: $CTX"
  else
    warn "kubectl cannot reach a cluster — ensure ${K8S_TOOL} is running"
  fi
else
  fail "kubectl not found — install from https://kubernetes.io/docs/tasks/tools"
fi

# Optional: Helm
if command -v helm &>/dev/null; then
  HELM_VER=$(get_version helm version)
  pass "helm $HELM_VER (optional — nice to have)"
else
  skip "helm not installed — optional for this workshop"
fi

# =============================================================================
# 7. ARGOCD CLI
# =============================================================================
section "ArgoCD CLI"

if command -v argocd &>/dev/null; then
  ARGO_VER=$(get_version argocd version --client)
  if version_gte "$ARGO_VER" "2.10.0"; then
    pass "argocd CLI $ARGO_VER (required: 2.10+)"
  else
    warn "argocd CLI $ARGO_VER — recommended 2.10+, reinstall from https://argo-cd.readthedocs.io"
  fi

  # Check if ArgoCD is deployed in the cluster
  if kubectl get namespace argocd &>/dev/null 2>&1; then
    pass "argocd namespace exists in cluster"
    ARGO_PODS=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    if [[ "$ARGO_PODS" -ge 1 ]]; then
      pass "ArgoCD pods running in cluster: $ARGO_PODS pod(s)"
    else
      warn "ArgoCD namespace exists but no pods are Running"
      info "Install ArgoCD: kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/install.yaml"
    fi
  else
    warn "ArgoCD not yet installed in the cluster"
    info "Install with:"
    info "  kubectl create namespace argocd"
    info "  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/install.yaml"
  fi
else
  fail "argocd CLI not found"
  info "Install instructions:"
  case "$OS" in
    Darwin) info "  brew install argocd" ;;
    Linux)  info "  curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
            info "  chmod +x argocd && sudo mv argocd /usr/local/bin/" ;;
    *)      info "  See https://argo-cd.readthedocs.io/en/stable/cli_installation/" ;;
  esac
fi

# =============================================================================
# 8. VS CODE & EXTENSIONS (optional but recommended)
# =============================================================================
section "VS Code & extensions (recommended)"

if command -v code &>/dev/null; then
  VSCODE_VER=$(get_version code --version)
  pass "VS Code $VSCODE_VER"

  EXTENSIONS=$(code --list-extensions 2>/dev/null || true)
  check_ext() {
    local ext="$1" label="$2"
    if echo "$EXTENSIONS" | grep -qi "$ext"; then
      pass "Extension: $label"
    else
      skip "Extension not installed: $label — run: code --install-extension $ext"
    fi
  }
  check_ext "redhat.vscode-yaml"            "YAML (Red Hat)"
  check_ext "ms-kubernetes-tools.vscode-kubernetes-tools" "Kubernetes (Microsoft)"
  check_ext "ms-azuretools.vscode-docker"   "Docker (Microsoft)"
  check_ext "github.vscode-github-actions"  "GitHub Actions (GitHub)"
  check_ext "ms-python.python"              "Python (Microsoft)"
else
  skip "VS Code not found or not in PATH — download from https://code.visualstudio.com"
fi

# =============================================================================
# 9. NETWORK & DISK
# =============================================================================
section "System resources"

# Disk space — check home directory has at least 15 GB free
if command -v df &>/dev/null; then
  FREE_KB=$(df -k "$HOME" | awk 'NR==2 {print $4}')
  FREE_GB=$(( FREE_KB / 1024 / 1024 ))
  if [[ "$FREE_GB" -ge 15 ]]; then
    pass "Disk space: ~${FREE_GB} GB free in \$HOME (required: 15 GB)"
  elif [[ "$FREE_GB" -ge 8 ]]; then
    warn "Disk space: ~${FREE_GB} GB free — 15 GB recommended (Docker images take space)"
  else
    fail "Disk space: ~${FREE_GB} GB free — at least 15 GB required for Docker images + K8s"
  fi
fi

# RAM (Linux/macOS)
if [[ "$OS" == "Darwin" ]]; then
  TOTAL_RAM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
  TOTAL_RAM_GB=$(( TOTAL_RAM_BYTES / 1024 / 1024 / 1024 ))
  if [[ "$TOTAL_RAM_GB" -ge 16 ]]; then
    pass "RAM: ${TOTAL_RAM_GB} GB total (optimal)"
  elif [[ "$TOTAL_RAM_GB" -ge 8 ]]; then
    warn "RAM: ${TOTAL_RAM_GB} GB total — sufficient but close all other heavy apps during the workshop"
  else
    fail "RAM: ${TOTAL_RAM_GB} GB total — 8 GB minimum required"
  fi
elif [[ "$OS" == "Linux" ]]; then
  TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 0)
  TOTAL_RAM_GB=$(( TOTAL_RAM_KB / 1024 / 1024 ))
  if [[ "$TOTAL_RAM_GB" -ge 16 ]]; then
    pass "RAM: ${TOTAL_RAM_GB} GB total (optimal)"
  elif [[ "$TOTAL_RAM_GB" -ge 8 ]]; then
    warn "RAM: ${TOTAL_RAM_GB} GB total — sufficient but close other heavy apps"
  else
    fail "RAM: ${TOTAL_RAM_GB} GB total — 8 GB minimum required"
  fi
fi

# =============================================================================
# 10. SUMMARY
# =============================================================================
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║                     Summary                         ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${GREEN}✔ Passed  : $PASS${RESET}"
echo -e "  ${YELLOW}⚠ Warnings: $WARN${RESET}"
echo -e "  ${RED}✘ Failed  : $FAIL${RESET}"
echo -e "  ${CYAN}– Skipped : $SKIP${RESET}"
echo ""

if [[ "$FAIL" -eq 0 && "$WARN" -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}All checks passed. You are ready for the workshop!${RESET}"
elif [[ "$FAIL" -eq 0 ]]; then
  echo -e "  ${YELLOW}${BOLD}No blocking issues found. Review warnings above before the session.${RESET}"
else
  echo -e "  ${RED}${BOLD}$FAIL blocking issue(s) found. Please fix them before the workshop.${RESET}"
  echo -e "  ${RED}Scroll up and follow the instructions next to each ${RED}✘${RESET}${RED} item.${RESET}"
fi

echo ""
if grep -qi microsoft /proc/version 2>/dev/null; then
  echo -e "  ${CYAN}Windows/WSL2 reminder: Docker Desktop must have WSL2 integration enabled.${RESET}"
  echo -e "  ${CYAN}Check: Docker Desktop → Settings → Resources → WSL Integration.${RESET}"
fi
echo -e "  ${BLUE}Cluster tool used: ${BOLD}${K8S_TOOL}${RESET}"
echo -e "  ${BLUE}Questions? Contact your instructor or share this output for support.${RESET}"
echo ""

# Exit with non-zero if there are failures (useful for CI/automated checks)
exit "$FAIL"