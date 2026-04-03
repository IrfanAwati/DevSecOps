# Embold DevSecOps Selfrunner

[![Build Status](https://img.shields.io/github/actions/workflow/status/<your-org>/<your-repo>/embold.yml?branch=main&label=build&logo=github)](https://github.com/<your-org>/<your-repo>/actions)
[![Embold Scan](https://img.shields.io/badge/Embold-verified-brightgreen)](https://www.embold.io/)
[![License](https://img.shields.io/github/license/<your-org>/<your-repo>?color=blue)](LICENSE)

A complete, easy-to-use GitHub repository that wires Embold static analysis into your CI/CD pipeline with an actionable workflow and docs for users.

## � Table of Contents

- [What this repo includes](#-what-this-repo-includes)
- [What it does](#-what-it-does)
- [How the workflow runs](#-how-the-workflow-runs)
- [Setup](#-setup-recommended)
- [Why this is useful](#-why-this-is-useful)
- [How to make your GitHub repo look informative](#-how-to-make-your-github-repo-look-informative)
- [Suggested enhancements](#-suggested-enhancements)
- [Contribution](#-contribution)
- [License](#-license)

## �🚀 What this repo includes

- `embold.yml`: reusable GitHub Actions workflow for Embold scanning (`workflow_call` entrypoint)
- `embol-selfrunner.yml`: record of a runner configuration for Embold scanning
- `README.md`: this user-facing documentation

## 🎯 What it does

This repository demonstrates how to run Embold automated scanning from GitHub workflows.

- Checks for code quality issues and security vulnerabilities using Embold engine
- Uses `embold/github-action-docker` in a self-contained job
- Adds summary and KPI details to `GITHUB_STEP_SUMMARY`
- Fails on quality gate violations

## 🧩 How the workflow runs

1. `workflow_call` receives `embold_repo_id` input + `EMBOLD_API_KEY` secret.
2. A job executes on the specified `runs-on` runner.
3. Source code is checked out with `actions/checkout@v4`.
4. `embold/github-action-docker@v2.0.0` runs scans with `downloadConfig`, `qualityGate`, `snapshotLabel`, etc.
5. `Add Embold quality summary` step calls Embold APIs to fetch quality gate status and KPIs, then reports them in the job summary.
6. `Check Quality Gate Result` step exits with `1` if `qualityGateStatus == FAILED`.

### 🔧 Step-by-step explanation (what each step means)

- `workflow_call` input mapping:
  - `embold_repo_id`: identifies which Embold repository/project to scan.
  - `EMBOLD_API_KEY`: credential required to authenticate API calls.

- `runs-on`: defines the execution environment (self-hosted runner or GitHub-hosted), ensuring dependencies are available.

```yaml
# example workflow runner selection
runs-on: ubuntu-latest  # or self-hosted label
```

- `actions/checkout@v4`: fetches the codebase into the runner workspace so Embold can analyze the latest files.

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

- `embold/github-action-docker@v2.0.0`:
  - `emboldUrl`: Embold server endpoint
  - `emboldToken`: API token for secure access
  - `emboldRepoUid`: target project identifier within Embold
  - `downloadConfig`: pulls project-specific Embold settings
  - `qualityGate`: evaluate and enforce policy thresholds
  - `snapshotLabel`: attach a unique filename/tag for traceability
```yaml

name: Run Embold Scan
id: embold-scan
uses: embold/github-action-docker@v2.0.0
continue-on-error: ${{ fromJSON(varsEMBOLD_CONTINUE_ON_ERROR || 'false') }}
timeout-minutes: 15
env:
    DOTNET_BUNDLE_EXTRACT_BASE_DIR: ${{ runner.temp }}
with:
    emboldUrl: ${{ env.EMBOLD_BASE_URL }}
    emboldToken: ${{ secrets.EMBOLD_API_KEY }}
    emboldRepoUid: ${{ env.EMBOLD_REPO_UID }}
    downloadConfig: true
    qualityGate: true
    verbose: false
    snapshotLabel: ${{ env.EMBOLD_SNAPSHOT_LABEL }}
```

- `Add Embold quality summary to Job Summary`:
  - Reads quality gate details from Embold HTTP APIs
  - Outputs a concise report in GitHub workflow summary
  - Includes metrics (passed/failed, KPIs, and link to full UI report)

```yaml
name: Check Quality Gate Result
if: steps.embold-scan.outputs.qualityGateStatus == 'FAILED'
run: |
    echo "Quality gate failed!"
    exit 1
```

- `Check Quality Gate Result`:
  - If Embold reports failure, this step causes the job to fail
  - Prevents merges when quality standards are not met

- Optional QA: add `actionlint` job to keep workflow syntax valid, and add Cypress-like tests to validate scan success conditions when desired.

## 🛠️ Setup (recommended)

1. Create secrets:
   - `EMBOLD_API_KEY`: Embold API token
2. Configure action variables in repository/organization secrets:
   - `EMBOLD_BASE_URL` (e.g. `https://embold.company.com/`)
   - `EMBOLD_REPO_UID` (Embold project UID)
3. Call this workflow from your repository pipeline:

```yaml
name: Embold CI
on: [push, pull_request]

jobs:
  embold:
    uses: <your-org>/DevSecOps/.github/workflows/embold.yml@main
    with:
      embold_repo_id: ${{ secrets.EMBOLD_REPO_UID }}
    secrets:
      EMBOLD_API_KEY: ${{ secrets.EMBOLD_API_KEY }}
```

## 📌 Why this is useful

- Enables shift-left security by integrating analysis into PR checks.
- Enforces consistent code quality with quality gates.
- Gives teams a single source of truth for Embold policy progress.
- Generates audit-friendly metadata (`GITHUB_STEP_SUMMARY`) and charting KPIs.

## 🔍 How to make your GitHub repo look informative

- Add badges at the top:
  - Embold scan status
  - Build status
  - Code coverage
- Keep this README up to date with usage examples and variable descriptions.
- Add `docs/` with:
  - `architecture.md`
  - `getting-started.md`
  - `contributing.md`
- Include an example `embold-config` snippet and policy notes.

## ✅ Suggested enhancements

- Add `actionlint` for workflow YAML validation.
- Add regeneration script for Embold status badge.
- Add `security` policy document and contributor code-of-conduct.

## 🤝 Contribution

- Fork, branch, PR.
- Update README with meaningful, non-ambiguous instructions.
- Keep pipeline behavior idempotent and test locally with `act` if available.

## 📄 License

Choose license for reuse (MIT, Apache-2.0, etc.).
