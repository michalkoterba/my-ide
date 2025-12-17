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

## Troubleshooting

### Common Issues

#### "Permission denied" on mounted volumes
```bash
# Fix permissions on host
sudo chown -R $USER:$USER ./workspace ./config
```



#### LSP servers not installing
1. Enter container: `docker exec -it ide-devbox bash`
2. Run Neovim: `nvim`
3. Check Mason: `:Mason`
4. Install manually: `:MasonInstall pyright ruff debugpy`

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