# Docker IDE for ARM64 (Oracle Cloud)

A containerized development environment for Python on ARM64 (Oracle Cloud) with modern tooling and AI assistants.

## Features

- **Neovim** with [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) configuration
- **Python 3.12** with modern tooling (uv, ruff, pyright, debugpy, mypy)
- **Claude Code** - Anthropic's coding assistant
- **OpenCode** - AI coding agent with LSP integration
- **OpenVSCode Server** - Web-based VS Code (optional)
- **ARM64 optimized** - Built for Oracle Cloud ARM instances

## Quick Start

### 1. Prerequisites

- Docker and Docker Compose
- Oracle Cloud ARM instance (or any ARM64 machine with Docker)

### 2. Setup

```bash
# Clone or extract the project
cd my-ide

# Copy environment template and edit with your credentials
cp .env.template .env
# Edit .env with your API keys (optional)

# Build and start the containers
docker compose up -d --build

# Check container status
docker compose ps
```

### 3. Access the Development Environment

#### Option A: Via SSH (Recommended)
1. SSH to the host server (Tailscale can be installed on host for secure access)
2. Navigate to project directory and enter the container:
   ```bash
   ssh ubuntu@your-server-ip
   cd my-ide
   docker exec -it ide-devbox bash
   ```

#### Option B: Direct Docker Exec
If running locally or have direct Docker access:
```bash
docker exec -it ide-devbox bash
```

## Environment Structure

### Directory Layout
```
my-ide/
├── config/nvim/           # Neovim configuration (persistent)
├── workspace/             # Project workspace (persistent)
├── Dockerfile             # Container definition
├── docker-compose.yml     # Service orchestration
├── entrypoint.sh          # Container initialization
├── .env.template          # Environment template
└── README.md              # This file
```

### Volume Mounts
- `./workspace` → `/home/devuser/workspace` - Your projects
- `./config/nvim` → `/home/devuser/.config/nvim` - Neovim config
- `~/.anthropic` → `/home/devuser/.anthropic` - Claude Code tokens
- `~/.opencode` → `/home/devuser/.opencode` - OpenCode config/cache

## Available Tools

### Development
- **nvim** - Neovim with preconfigured LSP, treesitter, telescope
- **python3.12** - Python interpreter
- **uv** - Modern Python package manager (replaces pip/venv)
- **Node.js 20** - JavaScript runtime for LSP servers

### AI Assistants
- **claude-code** - Anthropic's Claude Code assistant
- **opencode** - AI coding agent with multi-model support

### LSP & Tooling
- **pyright** - Python language server (type checking, completion)
- **ruff** - Ultra-fast Python linter and formatter
- **debugpy** - Python debugger for Neovim/VS Code
- **mypy** - Optional static type checker
- **black** - Python code formatter
- **isort** - Python import sorter

### Optional
- **OpenVSCode Server** - Web-based VS Code at `http://localhost:3000` (if exposed)

## Python Development Workflow

Inside the container:
```bash
# Create a new project
cd /home/devuser/workspace
mkdir myproject && cd myproject

# Create virtual environment with uv
uv venv
source .venv/bin/activate

# Install dependencies
uv pip install fastapi uvicorn

# Start Neovim with LSP support
nvim main.py
```

## Neovim Configuration

The container comes with [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) preconfigured with:

### Python-specific Setup
- **pyright** LSP server auto-installed via Mason
- **ruff** formatting via conform.nvim
- **debugpy** for debugging support
- **mypy** and **black** available via Mason

