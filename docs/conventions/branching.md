# Conventional Branch Specification

A standardized naming convention for Git branches adapted from [conventionalbranch.org](https://conventionalbranch.org/), customized for this repository.

## Summary

Branch names follow a structured, human- and machine-readable format to improve clarity, searchability, and CI/CD automation:

```
<type>/<description>
```

Trunk branches (`main`, `master`, `develop`) do not use a prefix.

---

## Prefixes (`<type>/`)

Short prefix forms are **preferred** for conciseness, but standard long forms are permitted. All AI-assisted or agent-generated branches must use the vendor-neutral `ai/` prefix without splitting by agent vendor.

| Preferred (Short) | Permitted (Long) | Category | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `feat/` | `feature/` | Purpose | New feature or functionality | `feat/virtual-text-preview` |
| `fix/` | `bugfix/`, `hotfix/` | Purpose | Bug fix | `fix/clipboard-osc52-sync` |
| `refac/` | `refactor/` | Purpose | Code refactoring without behavioral changes | `refac/modernize-vim-fs` |
| `ci/` | `cicd/` | Purpose | Continuous Integration and Deployment changes | `ci/split-workflow-files` |
| `tests/` | `test/` | Purpose | Test-specific additions or fixes | `tests/add-mock-fixtures` |
| `chore/` | — | Purpose | Maintenance, dependency updates, or docs | `chore/update-readme` |
| `release/` | — | Purpose | Release preparation branch | `release/v0.3.0` |
| `ai/` | — | Source | All AI-assisted or agentic workflows (no vendor split) | `ai/generated-documentation` |

### Special Notes on Types
- **Short Prefixes Preferred**: Prefer `feat/`, `fix/`, `refac/`, and `ci/`, but standard long forms (`feature/`, `bugfix/`, `refactor/`, `cicd/`) are fully accepted.
- **Single AI Prefix**: All AI-assisted work uses `ai/` (do not split by `claude/`, `copilot/`, `cursor/`, etc.).

---

## Basic Rules

1. **Lowercase Alphanumerics, Hyphens, and Dots**:
   Always use lowercase letters (`a-z`), numbers (`0-9`), and hyphens (`-`) to separate words. Avoid uppercase characters, underscores (`_`), or spaces. For release branches, dots (`.`) may be used in the description to represent semantic version numbers (e.g. `release/v1.2.0`).
2. **No Consecutive, Leading, or Trailing Hyphens or Dots**:
   Hyphens and dots must not appear consecutively (e.g. `feat/new--login`, `release/v1.-2.0`), nor at the start or end of the description (e.g. `feat/-new-login`, `release/v1.2.0.`).
3. **Clear and Concise (Present Tense / Imperative Mood)**:
   Branch descriptions should be descriptive yet concise, written in the **present tense** (imperative mood): use `fix` (not `fixed`), `add` (not `added`), `remove` (not `removed`), or `update` (not `updated`).
4. **Issue / Ticket Numbers**:
   When referencing an issue or ticket, prefix the description with the issue number or identifier (e.g. `feat/12-add-cache` or `fix/issue-45-null-deref`).

---

## Formal Grammar

The Augmented Backus-Naur Form (ABNF) grammar defining this repository's branch conventions:

```abnf
branch-name     = trunk-branch / prefixed-branch
trunk-branch    = "main" / "master" / "develop"
prefixed-branch = type "/" description
type            = "feat" / "feature" / "fix" / "bugfix" / "hotfix" / "refac" / "refactor" / "ci" / "cicd" / "test" / "tests" / "chore" / "release" / "ai"
description     = desc-segment *("-" desc-segment)
desc-segment    = 1*(ALPHA / DIGIT) *("." 1*(ALPHA / DIGIT))
ALPHA           = %x61-7A ; lowercase a-z
DIGIT           = %x30-39 ; 0-9
```

*Note: Consecutive hyphens or dots, as well as hyphens or dots at the start or end of the description segment, are invalid.*

---

## Examples

### Valid Branches
- `main`
- `develop`
- `feat/add-statusline-component`
- `feat/3-json-modernization`
- `fix/osc52-escape-sequence`
- `refac/use-vim-system`
- `release/v1.0.0`
- `chore/stylua-format`
- `cicd/archlinux-pipeline`
- `tests/unit-api-coverage`
- `ai/replace-curl-with-vim-net`

### Invalid Branches
| Branch Name | Reason Invalid |
| :--- | :--- |
| `claude/issue-5` / `cursor/issue-5` | AI branches must use `ai/`, not specific agent names |
| `feat/added-statusline` / `fix/fixed-bug` | Uses past tense instead of present tense (`add-statusline`, `fix-bug`) |
| `unknown/task-name` | Unrecognized prefix type |
| `Feat/Add-Statusline` | Contains uppercase letters |
| `fix/header_bug` | Uses underscores instead of hyphens |
| `fix/header bug` | Contains spaces |
| `feat/new--login` | Contains consecutive hyphens |
| `feat/-new-login` | Leading hyphen in description |
| `release/v1.-2.0` | Leading hyphen in version segment |

---

## Tooling & Enforcement

- **CI Enforcement**: Strictly enforced via the `branch-lint` job in GitHub Actions ([`.github/workflows/git-conventions.yml`](file:///.github/workflows/git-conventions.yml)). Pull requests from branches violating this convention will fail CI and be blocked from merging.
- **Agent Directives**: AI agents working in this repository must align strictly with these branch naming guidelines.
