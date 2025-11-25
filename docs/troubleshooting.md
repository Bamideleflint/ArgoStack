# Troubleshooting Guide

This guide documents common errors encountered during setup and their solutions.

## Table of Contents

1. [Cluster Setup Issues](#cluster-setup-issues)
2. [GitHub Actions / CI/CD Issues](#github-actions--cicd-issues)
3. [ArgoCD Issues](#argocd-issues)
4. [Monitoring Stack Issues](#monitoring-stack-issues)
5. [Application Deployment Issues](#application-deployment-issues)
6. [Networking Issues](#networking-issues)

---

## Cluster Setup Issues

### Error: Minikube won't start

**Symptoms:**
```bash
minikube start
❌ Exiting due to HOST_JUJU_LOCK_PERMISSION: Failed to save config: writing lockfile: unable to get lock
```

**Root Cause**: Conflicting minikube instances or corrupted state

**Solution:**
```bash
# Delete all minikube data
minikube delete --all --purge

# Start fresh
minikube start --driver=docker --cpus=4 --memory=8192 --force --delete-on-failure

# Verify
kubectl cluster-info
```

---

### Error: Pods stuck in ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods -n dev
NAME                         READY   STATUS             RESTARTS   AGE
sample-app-xxx-yyy          0/1     ImagePullBackOff   0          2m
```

**Root Cause**: Missing imagePullSecret for private registry (GHCR)

**Solution:**
```bash
# Create secret in the namespace
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_PAT \
  -n dev

# Repeat for other namespaces
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_PAT \
  -n staging

kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_PAT \
  -n production

# Note: Current image is at ghcr.io/bamideleflint/argostack-sample-app
```

---

### Error: Helm timeout during monitoring stack installation

**Symptoms:**
```bash
Error: timed out waiting for the condition
```

**Root Cause**: Insufficient cluster resources or slow image pulls

**Solution:**
```bash
# Increase cluster resources
minikube stop
minikube delete
minikube start --driver=docker --cpus=4 --memory=8192

# Use longer timeout
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --timeout 20m \
  --wait
```

---

### Error: GitHub Actions can't push to GHCR (permission_denied: write_package)

**Symptoms:**
```
ERROR: failed to push ghcr.io/bamideleflint/argostack-sample-app:main: 
denied: permission_denied: write_package
```

**Root Cause**: GitHub Actions workflow doesn't have write permissions for packages

**Solution:**

1. **Update Repository Settings:**
   - Go to: `https://github.com/YOUR_USERNAME/ArgoStack/settings/actions`
   - Scroll to "Workflow permissions"
   - Select: ✅ **"Read and write permissions"**
   - Check: ✅ **"Allow GitHub Actions to create and approve pull requests"**
   - Click **Save**

2. **Verify Workflow Permissions:**
   ```yaml
   # In .github/workflows/ci.yml
   build-and-push:
     permissions:
       contents: write
       packages: write
       id-token: write
   ```

3. **Re-run Failed Workflow:**
   - Go to Actions tab in GitHub
   - Click on the failed workflow run
   - Click "Re-run all jobs"

**Note**: The image name should be `ghcr.io/bamideleflint/argostack-sample-app` (not nested like `bamideleflint/argostack/sample-app`)

---

## GitHub Actions / CI/CD Issues

### Error: kubeval failed with exit code 1

**Symptoms:**
```
ERR  - k8s/base/servicemonitor.yml: Failed initializing schema
Error: The process '/usr/bin/kubeval' failed with exit code 1
```

**Root Cause**: kubeval doesn't recognize CRDs (ServiceMonitor is from Prometheus Operator)

**Solution**: Use kubectl dry-run validation instead (already fixed in workflow)

```yaml
# In .github/workflows/ci.yml
- name: Validate Kubernetes manifests
  run: |
    kubectl apply --dry-run=client -f k8s/base/deployment.yml
    kubectl apply --dry-run=client -f k8s/base/service.yml
```

---

### Error: Kustomize commonLabels deprecated warning

**Symptoms:**
```
Warning: 'commonLabels' is deprecated. Please use 'labels' instead.
```

**Root Cause**: Using deprecated Kustomize field

**Solution**: Update kustomization.yml files

```yaml
# OLD (deprecated)
commonLabels:
  app.kubernetes.io/managed-by: argocd

# NEW (correct)
labels:
  - pairs:
      app.kubernetes.io/managed-by: argocd
```

---

### Error: GitHub Actions can't find networkpolicy.yml

**Symptoms:**
```
ERR  - Could not open file k8s/base/networkpolicy.yml
```

**Root Cause**: File not committed to repository

**Solution:**
```bash
cd ~/Argo-Project/ArgoStack

# Add and commit missing files
git add k8s/base/networkpolicy.yml k8s/base/poddisruptionbudget.yml
git commit -m "Add missing security manifests"
git push origin main
```

---

## ArgoCD Issues

### Error: ArgoCD application OutOfSync

**Symptoms:**
```bash
kubectl get applications -n argocd
NAME                 SYNC STATUS   HEALTH STATUS
sample-app-dev       OutOfSync     Progressing
```

**Root Cause**: Manifest changes not yet synced or auto-sync disabled

**Solution:**
```bash
# Manual sync
argocd app sync sample-app-dev

# Or enable auto-sync
kubectl patch application sample-app-dev -n argocd \
  --type merge \
  --patch '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

---

### Error: ArgoCD server connection refused

**Symptoms:**
```bash
argocd login localhost:8080
FATA[0000] Failed to establish connection: connection refused
```

**Root Cause**: Port-forward not running

**Solution:**
```bash
# Start port-forward in background
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

# Wait a moment
sleep 3

# Get password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure
```

---

## Monitoring Stack Issues

### Error: Grafana dashboards not showing

**Symptoms**: Dashboards created but not visible in Grafana UI

**Root Cause**: Dashboard ConfigMaps not labeled correctly or Grafana not restarted

**Solution:**
```bash
# Deploy dashboards with script
bash scripts/deploy-dashboards.sh

# Restart Grafana
kubectl rollout restart deployment prometheus-grafana -n monitoring

# Wait for ready
kubectl wait --for=condition=available --timeout=120s deployment/prometheus-grafana -n monitoring
```

---

### Error: Prometheus not scraping sample-app metrics

**Symptoms**: No data in Grafana for sample-app metrics

**Root Cause**: ServiceMonitor not created or namespace label missing

**Solution:**
```bash
# Check ServiceMonitor exists
kubectl get servicemonitor -n dev

# Label namespace for Prometheus
kubectl label namespace dev prometheus=enabled

# Restart Prometheus to pick up changes
kubectl delete pod -n monitoring -l app.kubernetes.io/name=prometheus
```

---

### Error: Alert rules not firing

**Symptoms**: Conditions met but no alerts in Alertmanager

**Root Cause**: Alert rules not loaded or query errors

**Solution:**
```bash
# Check Prometheus rules
kubectl get prometheusrule -n monitoring

# View Prometheus UI to check rules status
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Visit http://localhost:9090/rules
# Look for errors in rule evaluation
```

---

## Application Deployment Issues

### Error: Rollout stuck in Progressing

**Symptoms:**
```bash
kubectl get rollout -n staging
NAME         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
sample-app   3         3         1            2           10m
```

**Root Cause**: Canary analysis failing or pods not ready

**Solution:**
```bash
# Check rollout details
kubectl describe rollout sample-app -n staging

# Check analysis runs
kubectl get analysisrun -n staging

# Check pod status
kubectl get pods -n staging

# If stuck, abort and restart
kubectl argo rollouts abort sample-app -n staging
kubectl argo rollouts promote sample-app -n staging
```

---

### Error: Service label mismatch in Rollout

**Symptoms:**
```
Service "sample-app" has unmatch label "app.kubernetes.io/managed-by"
```

**Root Cause**: Rollout template missing required labels

**Solution**: Add label to rollout template

```yaml
# In rollout.yml
spec:
  template:
    metadata:
      labels:
        app: sample-app
        app.kubernetes.io/managed-by: argocd  # Add this
```

---

## Networking Issues

### Error: Cannot access services via port-forward

**Symptoms:**
```bash
kubectl port-forward -n dev svc/sample-app 8080:80
error: lost connection to pod
```

**Root Cause**: Service port mismatch or pods not ready

**Solution:**
```bash
# Check service configuration
kubectl get svc -n dev sample-app -o yaml

# Check target port
kubectl get svc -n dev sample-app -o jsonpath='{.spec.ports[0].targetPort}'

# Check pod readiness
kubectl get pods -n dev -l app=sample-app

# Use correct ports
kubectl port-forward -n dev svc/sample-app 8080:80
```

---

### Error: NetworkPolicy blocking connections

**Symptoms**: Can't access pods even though they're running

**Root Cause**: Too restrictive NetworkPolicy

**Solution**: Update NetworkPolicy to allow required traffic

```yaml
# In networkpolicy.yml - allow from monitoring
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        name: monitoring  # Must match actual namespace label
```

---

## Load Testing Issues

### Error: K6 test file not found

**Symptoms:**
```bash
bash run-load-test.sh baseline k8s dev
Test file not found: /path/to/baseline-test.js
```

**Root Cause**: Script looking in wrong directory

**Solution**: Test files are in k6 subdirectory (already fixed)

```bash
# Ensure you're in the right directory
cd ~/Argo-Project/ArgoStack/load-testing

# Run test
bash run-load-test.sh baseline k8s dev
```

---

## Quick Diagnostic Commands

### Check overall cluster health
```bash
kubectl get nodes
kubectl get pods --all-namespaces
kubectl top nodes
kubectl top pods --all-namespaces
```

### Check ArgoCD applications
```bash
kubectl get applications -n argocd
argocd app list
argocd app get sample-app-dev
```

### Check monitoring stack
```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get prometheusrule -n monitoring
```

### Check application status
```bash
kubectl get rollout -n dev
kubectl get pods -n dev
kubectl logs -n dev -l app=sample-app
```

### View events
```bash
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
kubectl get events -n dev --sort-by='.lastTimestamp'
```

---

## Getting Help

If you encounter an issue not covered here:

1. Check pod logs: `kubectl logs <pod-name> -n <namespace>`
2. Describe resources: `kubectl describe <resource> <name> -n <namespace>`
3. Check events: `kubectl get events -n <namespace>`
4. View documentation: [docs/complete-documentation.md](complete-documentation.md)
5. Open an issue on GitHub with error details

---

**Last Updated**: November 2025