### Key Features
- LSP auto-completion with [blink.cmp](https://github.com/saghen/blink.cmp)
- File navigation with [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- Syntax highlighting with [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Git integration with [gitsigns](https://github.com/lewis6991/gitsigns.nvim)

### Customization
Custom Python LSP configuration is in `lua/custom/python.lua`. To extend:
1. Edit `./config/nvim/lua/custom/` on the host
2. Restart Neovim or run `:Lazy sync`

## AI Assistant Setup

### Claude Code
1. First run: `claude-code`
2. Follow authentication prompts
3. Tokens stored in `~/.anthropic` (mounted from host)

### OpenCode
1. First run: `opencode`
2. Run `/connect` to configure providers
3. Configuration stored in `~/.opencode` (mounted from host)



## Maintenance

### Updating Containers
```bash
docker compose down
docker compose pull
docker compose up -d --build
```

### Resetting Environment
```bash
# Remove containers and volumes (preserves workspace/config)
docker compose down -v

# Rebuild from scratch
docker compose up -d --build
```

### Backup
- `./workspace` - Your projects
- `./config/nvim` - Neovim configuration
- `~/.anthropic` - Claude tokens (on host)
- `~/.opencode` - OpenCode config (on host)

## Build Notes

### ARM64 Compatibility
- Dockerfile is optimized for ARM64 (Oracle Cloud ARM instances)
- Uses Ubuntu 24.04 base image with ARM64 binaries
- Neovim ARM64 binary downloaded from official releases
- Python packages installed via uv (installed via pipx)

### Docker Compose
- Uses Docker Compose v2 syntax (no `version:` attribute)
- If using older Docker Compose v1, add `version: '3.8'` at the top of `docker-compose.yml`

### uv Installation
- uv is installed via `pip3 install uv --break-system-packages`
- Ubuntu 24.04's externally-managed-environment restriction removed
- uv available system-wide in `/usr/local/bin`

### Python Package Installation
- Python LSP tools (ruff, debugpy, etc.) installed via `uv pip install --system --break-system-packages`
- This bypasses Ubuntu's protected Python environment for containers

### Building on x86_64
To build ARM64 image on x86_64 host, use Docker Buildx:
```bash
docker buildx build --platform linux/arm64 -t my-ide .
```

## Troubleshooting

### Common Issues

#### "Permission denied" on mounted volumes

The container runs as non-root user `devuser` with passwordless sudo. Mounted volumes (workspace, config/nvim) may have incorrect permissions.

**Symptoms**: Entrypoint logs show "Permission denied" when copying Neovim config files.

**Solutions**:

1. **Fix host permissions** (recommended):
   ```bash
   sudo chown -R $USER:$USER ./workspace ./config
   ```

2. **Let container fix permissions** (entrypoint uses sudo):
   - The entrypoint script uses `sudo` to create/copy files
   - If host directory is owned by root, `devuser` can still write via sudo
   - Files will be owned by root initially, then chowned to `devuser`

3. **If issues persist**:
   ```bash
   # Remove existing volumes and rebuild
   docker compose down -v
   docker compose up -d --build
   ```

**Note**: The `devuser` has passwordless sudo for container maintenance. This is safe in a container environment.



#### "externally-managed-environment" error when installing Python packages
This occurs because Ubuntu 24.04 protects system Python. The Dockerfile removes the restriction file and uses `--break-system-packages` flag. If you encounter this error elsewhere, ensure you're using `--break-system-packages` with pip/uv.

#### LSP servers not installing
1. Enter container: `docker exec -it ide-devbox bash`
2. Run Neovim: `nvim`
3. Check Mason: `:Mason`
4. Install manually: `:MasonInstall pyright ruff debugpy`

#### Neovim plugin installation issues (nvim-treesitter errors)

If you see errors like "module 'nvim-treesitter.configs' not found":

1. **Plugins may not be installed yet**: 
   - First time running Neovim triggers auto-install via Lazy.nvim
   - This can take several minutes depending on network speed

2. **Manual plugin installation**:
   ```bash
   docker exec -it ide-devbox bash
   nvim --headless -c 'Lazy sync' -c 'qa'
   ```
   This runs plugin installation in headless mode.

3. **Check plugin installation status**:
   ```bash
   docker exec -it ide-devbox ls -la /home/devuser/.local/share/nvim/lazy/
   ```
   Should show directories for nvim-treesitter, nvim-lspconfig, etc.

4. **Check logs for errors**:
   - In Neovim: `:Lazy log` to see plugin manager logs
   - `:messages` to see recent error messages

5. **Common issues**:
   - Network connectivity (GitHub access for cloning repos)
   - Disk space for plugin installation
   - Permission issues in plugin directory (fixed in entrypoint)

#### OpenCode/Claude Code authentication issues
1. Ensure host directories exist: `mkdir -p ~/.anthropic ~/.opencode`
2. Check write permissions on host directories

## Security Notes

- **Non-root user**: Container runs as `devuser` with passwordless sudo
- **Network security**: Access via host SSH (Tailscale can be installed on host)
- **Credential storage**: API keys in `.env` file (never committed)
- **Volume mounts**: Sensitive data stored on host, not in container

## Customization

### Adding Tools
Edit `Dockerfile` and add packages:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here
```

### Changing Python Version
Ubuntu 24.04 includes Python 3.12. To change:
1. Modify `Dockerfile` Python installation
2. Update LSP server configurations

### Disabling OpenVSCode Server
Comment out lines 43-48 in `Dockerfile`:
```dockerfile
# RUN wget https://github.com/gitpod-io/openvscode-server/releases/download/...
```

## License

MIT

## Support

For issues and questions:
1. Check troubleshooting section
2. Review Docker logs: `docker compose logs`
3. Check container health: `docker compose ps`