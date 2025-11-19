# 🚀 Complete DevOps Project - Production Ready

A comprehensive, production-ready DevOps project implementing GitOps, observability, advanced deployment strategies, service mesh, cost optimization, and load testing.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Component Details](#component-details)
- [Deployment Strategies](#deployment-strategies)
- [Monitoring & Observability](#monitoring--observability)
- [Cost Optimization](#cost-optimization)
- [Service Mesh](#service-mesh)
- [Load Testing](#load-testing)
- [Notifications](#notifications)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        GitHub Actions                        │
│  (CI/CD Pipeline, Security Scanning, Notifications)         │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                        │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                     ArgoCD                            │  │
│  │  (GitOps Controller - Automated Deployments)         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Argo Rollouts                        │  │
│  │  (Canary/Blue-Green Deployments)                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │             Service Mesh (Istio/Linkerd)             │  │
│  │  (Traffic Management, Security, Observability)       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Monitoring Stack                             │  │
│  │  Prometheus │ Grafana │ Alertmanager │ Jaeger        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Cost Optimization                            │  │
│  │  Cluster Autoscaler │ VPA │ Karpenter │ Kubecost    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## ✨ Features

### Core Features
- ✅ **GitOps Workflow** - ArgoCD for declarative deployments
- ✅ **CI/CD Pipeline** - GitHub Actions with automated testing
- ✅ **Container Registry** - GitHub Container Registry integration
- ✅ **Multi-Environment** - Dev, Staging, Production

### Deployment Strategies
- ✅ **Canary Deployments** - Progressive traffic shifting
- ✅ **Blue-Green Deployments** - Zero-downtime releases
- ✅ **Automated Rollbacks** - Based on Prometheus metrics
- ✅ **Manual Approval Gates** - For production deployments

### Monitoring & Observability
- ✅ **Metrics Collection** - Prometheus with custom metrics
- ✅ **Visualization** - Grafana dashboards
- ✅ **Distributed Tracing** - Jaeger integration
- ✅ **Log Aggregation** - ELK/Loki stack ready
- ✅ **Alerting** - Alertmanager with multiple channels

### Service Mesh
- ✅ **Traffic Management** - Intelligent routing, load balancing
- ✅ **Security** - mTLS, authorization policies
- ✅ **Resilience** - Circuit breakers, retries, timeouts
- ✅ **Observability** - Service-to-service metrics

### Cost Optimization
- ✅ **Cluster Autoscaler** - Automatic node scaling
- ✅ **VPA** - Right-sizing pod resources
- ✅ **Karpenter** - Advanced autoscaling with spot instances
- ✅ **Resource Quotas** - Namespace-level limits
- ✅ **Cost Monitoring** - Kubecost integration
- ✅ **Descheduler** - Workload optimization

### Notifications
- ✅ **Slack Integration** - Deployment and alert notifications
- ✅ **Discord Integration** - Alternative notification channel
- ✅ **Email Alerts** - Critical alerts via email
- ✅ **PagerDuty** - Incident management integration

### Security
- ✅ **Container Scanning** - Trivy for vulnerabilities
- ✅ **Secret Management** - Sealed Secrets
- ✅ **RBAC** - Role-based access control
- ✅ **Network Policies** - Pod-to-pod communication control
- ✅ **Pod Security Standards** - Restricted profiles

### Load Testing
- ✅ **K6 Integration** - Modern load testing
- ✅ **Multiple Test Types** - Stress, spike, soak tests
- ✅ **Automated Testing** - Via GitHub Actions
- ✅ **Metrics Collection** - InfluxDB + Grafana

## 📦 Prerequisites

- **Kubernetes Cluster** (1.24+)
  - EKS, GKE, AKS, or local (kind, k3s, minikube)
  - Minimum 3 nodes (2 CPU, 4GB RAM each)
- **kubectl** (configured)
- **Helm** 3+
- **Docker** (for building images)
- **Git**

## 🚀 Quick Start

### Step-by-Step Setup Guide

Follow these steps in order for a successful deployment:

### Step 1: Install Required Tools

```bash
./scripts/install-tools.sh
```

This installs all required DevOps tools:
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager
- **Minikube** - Local Kubernetes cluster
- **ArgoCD CLI** - GitOps deployment tool
- **Argo Rollouts plugin** - Advanced deployment strategies
- **k9s** - Terminal UI for Kubernetes
- **Trivy** - Container security scanner
- **kubeval** - Kubernetes manifest validator
- **kustomize** - Kubernetes configuration management
- **kubeseal** - Secret encryption tool

**Verification:**
```bash
# Check installed tools
kubectl version --client
helm version
minikube version
argocd version --client
```

### Step 2: Start Kubernetes Cluster

```bash
./scripts/start-cluster.sh
```

This script:
- Starts a Minikube cluster with Docker driver
- Configures cluster with 4 CPUs, 6GB RAM, 20GB disk
- Sets up kubectl context automatically
- Verifies cluster is ready

**Expected Output:**
```
🏄  Done! kubectl is now configured to use "minikube" cluster
Kubernetes control plane is running at https://127.0.0.1:XXXXX
minikube   Ready    control-plane
```

**Verification:**
```bash
# Check cluster status
minikube status
kubectl cluster-info
kubectl get nodes
```

### Step 3: Deploy Monitoring Stack

```bash
./scripts/setup-cluster.sh
```

This script deploys:
- **Prometheus** - Metrics collection and monitoring
- **Grafana** - Metrics visualization and dashboards
- **Alertmanager** - Alert routing and notifications
- **kube-state-metrics** - Kubernetes cluster metrics
- **node-exporter** - Node-level metrics

**Expected Timeline:**
- 0-2 min: Helm chart installation begins
- 2-5 min: Container images being pulled
- 5-10 min: Pods starting and initializing
- 10+ min: All components ready

**Monitor Progress:**
```bash
# Watch pods coming up
kubectl get pods -n monitoring -w

# Check when all are ready
kubectl get pods -n monitoring
```

**Expected Final Status:**
```
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          10m
prometheus-grafana-xxxxx                                 3/3     Running   0          14m
prometheus-kube-prometheus-operator-xxxxx                1/1     Running   0          14m
prometheus-kube-state-metrics-xxxxx                      1/1     Running   0          14m
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          10m
prometheus-prometheus-node-exporter-xxxxx                1/1     Running   0          14m
```

### Step 4: Configure Secrets (Optional)

If deploying to production with private registries:

```bash
# GitHub Container Registry
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_TOKEN \
  -n production

# Slack/Discord Webhooks (if using notifications)
kubectl create secret generic notification-secrets \
  --from-literal=slack-webhook-url=YOUR_SLACK_WEBHOOK \
  --from-literal=discord-webhook-url=YOUR_DISCORD_WEBHOOK \
  -n argocd
```

### Step 5: Deploy Application (Optional)

If you want to deploy the sample application:

```bash
# Build and push image
docker build -t ghcr.io/your-org/sample-app:latest ./apps/sample-app
docker push ghcr.io/your-org/sample-app:latest

# Deploy to production
kubectl apply -f argocd/applications/sample-app-prod.yml
```

### Step 6: Access Dashboards

**Access Grafana:**
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open browser: http://localhost:3000
# Username: admin
# Password: admin123
```

**Access Prometheus:**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open browser: http://localhost:9090
```

**Access ArgoCD (if deployed):**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open browser: https://localhost:8080
# Username: admin
# Password: [Get from setup output]
```

---

### Quick Start Summary

**Complete setup in 3 commands:**
```bash
# 1. Install tools (~2 minutes)
./scripts/install-tools.sh

# 2. Start cluster (~3-5 minutes)
./scripts/start-cluster.sh

# 3. Deploy monitoring (~10-15 minutes)
./scripts/setup-cluster.sh
```

**Total time:** ~15-20 minutes for complete environment

**Troubleshooting:** See [troubleshooting.md](troubleshooting.md) for common issues

---

## 📁 Project Structure

```
ArgoStack/
├── .github/
│   └── workflows/               # GitHub Actions
│       ├── ci.yml
│       ├── security-scan.yml
│       ├── release.yml
│       └── load-test.yml
├── apps/
│   └── sample-app/              # Application code
│       ├── src/
│       │   └── app.py
│       ├── Dockerfile
│       ├── requirements.txt
│       └── .dockerignore
├── k8s/
│   ├── base/                    # Base Kubernetes manifests
│   │   ├── deployment.yml
│   │   ├── service.yml
│   │   └── servicemonitor.yml
│   └── overlays/                # Environment-specific
│       ├── dev/
│       ├── staging/
│       └── prod/
├── argocd/
│   ├── applications/            # ArgoCD apps
│   │   ├── sample-app-dev.yml
│   │   ├── sample-app-staging.yml
│   │   └── sample-app-prod.yml
│   ├── projects/
│   │   └── project.yml
│   └── notifications/
│       ├── argocd-notifications-cm.yaml
│       └── argocd-notifications-secret.yaml
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus-config.yml
│   │   ├── alerting-rules.yml
│   │   ├── advanced-alerting-rules.yml
│   │   └── cost-alerts.yaml
│   └── grafana/
│       ├── dashboards/
│       │   ├── app-dashboard.json
│       │   ├── istio-dashboard.json
│       │   └── k6-dashboard.json
│       └── grafana-config.yml
├── service-mesh/
│   ├── istio/
│   │   ├── install.sh
│   │   ├── gateway.yaml
│   │   ├── virtual-service.yaml
│   │   └── destination-rule.yaml
│   └── linkerd/
│       ├── install.sh
│       └── service-profile.yaml
├── autoscaling/
│   ├── cluster-autoscaler/
│   │   ├── deployment.yaml
│   │   └── rbac.yaml
│   ├── vpa/
│   │   └── sample-app-vpa.yaml
│   ├── karpenter/
│   │   └── provisioner.yaml
│   ├── priority-classes.yaml
│   ├── resource-quotas/
│   └── descheduler/
├── load-testing/
│   ├── k6/
│   │   ├── basic-load-test.js
│   │   ├── stress-test.js
│   │   ├── spike-test.js
│   │   └── soak-test.js
│   ├── artillery/
│   └── locust/

├── scripts/\
│   ├── install-tools.sh\
│   ├── setup-cluster.sh\
│   ├── start-cluster.sh\
│   ├── backup-etcd.sh\
│   └── generate-docs.sh
└── docs/
    └── complete-documentation.md
```

## 🎯 Component Details

### ArgoCD

Access ArgoCD UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# URL: https://localhost:8080
# Username: admin
# Password: [shown in output]
```

Sync applications:
```bash
argocd app sync sample-app-prod
argocd app sync --all
```

### Prometheus

Access Prometheus:
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# URL: http://localhost:9090
```

Query metrics:
```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### Grafana

Access Grafana:
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# URL: http://localhost:3000
# Username: admin
# Password: admin123
```

Import dashboards:
- Application Metrics
- Istio Service Mesh
- K6 Load Testing
- Cost Analysis

## 🎨 Deployment Strategies

### Canary Deployment

```bash
# Deploy with canary
kubectl apply -f argocd/applications/sample-app-prod-with-notifications.yaml

# Watch progress
kubectl argo rollouts get rollout sample-app -n production

# Promote canary
kubectl argo rollouts promote sample-app -n production

# Abort rollout
kubectl argo rollouts abort sample-app -n production
```

Traffic split progression:
1. 20% canary, 80% stable (2 min)
2. 40% canary, 60% stable (2 min)
3. 60% canary, 40% stable (2 min)
4. 80% canary, 20% stable (2 min)
5. 100% canary (manual promotion)

### Blue-Green Deployment

```bash
# Deploy blue-green (requires additional configuration)
kubectl apply -f k8s/rollouts/bluegreen/rollout.yaml

# Preview new version
kubectl port-forward svc/sample-app-preview -n production 8081:80

# Promote to production
kubectl argo rollouts promote sample-app-bluegreen -n production
```

## 📊 Monitoring & Observability

### Custom Metrics

The application exposes the following metrics:

```
# HTTP Metrics
http_requests_total               - Total HTTP requests
http_request_duration_seconds     - Request duration histogram
http_requests_active              - Active requests gauge

# Business Metrics
business_operations_total         - Business operations counter
app_info                          - Application information
```

### Alerting Rules

**Critical Alerts:**
- SLO Violation (99.9% availability)
- High Error Rate (>5%)
- Pod Crash Looping
- Certificate Expiring Soon

**Warning Alerts:**
- High Memory Usage (>90%)
- High CPU Throttling
- Deployment Replica Mismatch
- PV Filling Up

### Distributed Tracing

View traces in Jaeger:
```bash
kubectl port-forward -n monitoring svc/jaeger-query 16686:16686
# URL: http://localhost:16686
```

## 💰 Cost Optimization

### Cluster Autoscaler

Automatically scales nodes based on pending pods:

```yaml
# Configuration
--scale-down-enabled=true
--scale-down-delay-after-add=10m
--scale-down-unneeded-time=10m
--scale-down-utilization-threshold=0.5
```

### Vertical Pod Autoscaler (VPA)

Automatically adjusts pod resources:

```bash
# Apply VPA
kubectl apply -f autoscaling/vpa/sample-app-vpa.yaml

# Check recommendations
kubectl get vpa sample-app-vpa -o yaml
```

### Karpenter (Alternative)

Advanced autoscaling with spot instances:

```bash
# Install Karpenter (requires additional setup)
helm upgrade --install karpenter karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
  --set settings.aws.clusterName=${CLUSTER_NAME} \
  --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile \
  --wait
```

### Resource Quotas

Limit resource consumption per namespace:

```bash
# Apply quotas
kubectl apply -f autoscaling/resource-quotas/production-quota.yaml
kubectl apply -f autoscaling/limit-ranges/production-limits.yaml
```

## 🔗 Service Mesh

### Istio Integration

Install Istio:
```bash
# Install Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
kubectl apply -f manifests/charts/istio-crds/files/
kubectl apply -f manifests/charts/istio-control/istio-discovery/files/
```

Deploy with Istio sidecar:
```bash
# Enable Istio injection
kubectl label namespace production istio-injection=enabled

# Deploy application
kubectl apply -f k8s/overlays/prod/
```

### Traffic Management

Configure traffic routing:
```bash
# Apply virtual service
kubectl apply -f service-mesh/istio/virtual-service.yaml

# Apply destination rules
kubectl apply -f service-mesh/istio/destination-rule.yaml
```

## 🧪 Load Testing

### K6 Load Testing

Run load tests locally:
```bash
# Install k6
npm install -g k6

# Run basic load test
k6 run load-testing/k6/basic-load-test.js

# Run with environment variables
BASE_URL=http://localhost:8080 k6 run load-testing/k6/basic-load-test.js
```

Run load tests in Kubernetes:
```bash
# Create testing namespace
kubectl create namespace testing

# Create ConfigMap with test scripts
kubectl create configmap k6-scripts \
  --from-file=load-testing/k6/basic-load-test.js \
  -n testing

# Apply the job
kubectl apply -f load-testing/k8s/k6-job.yaml

# Check job status
kubectl get jobs -n testing

# View logs
kubectl logs -n testing -l app=k6
```

### GitHub Actions Load Testing

Trigger load tests via GitHub Actions:
1. Go to GitHub repository
2. Navigate to Actions tab
3. Select "Load Testing" workflow
4. Run workflow with desired parameters

## 🔔 Notifications

### ArgoCD Notifications

Configure notification channels:
```bash
# Apply notification configuration
kubectl apply -f argocd/notifications/argocd-notifications-cm.yaml
kubectl apply -f argocd/notifications/argocd-notifications-secret.yaml
```

Subscribe to notifications:
```yaml
# In application manifest
metadata:
  annotations:
    notifications.argoproj.io/subscribe.on-deployed.slack: "deployments"
    notifications.argoproj.io/subscribe.on-health-degraded.slack: "alerts"
```

### Alertmanager Configuration

Configure alert routing:
```bash
# Apply Alertmanager config
kubectl apply -f monitoring/alertmanager/alertmanager-config.yaml
```

## 🔐 Security

### Container Scanning

Scan images for vulnerabilities:
```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan image
trivy image ghcr.io/your-org/sample-app:latest
```

### Secret Management

Securely manage secrets:
```bash
# Install kubeseal
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.24.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

# Create sealed secret
kubectl create secret generic my-secret \
  --from-literal=username=myuser \
  --from-literal=password=mypassword \
  -o json --dry-run=client \
  | kubeseal \
  | kubectl apply -f -
```

### Network Policies

Restrict pod communication:
```bash
# Apply network policies
kubectl apply -f k8s/network-policies/
```

## 🛠️ Troubleshooting

### Common Issues

1. **ArgoCD Sync Issues**
   ```bash
   # Check application status
   argocd app get sample-app-prod
   
   # Force sync
   argocd app sync sample-app-prod --force
   ```

2. **Pod Crash Looping**
   ```bash
   # Check pod logs
   kubectl logs -n production sample-app-xyz --previous
   
   # Describe pod
   kubectl describe pod -n production sample-app-xyz
   ```

3. **High Memory Usage**
   ```bash
   # Check VPA recommendations
   kubectl get vpa sample-app-vpa -o yaml
   
   # Check resource usage
   kubectl top pods -n production
   ```

4. **Prometheus Alerts Firing**
   ```bash
   # Check alert status
   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
   
   # Query active alerts
   curl http://localhost:9090/api/v1/alerts
   ```

### Debugging Commands

```bash
# Check all pods
kubectl get pods -A

# Check events
kubectl get events -A --sort-by='.lastTimestamp'

# Check logs
kubectl logs -n production deployment/sample-app

# Check resources
kubectl top nodes
kubectl top pods -n production

# Check HPA status
kubectl get hpa -n production

# Check VPA recommendations
kubectl get vpa -n production
```

## 📚 Best Practices

### GitOps Best Practices

1. **Separate Configuration from Code**
   - Keep Kubernetes manifests in separate repository
   - Use Kustomize for environment-specific configurations

2. **Use Semantic Versioning**
   - Tag releases with semantic versioning
   - Use tags in ArgoCD applications

3. **Implement Proper RBAC**
   - Define least-privilege roles
   - Use ArgoCD projects for isolation

### Kubernetes Best Practices

1. **Resource Management**
   - Set resource requests and limits
   - Use VPA for optimization
   - Implement resource quotas

2. **Health Checks**
   - Implement readiness and liveness probes
   - Use meaningful health check endpoints

3. **Security**
   - Use security contexts
   - Implement network policies
   - Regularly scan images

### Monitoring Best Practices

1. **SLOs and SLIs**
   - Define meaningful SLOs
   - Implement appropriate alerting
   - Regular SLO review

2. **Dashboard Design**
   - Focus on actionable metrics
   - Use appropriate visualizations
   - Regular dashboard review

### CI/CD Best Practices

1. **Pipeline Design**
   - Fast feedback loops
   - Automated testing
   - Security scanning

2. **Deployment Strategies**
   - Use progressive delivery
   - Implement rollback mechanisms
   - Monitor deployments

## 📞 Support

For issues and questions:
- Open a GitHub issue
- Contact the DevOps team
- Check the troubleshooting section

## 📧 Contact

For direct inquiries, please contact:
- Email: oluwafunsho.osho@gmail.com
- GitHub: [Bamideleflint](https://github.com/Bamideleflint)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

**Built with ❤️ for GitOps excellence**
