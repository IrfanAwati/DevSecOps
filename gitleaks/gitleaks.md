# Gitleaks Workflow Documentation

This document explains the Gitleaks configuration used in this repository. The actual workflow file is located at `.github/workflows/gitleaks.yml`.

## What is Gitleaks?

Gitleaks is an open-source secret scanning tool that detects secrets, API keys, credentials, and other sensitive data in Git repositories. It can scan both commits and repository content to help prevent leaks before code is merged.

- Official project: https://github.com/gitleaks/gitleaks
- GitHub Action: https://github.com/gitleaks/gitleaks-action

## Purpose of this workflow

The workflow runs Gitleaks security scans on the repository to catch secrets and sensitive data automatically.
It is configured to run on:

- pull requests targeting `main`
- pushes to the `main` branch
- manual workflow dispatch

This helps ensure that code is scanned at important gate checkpoints and that findings are easy to review.

## Workflow triggers

```yaml
on:
  pull_request:
    branches: [ main ]
    types: [ opened, reopened, synchronize ]
  push:
    branches: [ main ]
  workflow_dispatch:
```

Explanation:

- `pull_request`: runs the scan when a PR is opened, reopened, or updated (`synchronize`) against `main`.
- `push`: runs on every push to the `main` branch.
- `workflow_dispatch`: allows manual execution from the Actions tab.

## Job definition

```yaml
jobs:
  gitleaks-scan:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      actions: read
```

Explanation:

- `gitleaks-scan`: the job name for the secret scanning workflow.
- `runs-on: ubuntu-latest`: uses a standard Ubuntu environment provided by GitHub Actions.
- `permissions`: limits the job permissions to only what it needs.
  - `contents: read`: allows read access to repository contents.
  - `actions: read`: allows read access to GitHub Actions metadata.

## Steps explained

### 1. Checkout repository

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
  with:
    fetch-depth: 1 # Setting it to '0' will allow full history, gitleaks inspect historical commits too
```

Explanation:

- `actions/checkout@v4` checks out the repository into the workflow runner.
- `fetch-depth: 1` fetches only the latest commit.
- If you want Gitleaks to scan the full commit history, change this to `0`.

Note: `fetch-depth: 1` is faster and sufficient for scanning the current tree, but it will not catch secrets in older commits.

### 2. Set up Gitleaks

```yaml
- name: Set up Gitleaks
  uses: gitleaks/gitleaks-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }} # Required for organization-owned repos
    GITLEAKS_ENABLE_UPLOAD_ARTIFACT: true # Uploads results.sarif as a workflow artifact
    GITLEAKS_ENABLE_SUMMARY: true # Adds a report summary to the job page
    GITLEAKS_NOTIFY_USER_LIST : '@awatiirf' # Comma-separated list of GitHub usernames to notify on findings
