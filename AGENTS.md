# Agent Guidelines & Project Directives

## CI/CD Environment Directives
- **Runner Standard**: Standardize on GitHub-hosted runners (e.g. `ubuntu-latest`) using official setup actions and native package/release management for speed and reliability.
- **Linters**: Use standard linter actions (e.g. `JohnnyMorganz/stylua-action` for `stylua`).

## Neovim Target Version
- Neovim **0.12+** is the target platform for modernization work.
- Leverage modern Lua APIs introduced or expanded in 0.10 - 0.12:
  - `vim.net.request` for HTTP/networking.
  - `vim.fs` (`ext`, `basename`, `relpath`, `normalize`) for filesystem path operations.
  - `vim.json` (`encode`, `decode`) for JSON operations.
  - `vim.system` for any required external process execution.

## Git Directives
- **Branch Naming**: Strictly follow [`docs/conventions/branching.md`](file:///docs/conventions/branching.md).
  - Prefer short prefix forms (`feat/`, `fix/`, `refac/`, `ci/`), but standard long forms (`feature/`, `bugfix/`, `refactor/`, `cicd/`, `tests/`, `chore/`, `release/`) are permitted.
  - Vendor-neutral AI prefix: All AI-related branches must use `ai/` (never split by vendor like `cursor/` or `claude/`).
  - Branch descriptions must use lowercase alphanumerics, hyphens (`-`), dots (`.` for versions), and present-tense / imperative verbs (e.g. `feat/3-json-modernization`, `fix/osc52-escape`, not `fix/fixed-bug`).
  - Strict blocking enforcement runs in CI (`git-conventions.yml`).
- **Commit Messages**: Strictly adhere to Conventional Commits per [`docs/conventions/commits.md`](file:///docs/conventions/commits.md).
  - Format: `<type>[optional scope]: <description>`
  - Types: `feat`, `fix`, `refactor`, `perf`, `style`, `test`, `docs`, `build`, `ci`, `chore`, `revert`, `ai`.
  - Scopes are strongly recommended (e.g., `feat(gist): ...`, `fix(core): ...`).
  - Description must be in lowercase, present-tense / imperative mood (e.g., `fix`, `add`, `remove`, `update`, never `fixed`, `added`, `updates`), under 72 chars, and without a trailing period.
