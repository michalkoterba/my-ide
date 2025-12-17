#!/bin/bash
set -e

# Add user's cargo bin to PATH if exists (for future cargo installations)
if [ -d "/home/devuser/.cargo/bin" ]; then
    export PATH="/home/devuser/.cargo/bin:${PATH}"
fi

# Add user's local bin to PATH (for pipx and other user-installed tools)
if [ -d "/home/devuser/.local/bin" ]; then
    export PATH="/home/devuser/.local/bin:${PATH}"
fi

# Set up Neovim configuration if not present
NVIM_CONFIG_DIR="/home/devuser/.config/nvim"
KICKSTART_SOURCE="/tmp/kickstart.nvim"

if [ ! -f "${NVIM_CONFIG_DIR}/init.lua" ]; then
    echo "Setting up Neovim configuration from kickstart.nvim..."
    
    # Create config directory
    mkdir -p "${NVIM_CONFIG_DIR}"
    
    # Copy kickstart.nvim files
    cp -r "${KICKSTART_SOURCE}"/* "${NVIM_CONFIG_DIR}"/
    
    # Create lua/custom directory for user extensions
    mkdir -p "${NVIM_CONFIG_DIR}/lua/custom"
    
    # Create custom Python LSP configuration
    cat > "${NVIM_CONFIG_DIR}/lua/custom/python.lua" << 'EOF'
-- Python LSP configuration for Docker IDE
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
        "ruff",
        "debugpy",
        "black",
        "mypy",
      },
    },
  },
}
EOF
    
    # Uncomment the custom plugins import in init.lua
    sed -i "s/-- { import = 'custom.plugins' }/{ import = 'custom.plugins' }/" "${NVIM_CONFIG_DIR}/init.lua"
    
    # Create custom/plugins/init.lua to load our python config
    mkdir -p "${NVIM_CONFIG_DIR}/lua/custom/plugins"
    cat > "${NVIM_CONFIG_DIR}/lua/custom/plugins/init.lua" << 'EOF'
return {
  require("custom.python"),
}
EOF
    
    echo "Neovim configuration set up with Python LSP support"
else
    echo "Neovim configuration already exists, skipping setup"
fi

# Fix permissions on workspace directory
if [ -d "/home/devuser/workspace" ]; then
    sudo chown -R devuser:devuser /home/devuser/workspace 2>/dev/null || true
fi

# Fix permissions on config directory
if [ -d "${NVIM_CONFIG_DIR}" ]; then
    sudo chown -R devuser:devuser "${NVIM_CONFIG_DIR}" 2>/dev/null || true
fi

echo "Docker IDE environment ready"
echo "Tools available:"
echo "  nvim         - Neovim with kickstart.nvim configuration"
echo "  opencode     - AI coding agent (run 'opencode' to start)"
echo "  claude-code  - Anthropic's coding assistant"
echo "  uv           - Modern Python package manager"
echo "  python3.12   - Python interpreter"

# Execute the passed command
exec "$@"