```

Explanation:

- `gitleaks/gitleaks-action@v2`: uses the official Gitleaks GitHub Action.
- `GITHUB_TOKEN`: required by GitHub Actions for authentication and reporting.
- `GITLEAKS_LICENSE`: a license key used for organization-owned repositories.
  - This is stored in GitHub Secrets and should never be committed to source control.
- `GITLEAKS_ENABLE_UPLOAD_ARTIFACT: true`: uploads a `results.sarif` artifact to the workflow run.
  - This is useful for later review and integration with tools that support SARIF reports.
- `GITLEAKS_ENABLE_SUMMARY: true`: adds a summary of findings directly to the workflow run page.
- `GITLEAKS_NOTIFY_USER_LIST: '@awatiirf'`: notifies the listed GitHub usernames when findings are detected.
  - This should be a comma-separated list if you want to notify multiple people.

> Important: the `GITLEAKS_NOTIFY_USER_LIST` value must be carefully managed. If you add multiple users, separate them with commas.

## Things to know and improvement suggestions

### Secret scanning scope

- This workflow scans the checked-out repository content for patterns that look like secrets.
- It does not require a custom `gitleaks.toml` or `gitleaks.yml` config file in the repo unless you want custom rules.
- If you need custom regex rules, allowlist rules, or excluded paths, you can add a configuration file and pass it to the action.

### Recommended enhancements

- Use `fetch-depth: 0` for full history scanning if you want to detect old leaks.
- Add `paths-ignore` or custom config to exclude non-source files if needed.
- Add another user or team to `GITLEAKS_NOTIFY_USER_LIST` for broader coverage.
- Consider scanning branches other than `main` if your workflow requires earlier detection.

### Example of a better notification list

```yaml
GITLEAKS_NOTIFY_USER_LIST: '@awatiirf,@yourteam-member'
```

### When using organization-owned repos

- `GITLEAKS_LICENSE` is required and must be stored as a GitHub Secret.
- If you do not use an organization license, remove or omit this variable.

## Environment variables at a glance

| Variable | Purpose | Notes |
|---|---|---|
| `GITHUB_TOKEN` | Authenticates GitHub Actions and allows the action to report status and artifacts. | Always use the built-in secret. |
| `GITLEAKS_LICENSE` | License key for organization-owned repos or paid Gitleaks offerings. | Store it in GitHub Secrets, never commit it. |
| `GITLEAKS_ENABLE_UPLOAD_ARTIFACT` | Enables upload of `results.sarif` to the workflow run. | `true` uploads SARIF artifacts for later review. |
| `GITLEAKS_ENABLE_SUMMARY` | Enables a workflow run summary of findings. | `true` adds a summary directly to the Actions page. |
| `GITLEAKS_NOTIFY_USER_LIST` | List of GitHub usernames to notify when findings are detected. | Use comma-separated usernames. |

## How to run Gitleaks locally

If you want to test scanning outside GitHub Actions, install Gitleaks locally and run:

```bash
# install gitleaks (example using release binary)
# check https://github.com/gitleaks/gitleaks/releases for latest version
curl -sSfL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_$(uname -s)_$(uname -m).tar.gz | tar xz
./gitleaks detect --source .
```

If you have a configuration file, run:

```bash
./gitleaks detect --source . --config gitleaks/.gitleaks.toml
```

## Sample Gitleaks config

This repository includes a sample configuration file at `gitleaks/.gitleaks.toml`.
The file shows how to add custom rules, exceptions, and ignored paths.

A sample configuration can help when default scanning is too broad or when you need to reduce false positives.

## License key source and safety

- The license key is typically obtained from the official Gitleaks project or the Gitleaks GitHub Action documentation.
- For organization-owned repositories, GitHub Actions may require a valid license key for the action to run successfully.
- The safest way to store it is in GitHub Secrets, which are encrypted at rest and only exposed to workflow runs.
- Do not commit license keys, API keys, or other secrets to source control.

### Where to get the key

- Visit the official Gitleaks repository: https://github.com/gitleaks/gitleaks
- Visit the GitHub Action page: https://github.com/gitleaks/gitleaks-action
- If your organization already uses Gitleaks, ask your security or DevSecOps team for the key.
- If you need a paid license, contact Gitleaks support or the sales team through their official website.

### Why it is safe and easy

- GitHub Secrets are designed for this use case and keep values hidden from logs.
- Once added to repository or organization secrets, the workflow can access the value without exposing it.
- The only action required is to paste the key into GitHub Secrets and reference it in the workflow.

## Why this workflow is useful

- Automates secret detection on PRs and pushes.
- Provides immediate feedback to developers and reviewers.
- Stores scan artifacts and inline summaries for easier triage.
- Helps reduce the risk of accidentally committing API keys, passwords, or tokens.

## References

- Gitleaks main repository: https://github.com/gitleaks/gitleaks
- Gitleaks GitHub Action docs: https://github.com/gitleaks/gitleaks-action
- GitHub Actions checkout action: https://github.com/actions/checkout
- GitHub Actions workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- SARIF reporting: https://docs.github.com/en/code-security/sast/understanding-the-sarif-format

## Notes

- The repository currently relies on the workflow file `.github/workflows/gitleaks.yml`.
- There is no separate `gitleaks.yml` scanner configuration file in this repo at the moment.
- A sample config file is now available at `gitleaks/.gitleaks.toml`.
