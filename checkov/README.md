# Checkov Infrastructure as Code (IaC) Security

[![Checkov Workflow](https://img.shields.io/github/actions/workflow/status/<your-org>/<your-repo>/checkov/checkov.yml?branch=main&label=iac%20scan&logo=checkov)](https://github.com/<your-org>/<your-repo>/actions)
[![Checkov](https://img.shields.io/badge/Checkov-Static%20Scan-blue)](https://www.checkov.io/)
[![License](https://img.shields.io/github/license/<your-org>/<your-repo>?color=blue)](../LICENSE)

## 📌 Overview

Checkov is an open source static analysis tool for Terraform, CloudFormation, Kubernetes, ARM and other infrastructure-as-code templates. It detects misconfigurations, security risks, and compliance issues before deployment.

## 🚀 Why Checkov

- Shift-left security in PRs and CI pipelines.
- Consistent, ruleset-based policy enforcement.
- Supports Terraform, Kubernetes, CloudFormation, and more in one scan.
- SARIF output for GitHub code scanning and audit.

## 🛠️ Repository flow (`checkov/checkov.yml`)

1. Trigger on `push`, `pull_request`, and manual `workflow_dispatch`.
2. Checkout repository code.
3. Install Python and Checkov.
4. Execute scan:
   - `terraform`, `kubernetes`, `cloudformation`
   - output artifact file `checkov-report.json`
5. Upload SARIF and artifact for visibility.
6. (Optional) enforce fail conditions on critical issues.

## 🧰 Quick pipeline usage

```yaml
name: IaC Security Scan
on: [push, pull_request]

jobs:
  checkov:
    uses: <your-org>/<your-repo>/.github/workflows/checkov/checkov.yml@main
```

## 🏁 Local installation and scanning

### Install Checkov

```bash
python -m pip install --upgrade pip
pip install checkov
```

### Scan a directory

```bash
checkov -d ./path/to/your/repo --framework terraform,kubernetes,cloudformation
```

### Scan a single file

```bash
checkov -f ./path/to/file.tf --framework terraform
checkov -f ./path/to/deployment.yaml --framework kubernetes
```

### Run specific frameworks

```bash
checkov -d . --framework terraform
checkov -d . --framework kubernetes
checkov -d . --framework terraform,kubernetes
```

### Output formats

```bash
# CLI and JSON report
checkov -d . --framework terraform,kubernetes --output cli --output-file-path checkov-report.json

# SARIF output for GitHub Code Scanning
checkov -d . --framework terraform,kubernetes --output sarif --output-file-path checkov-report.sarif
```

## 🧑‍🏫 Beginner steps

1. Clone repo:

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd DevSecOps
```

2. Install Checkov.
3. Run full scan:

```bash
checkov -d . --framework terraform,kubernetes....
```

4. Review output and fix failures.

## 📊 Result interpretation

- `PASS`: no issue found for the rule.
- `FAIL`: issue found; fix based on rule description and file/line.
- `SKIP`: rule bypassed by config.
- `ERROR`: scan error; usually syntax/parse issue.

## ⚙️ Common CLI options

- `-d <directory>`: target path.
- `-f <file>`: target file.
- `--framework`: `terraform`, `kubernetes`, `cloudformation`, etc.
- `--output`: `cli`, `json`, `sarif`.
- `--output-file-path`: output artifact path.
- `--soft-fail`: allow execution to continue with issues.
- `--skip-check CKV_*`: skip specific checks (false positives).

## 🔍 Supported IaC types

- Terraform: security controls, access, encryption, resource configuration.
- Kubernetes: pods, services, RBAC, network policy, secrets.
- CloudFormation: AWS best practices and IAM safety.

