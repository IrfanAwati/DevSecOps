# Kubernetes Dummy Manifests for Checkov Scanning

This folder contains sample Kubernetes manifests designed to demonstrate Checkov scanning for container and orchestration security best practices.

## Files included

- `deployment.yaml`: Complete Kubernetes deployment with Pod, Service, ServiceAccount, RBAC, and NetworkPolicy
- `psp.yaml`: Pod Security Policy defining security constraints

## Security features demonstrated

### Deployment (`deployment.yaml`)

✅ **Security Context**
- Non-root user (`runAsUser: 1000`)
- Read-only root filesystem
- No privilege escalation
- Dropped all capabilities

✅ **Resource Limits**
- CPU and memory requests/limits
- Prevents resource exhaustion

✅ **Health Checks**
- Liveness probe (restart failed containers)
- Readiness probe (route traffic appropriately)

✅ **RBAC**
- Service Account with minimal permissions
- Role with specific API groups and verbs
- RoleBinding for least privilege

✅ **Network Policy**
- Ingress rules (restrict incoming traffic)
- Egress rules (restrict outgoing traffic)
- Namespace and port restrictions

✅ **Pod Anti-Affinity**
- Spreads replicas across nodes
- Improves availability

### Pod Security Policy (`psp.yaml`)

✅ Enforces non-root execution
✅ Prevents privilege escalation
✅ Restricts capabilities
✅ Enforces SELinux context
✅ Requires fsGroup
✅ Restricts volume types

## How to scan locally

```bash
# Scan Kubernetes manifests
checkov -d . --framework kubernetes --output cli --output-file-path checkov-k8s-report.json

# Scan specific file
checkov -f deployment.yaml --framework kubernetes

# Output to SARIF
checkov -d . --framework kubernetes --output sarif --output-file-path checkov-k8s-report.sarif
```

## GitHub Workflow

The `kubernetes-checkov.yml` workflow:
1. Runs on push/PR to `main` when `checkov/kubernetes-dummy/**` changes
2. Scans all YAML files with Checkov
3. Uploads SARIF for GitHub security scanning
4. Stores artifact for review

## Fixing Checkov findings

Refer to `../NOTES.md` under the "Kubernetes Examples" section for common Checkov rules and how to fix them.

### Common checks

- `CKV_K8S_8`: Liveness probe not set
- `CKV_K8S_9`: Readiness probe not set
- `CKV_K8S_20`: Containers should run as non-root
- `CKV_K8S_21`: CPU limits should be set
- `CKV_K8S_6`: PodSecurityPolicy not defined

## Next steps

- Apply these manifests to your cluster: `kubectl apply -f .`
- Monitor in GitHub Security > Code scanning
- Customize based on your app requirements
- Add more manifests (StatefulSet, DaemonSet, ConfigMap, Secret, etc.)

## Resources

- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [OWASP Kubernetes Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)
- [Checkov Kubernetes Checks](https://www.checkov.io/)
