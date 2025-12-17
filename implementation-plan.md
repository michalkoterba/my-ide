# Docker IDE Implementation Plan

## Overview
A containerized development environment for Python on ARM64 (Oracle Cloud) with:
- **Neovim** (preconfigured via kickstart.nvim + Python LSP)
- **Claude Code** (AI assistant)
- **OpenCode** (AI coding agent)
- **OpenVSCode Server** (web-based VS Code)
- **Python 3.12** with modern tooling (uv, ruff, pyright, debugpy)

---

## 1. Dockerfile Specifications

**Base**: Ubuntu 24.04 (ARM64 compatible)

**Key Components**:

| Component | Installation Method | Purpose |
|-----------|---------------------|---------|
| System deps | `apt-get` | build-essential, ripgrep, fd-find, python3.12 |
| Node.js 20 | nodesource script | Required for LSP servers & AI tools |
| Neovim | GitHub binary (ARM64) | Latest stable, ARM64 optimized |
| Python 3.12 | Ubuntu default | Recent Python version |
| uv | curl install script | Modern Python package manager |
| Python LSP | npm/pip via uv | pyright, ruff, debugpy, mypy |
| Claude Code | npm global | Anthropic's coding assistant |
| OpenCode | curl install script | AI coding agent |
| OpenVSCode Server | GitHub release | Web-based VS Code (optional) |
| kickstart.nvim | git clone | Neovim starter config |

**Preconfiguration**:
- Python LSP servers added to Mason's `ensure_installed` list
- uv installed and added to PATH (`~/.cargo/bin`)
- Default user: `devuser` with passwordless sudo

---

## 2. docker-compose.yml Modifications

**Simplified Single-Service Setup**:
- Single `devbox` service using default bridge network
- No Tailscale sidecar (Tailscale installed on host if needed)
- Volume mounts for configuration persistence

**Volume Mounts**:
```yaml
volumes:
  - ./workspace:/home/devuser/workspace
  - ./config/nvim:/home/devuser/.config/nvim        # Neovim config
  - ~/.anthropic:/home/devuser/.anthropic           # Claude tokens
  - ~/.opencode:/home/devuser/.opencode             # OpenCode config
```

**Environment Variables** (from `.env`):
```yaml
environment:
  - TERM=xterm-256color
  - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}        # Optional
  - OPENCODE_API_KEY=${OPENCODE_API_KEY:-}          # Optional
```

---

## 3. Environment Variables (.env.template)

```env
# Optional: AI service credentials
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxx
OPENCODE_API_KEY=oc-xxxxxxxxxxxxxxxxxxxx
```

**Security**: All credentials stored in `.env` file (git-ignored), not in Docker image.

---

## 4. Entrypoint Script (`entrypoint.sh`)

**Functions**:
1. **Kickstart.nvim Setup**: Copies from `/tmp/kickstart.nvim` if `~/.config/nvim/init.lua` doesn't exist
2. **Python LSP Preconfiguration**: Patches Mason's `ensure_installed` to include:
   ```lua
   'pyright', 'ruff', 'debugpy', 'black', 'mypy'
   ```
3. **PATH Configuration**: Ensures `uv` (`~/.cargo/bin`) is in PATH
4. **Permission Fixes**: Sets correct ownership on mounted volumes

**Behavior**: Idempotent - only modifies config if missing/outdated.

---

## 5. Usage Workflow

```bash
# 1. Setup
cp .env.template .env        # Add your credentials (optional)
docker compose up -d --build

# 2. Access (via SSH to host)
ssh ubuntu@your-server-ip    # Connect to host server
cd my-ide
docker exec -it ide-devbox bash  # Enter container

# 3. Development
nvim                         # Preconfigured Neovim
opencode                     # AI coding agent
claude-code                  # Claude assistant
```

**Python Development**:
- `uv venv` per project in `/home/devuser/workspace`
- LSP servers auto-installed via Mason
- Formatting/linting via ruff, pyright

---

## 6. Key Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| **Python 3.12** | Ubuntu 24.04 default, recent features |
| **uv per project** | Modern, fast dependency management |
| **Mason auto-install** | Ensures LSP servers available on first use |
| **Host SSH access** | Access via SSH to host (Tailscale can be installed on host) |
| **Credentials in .env** | Security best practice, easy rotation |
| **Volume-mounted configs** | Persistence across container recreations |

---

## 7. Questions for Clarification

1. **OpenVSCode Server**: Include in Dockerfile? (adds ~200MB)
2. **Python LSP Configuration**: Use Mason auto-install only, or also preconfigure Neovim keybinds for Python?
3. **Default Python Environment**: Create a default virtual environment in workspace?
4. **Anthropic API**: Should we mount `~/.anthropic` volume AND support `ANTHROPIC_API_KEY` env var?
5. **Additional Tools**: Need `docker`, `kubectl`, or other devops tools inside container?

---

## 8. Implementation Status

**Implementation complete!** All files have been created:
1. `my-ide/implementation-plan.md` (this plan)
2. `my-ide/Dockerfile` - ARM64 optimized with all dependencies
3. `my-ide/docker-compose.yml` - Simplified single-service setup
4. `my-ide/.env.template` - Environment variables (no Tailscale key)
5. `my-ide/entrypoint.sh` - Automated Neovim configuration
6. `my-ide/README.md` - Updated documentation

**Tailscale integration removed**: Container uses default bridge network.
Access via SSH to host (Tailscale can be installed on host for secure access).

---

*Plan created: 2025-12-17*
*Updated: 2025-12-17* (Tailscale removed, simplified to single container)
*Version: 2.0*