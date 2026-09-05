# Conventional Commits Specification

This repository adopts the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification for structuring commit messages. Standardized commit messages provide human- and machine-readable context, streamline release changelogs, and simplify project history navigation.

---

## Commit Message Format

Each commit message consists of a **header**, an optional **body**, and an optional **footer**:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The header line is mandatory and must not exceed 72 characters. The description must be in lowercase (unless referencing proper nouns/constants), written strictly in the **present tense (imperative mood)**:
- Use `fix` (not `fixed` or `fixes`)
- Use `remove` (not `removed` or `removes`)
- Use `add` (not `added` or `adds`)
- Use `update` (not `updated` or `updates`)

Never include a trailing period at the end of the subject line.

---

## Allowed Types

Standard types aligned with Conventional Commits and Angular conventions:

| Type | Intent | Example |
| :--- | :--- | :--- |
| `feat` | Introduces a new feature to the codebase | `feat(osc52): support base64 chunked streaming` |
| `fix` | Patches a bug | `fix(gist): correct JSON response parsing` |
| `refactor` | Code changes that neither fix a bug nor add a feature | `refactor(core): utilize vim.system for execution` |
| `perf` | Code changes that improve performance | `perf(provider): optimize buffer line serialization` |
| `style` | Formatting or white-space changes with no code logic impact | `style: apply stylua format` |
| `test` | Adding missing tests or correcting existing tests | `test(integrations): add mock tests for gist integration` |
| `docs` | Documentation-only changes | `docs(conventions): document commit guidelines` |
| `build` | Changes affecting build systems, packaging, or external dependencies | `build: update package metadata` |
| `ci` | Changes to CI configuration files and scripts | `ci: add informational commit linting job` |
| `chore` | Routine maintenance tasks that do not modify src or test files | `chore: update license year` |
| `revert` | Reverts a previous commit | `revert: feat(osc52): support base64 chunked streaming` |
| `ai` | AI-assisted or agent-generated changes when not mapped to a single type | `ai: overhaul integration interfaces` |

---

## Scope Policy

Scopes are **optional but strongly recommended** to provide immediate modular context on where changes occur.

Recommended repository scopes include:
- `core`: Central engine, dispatcher, and base utilities (`lua/codecopy/init.lua`, etc.)
- `config`: Default configurations and options
- `integrations` / `<integration-name>`: Specific provider integrations (e.g., `gist`, `osc52`, `pastebin`)
- `ui`: Floating windows, notifications, visual prompts
- `ci`: CI/CD workflows and container configurations
- `docs`: Documentation files (`README.md`, `docs/*`)
- `test`: Test configurations, harness, and fixtures

Example:
```
feat(gist): support secret gist creation option
fix(core): handle empty visual selections gracefully
refactor(integrations): simplify payload builder
```

---

## Breaking Changes

Breaking changes can be signaled in two ways:
1. Appending an exclamation mark (`!`) immediately before the colon in the header:
   ```
   feat(core)!: drop Neovim 0.9 compatibility in favor of vim.net.request
   ```
2. Including a `BREAKING CHANGE:` footer with an explanation:
   ```
   refactor(config): rename default provider option

   BREAKING CHANGE: The `default_provider` configuration key is now `provider`.
   ```

---

## Examples

### Simple feature commit
```
feat(osc52): add automatic fallback to system clipboard
```

### Bug fix with scope and body
```
fix(gist): handle rate limiting errors from GitHub API

The API returns HTTP 403 when unauthenticated requests exceed the
rate limit. We now parse the response error body and notify the user.
```

### Breaking change with exclamation mark
```
feat(api)!: require Neovim 0.12+ for modern networking APIs
```

### Maintenance chore without scope
```
chore: bump stylua version to 2.5.2
```

### Invalid / Non-Conforming Commits
| Commit Message | Problem | Correct Form |
| :--- | :--- | :--- |
| `fix(gist): fixed json parse error` | Past tense (`fixed`) | `fix(gist): fix json parse error` |
| `refactor(core): removed deprecated helpers` | Past tense (`removed`) | `refactor(core): remove deprecated helpers` |
| `feat: added osc52 support.` | Past tense (`added`) and trailing period | `feat: add osc52 support` |
| `chore: updates stylua version` | Third person (`updates`) | `chore: update stylua version` |

---

## CI & Informational Enforcement

Commit messages on pull requests are checked in CI as an **informational, non-blocking** step. If a commit does not conform to the conventional commit pattern, the check produces clear summary warnings/notices without failing the build or blocking merges.
