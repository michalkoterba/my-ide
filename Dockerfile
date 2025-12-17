# Docker IDE for ARM64 (Oracle Cloud)
# Based on Ubuntu 24.04 with Neovim, Python 3.12, AI assistants, and modern tooling

# Use Ubuntu 24.04 as base (ARM64 compatible)
FROM ubuntu:24.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system dependencies
# build-essential: needed for Treesitter compilation (gcc)
# ripgrep, fd-find: required by Telescope plugin
# python3.12: default Python version in Ubuntu 24.04
RUN apt-get update && apt-get install -y \
    curl wget git unzip build-essential \
    ripgrep fd-find \
    python3 python3-pip python3-venv python3.12 python3.12-venv python3.12-dev \
    software-properties-common \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js 20 (required for Claude Code, LSP servers, OpenCode)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# 3. Install Neovim (ARM64 binary - Oracle Cloud compatible)
# Download latest stable version (v0.10+ required for modern configs)
RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-arm64.tar.gz && \
    tar xzvf nvim-linux-arm64.tar.gz && \
    mv nvim-linux-arm64 /opt/nvim && \
    ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux-arm64.tar.gz

# 4. Install uv (modern Python package manager)
# Install via pip for reliable availability in PATH
RUN pip3 install uv

# 5. Install Python LSP tools
# pyright via npm (official Microsoft Python language server)
# ruff, debugpy, mypy via uv pip (fast package manager)
RUN npm install -g pyright && \
    uv pip install ruff debugpy mypy black isort

# 6. Install Claude Code (Anthropic's coding assistant)
RUN npm install -g @anthropic-ai/claude-code

# 7. Install OpenCode (AI coding agent)
RUN curl -fsSL https://opencode.ai/install | bash

# 8. Install OpenVSCode Server (optional web-based VS Code, ARM64)
# Comment out if not needed (saves ~200MB)
RUN wget https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v1.96.0/openvscode-server-v1.96.0-linux-arm64.tar.gz && \
    tar -xzf openvscode-server-v1.96.0-linux-arm64.tar.gz && \
    mv openvscode-server-v1.96.0-linux-arm64 /opt/openvscode-server && \
    rm openvscode-server-v1.96.0-linux-arm64.tar.gz

# 9. Clone kickstart.nvim for initial Neovim configuration
RUN git clone https://github.com/nvim-lua/kickstart.nvim /tmp/kickstart.nvim

# 10. Create non-root user with passwordless sudo
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER devuser
WORKDIR /home/devuser/workspace

# PATH already includes /usr/local/bin where uv is symlinked
# Additional cargo binaries can be added in entrypoint.sh

# Default command - keeps container running
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]