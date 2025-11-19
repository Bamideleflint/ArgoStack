# ArgoStack Troubleshooting Guide

This document contains common issues encountered during setup and deployment, along with their solutions.

---

## Table of Contents

1. [Kubernetes Cluster Issues](#kubernetes-cluster-issues)
2. [Docker and Container Issues](#docker-and-container-issues)
3. [kubectl Configuration Issues](#kubectl-configuration-issues)
4. [Personal Configuration Issues](#personal-configuration-issues)
5. [Installation Script Issues](#installation-script-issues)
6. [Monitoring Stack Issues](#monitoring-stack-issues)
7. [Quick Reference Commands](#quick-reference-commands)

---

## Kubernetes Cluster Issues

### Issue 1: Kind Cluster Creation Fails with Control Plane Timeout

**Error Message:**
```
ERROR: failed to create cluster: failed to init node with kubeadm
couldn't initialize a Kubernetes cluster
error: timed out waiting for the condition
```

**Root Cause:**
- Kind has compatibility issues with WSL2's cgroup configuration
- Port mappings (80, 443) in kind-config.yaml cause conflicts in WSL
- kubeadmConfigPatches can trigger InitConfiguration failures

**Solution:**
1. **Switch to Minikube** (Recommended for WSL):
   ```bash
   # Install minikube
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   rm minikube-linux-amd64
   
   # Delete any existing cluster
   minikube delete --all --purge
   rm -rf ~/.minikube
   
   # Start fresh cluster
   minikube start --driver=docker --force --delete-on-failure
   ```

2. **Alternative: Simplified Kind Config** (If you must use Kind):
   - Remove kubeadmConfigPatches
   - Remove extraPortMappings for ports 80 and 443
   - Use minimal configuration

**Status:** ✅ Resolved by migrating to Minikube

---

### Issue 2: Minikube Fails with "DRV_UNSUPPORTED_OS" Error

**Error Message:**
```
❌  Exiting due to DRV_UNSUPPORTED_OS: The driver 'docker' is not supported on linux/amd64
```

**Root Cause:**
- Corrupted minikube profile from previous failed attempts
- Driver configuration conflict

**Solution:**
```bash
# Complete cleanup
minikube delete --all --purge
rm -rf ~/.minikube

# Start with force flag to bypass validation
minikube start --driver=docker --force --delete-on-failure
```

**Status:** ✅ Resolved

---

### Issue 3: Minikube Certificate Hostname Error

**Error Message:**
```
error: apiServer.certSANs: Invalid value: "": altname is not a valid IP address
❌  Exiting due to K8S_INVALID_CERT_HOSTNAME
```

**Root Cause:**
- Minikube bug with certificate configuration
- Corrupted configuration from previous attempts

**Solution:**
```bash
# Complete purge and fresh start
minikube delete --all --purge
rm -rf ~/.minikube

# Start with explicit settings
minikube start --driver=docker --force --delete-on-failure
```

**Expected Output:**
```
😄  minikube v1.37.0 on Ubuntu 24.04 (amd64)
✨  Using the docker driver based on user configuration
📌  Using Docker driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.48 ...
💾  Downloading Kubernetes v1.34.0 preload ...
🔥  Creating docker container (CPUs=2, Memory=3072MB) ...
🐳  Preparing Kubernetes v1.34.0 on Docker 28.4.0 ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster
```

**Verification:**
```bash
kubectl cluster-info
# Should show: Kubernetes control plane is running at https://127.0.0.1:XXXXX

kubectl get nodes
# Should show: minikube   Ready    control-plane
```

**Related Issue:** https://github.com/kubernetes/minikube/issues/9175

**Status:** ✅ Resolved with complete cleanup

---

## Docker and Container Issues

### Issue 4: Docker Cgroup Driver Compatibility

**Error Message:**
```
Cgroup Driver: cgroupfs
WARNING: Docker is using cgroupfs instead of systemd
```

**Root Cause:**
- Docker Desktop vs Docker Engine difference in WSL
- cgroupfs vs systemd driver mismatch

**Impact:**
- Can cause Kind cluster failures
- Less impactful with Minikube

**Recommendation:**
- Use Docker Engine instead of Docker Desktop for better performance
- Minikube handles this better than Kind

**Status:** ⚠️ Workaround: Use Minikube instead of Kind

---

### Issue 5: Docker Image Registry Path Conflicts

**Error:**
- Multiple inconsistent Docker registry references found:
  - `Bamidele1995/sample-app`
  - `leke1995/sample-app`
  - Missing proper GitHub Container Registry path

**Root Cause:**
- Project copied from another repository
- Personal details not updated

**Solution:**
Updated all image references to use GitHub Container Registry:
```
ghcr.io/bamideleflint/argostack/sample-app:v1.0.0
```

**Files Updated:**
- `k8s/base/deployment.yml`
- `helm-charts/sample-app/values.yml`
- `k8s/overlays/dev/kustomization.yml`
- `k8s/overlays/staging/kustomization.yml`
- `k8s/overlays/prod/kustomization.yml`

**Status:** ✅ Resolved

---

## kubectl Configuration Issues

### Issue 6: kubectl Not Configured - Connection Refused on localhost:8080

**Error Message:**
```
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

**Root Cause:**
- kubectl is not configured to connect to any cluster
- No kubeconfig file or incorrect kubeconfig

**Solution:**
```bash
# For Minikube (automatic configuration)
minikube start --driver=docker --force

# Verify configuration
kubectl cluster-info
kubectl get nodes

# If still not working, manually update context
minikube update-context

# Check kubeconfig
cat ~/.kube/config
```

**For Kind (if using):**
```bash
kind get kubeconfig --name argostack > ~/.kube/config
```

**Status:** ✅ Resolved - Minikube auto-configures kubectl

---

### Issue 7: Minikube Kubeconfig Misconfigured

**Error Message:**
```
kubeconfig: Misconfigured
WARNING: Your kubectl is pointing to stale minikube-vm.
```

**Root Cause:**
- Previous failed minikube installations left stale config
- Cluster exists but not properly registered in kubeconfig

**Solution:**
```bash
# Update kubectl context
minikube update-context

# Or recreate from scratch
minikube delete
minikube start --driver=docker --force
```

**Status:** ✅ Resolved

---

## Personal Configuration Issues

### Issue 8: Incorrect Personal Details in Configuration Files

**Error:**
- ArgoCD project references `https://github.com/your-org/*`
- Helm chart maintainer shows "DevOps Team"
- Mixed Docker usernames

**Root Cause:**
- Project cloned from friend's repository
- Template values not updated

**Solution:**
Updated the following files with personal details:

1. **argocd/projects/project.yml:**
   ```yaml
   sourceRepos:
     - 'https://github.com/Bamideleflint/*'
   ```

2. **helm-charts/sample-app/Chart.yml:**
   ```yaml
   maintainers:
     - name: Bamideleflint
       email: oluwafunsho.osho@gmail.com
   ```

3. **All image references** (see Issue 5)

**Status:** ✅ Resolved

---

## Installation Script Issues

### Issue 9: install-tools.sh Missing Minikube Installation Function

**Error Message:**
```
./scripts/install-tools.sh: line 170: install_minikube: command not found
```

**Root Cause:**
- The `install-tools.sh` script called `install_minikube` function on line 170
- The function definition was missing from the script
- Script also attempted to display minikube version in output

**Solution:**
Added the missing `install_minikube()` function to the script:

```bash
# Install Minikube
install_minikube() {
    echo -e "${BLUE}Installing Minikube...${NC}"
    if command -v minikube &> /dev/null; then
        echo -e "${GREEN}Minikube already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install minikube
        else
            curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
            sudo install minikube-linux-amd64 /usr/local/bin/minikube
            rm minikube-linux-amd64
        fi
        echo -e "${GREEN}Minikube installed successfully${NC}"
    fi
}
```

**Verification:**
```bash
./scripts/install-tools.sh
# Should install all tools including minikube without errors

which minikube
# Should show: /usr/local/bin/minikube
```

**Status:** ✅ Resolved - Function added to install-tools.sh

---

### Issue 10: setup-cluster.sh Incomplete Script

**Error:**
- Script ran without errors but didn't deploy anything
- No monitoring namespace or pods created
- Script only defined functions but never executed them

**Root Cause:**
- Script was missing:
  - Shebang and initialization
  - Color variable definitions
  - Main function to call `install_prometheus()`
  - Execution call to main function

**Solution:**
Completed the script by adding:

1. **Script header:**
```bash
#!/bin/bash
# Setup Kubernetes cluster with ArgoCD and monitoring tools

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
```

2. **Main function and execution:**
```bash
main() {
    install_prometheus
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Cluster setup complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
}

main
```

**Verification:**
```bash
# After running the corrected script
./scripts/setup-cluster.sh

# Check monitoring pods
kubectl get pods -n monitoring
# Should show: prometheus, grafana, alertmanager, kube-state-metrics, node-exporter
```

**Status:** ✅ Resolved - Script now properly deploys monitoring stack

---

## Monitoring Stack Issues

### Issue 11: Minikube API Server Connection Issues During Startup

**Error Message:**
```
E1119 14:49:57.028732 failed to get current CoreDNS ConfigMap
The connection to the server localhost:8443 was refused
Failed to inject host.minikube.internal into CoreDNS
Unable to scale down deployment "coredns"
Enabling 'default-storageclass' returned an error
```

**Root Cause:**
- API server temporarily unavailable during cluster initialization
- Minikube trying to configure addons before API server fully ready
- Previous failed cluster state interfering with new startup

**Solution:**
```bash
# Complete cleanup
minikube delete --all --purge

# Start with delete-on-failure flag
minikube start --driver=docker --cpus=4 --memory=6144 --disk-size=20g --force --delete-on-failure
```

**Expected Outcome:**
- Cluster should eventually start successfully
- Minor errors during startup can be ignored if final status shows "Done!"
- Verify with: `kubectl cluster-info` and `kubectl get nodes`

**Status:** ✅ Resolved - Cluster starts successfully after cleanup

---

### Issue 12: Prometheus Stack Installation Timing and Pod Status

**Symptoms:**
- Helm shows status "failed" but pods are running
- Pods stuck in `ContainerCreating` for several minutes
- Grafana shows `2/3 Running` for extended period
- `kube-state-metrics` in `CrashLoopBackOff`

**Root Cause:**
1. **Helm timeout:** 20-minute timeout can expire while pods are still initializing
2. **Image pulling:** First-time downloads of large images (Grafana, Prometheus) take time
3. **Grafana initialization:** Database migrations and plugin loading delay readiness
4. **API connectivity:** `kube-state-metrics` temporary connection issues to Kubernetes API

**Solution:**
This is expected behavior on first installation. The `|| true` in the setup script prevents script failure:

```bash
helm upgrade --install prometheus ... --timeout 20m --wait || true
```

**Monitoring Progress:**
```bash
# Watch pods status in real-time
kubectl get pods -n monitoring -w

# Check specific pod details
kubectl describe pod <pod-name> -n monitoring

# View container logs
kubectl logs <pod-name> -n monitoring -c <container-name>

# Check which containers are ready
kubectl get pod <pod-name> -n monitoring -o jsonpath='{range .status.containerStatuses[*]}{.name}{"\t"}{.ready}{"\n"}{end}'
```

**Expected Timeline:**
- **0-2 min:** Pods in `Pending` or `ContainerCreating`
- **2-5 min:** Image pulling completes, containers start
- **5-10 min:** Grafana DB migrations, pods become ready
- **10+ min:** All pods running and healthy

**Healthy Status:**
```
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          10m
prometheus-grafana-5789c6dd5c-2km5l                      3/3     Running   0          14m
prometheus-kube-prometheus-operator-787c69dfc5-56jzt     1/1     Running   0          14m
prometheus-kube-state-metrics-6c67d49fc8-hn2bq           1/1     Running   2          14m
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          10m
prometheus-prometheus-node-exporter-chbgg                1/1     Running   0          14m
```

**If pods stay in CrashLoopBackOff:**
```bash
# Check logs for errors
kubectl logs <pod-name> -n monitoring --previous

# Common fix: Increase cluster resources
minikube stop
minikube start --cpus=4 --memory=8192 --driver=docker --force

# Reinstall monitoring stack
./scripts/setup-cluster.sh
```

**Status:** ✅ Expected behavior - Be patient during first installation

---

## Quick Reference Commands

### Cluster Management

```bash
# Install all DevOps tools
./scripts/install-tools.sh

# Start cluster
./scripts/start-cluster.sh

# Setup monitoring and ArgoCD
./scripts/setup-cluster.sh

# Or manually start cluster
minikube start --driver=docker --cpus=4 --memory=6144 --disk-size=20g --force

# Check cluster status
minikube status
kubectl cluster-info

# Stop cluster (preserve state)
minikube stop

# Delete cluster completely
minikube delete
```

### Troubleshooting Commands

```bash
# Check Docker
docker ps
docker info | grep -i 'cgroup\|runtime'

# Check kubectl configuration
kubectl config view
kubectl config current-context

# Check minikube logs
minikube logs

# Verify nodes
kubectl get nodes

# Check all pods
kubectl get pods --all-namespaces

# Check monitoring stack
kubectl get pods -n monitoring
kubectl get pods -n monitoring -w  # watch mode

# Check pod details
kubectl describe pod <pod-name> -n monitoring
kubectl logs <pod-name> -n monitoring

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Then visit: http://localhost:3000 (admin/admin123)
```

### Complete Reset (Nuclear Option)

```bash
# WARNING: This deletes everything!
minikube delete --all --purge
rm -rf ~/.minikube
rm -rf ~/.kube/config

# Start fresh
minikube start --driver=docker --force --delete-on-failure
```

---

## Environment-Specific Notes

### WSL2 (Ubuntu 24.04) Environment

**Confirmed Working Setup:**
- OS: Ubuntu 24.04 on WSL2
- Docker: Running (check with `docker ps`)
- Cluster Tool: Minikube v1.37.0
- Driver: Docker with --force flag
- kubectl: Auto-configured by minikube

**Known Issues:**
- Kind has cgroup v2 compatibility issues → Use Minikube
- Docker Desktop vs Docker Engine → Prefer Docker Engine
- Port 80/443 mappings fail in WSL → Not needed for basic setup

---

## Prevention Checklist

Before starting a new cluster:

- [ ] Verify Docker is running: `docker ps`
- [ ] Clean up old clusters: `minikube delete --all`
- [ ] Verify personal details in configs
- [ ] Use correct image registry paths
- [ ] Use `./scripts/start-cluster.sh` for consistent setup

---

## Getting Help

If you encounter new issues:

1. Check this troubleshooting guide first
2. Run diagnostic commands from Quick Reference section
3. Check official documentation:
   - [Minikube Docs](https://minikube.sigs.k8s.io/docs/)
   - [kubectl Docs](https://kubernetes.io/docs/reference/kubectl/)
4. Check GitHub issues:
   - [Minikube Issues](https://github.com/kubernetes/minikube/issues)

---

**Last Updated:** November 19, 2025 - Full Stack Deployed ✅  
**Maintainer:** Bamideleflint (oluwafunsho.osho@gmail.com)

**Current Status:**
- ✅ Minikube cluster running on Docker driver
- ✅ kubectl configured and connected
- ✅ Kubernetes v1.34.0 operational
- ✅ Prometheus monitoring stack deployed
- ✅ Grafana dashboard accessible
- ✅ All DevOps tools installed (kubectl, helm, minikube, argocd, etc.)
