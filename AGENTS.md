# Agent Instructions for Docker IDE

## Build/Lint/Test Commands

- **Lint**: `ruff check` (or `ruff check --fix` for auto-fix)
- **Format**: `ruff format` (line length 88)
- **Type check**: `pyright` or `mypy .`
- **Test**: `pytest` (install via `uv pip install pytest`)
- **Single test**: `pytest path/to/test.py::test_function`

## Code Style Guidelines

- Follow **PEP 8**; use `ruff` for linting/formatting
- **Imports**: sorted with isort (via `ruff format`)
- **Type hints**: encouraged; run `pyright` for type checking
- **Error handling**: explicit exceptions; avoid bare `except`
- **Naming**: `snake_case` (functions/variables), `PascalCase` (classes)
- **Docstrings**: use triple quotes; include types and returns

## Environment Notes

- Python 3.12, `uv` for package management
- Pre-installed: ruff, pyright, mypy, black, isort, debugpy
- Neovim config uses ruff_format and pyright LSP
- Workspace mounted at `/home/devuser/workspace`
- **Always run lint and typecheck after making changes**