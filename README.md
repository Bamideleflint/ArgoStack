# ArgoStack - Production-Ready Kubernetes GitOps Platform

**ArgoStack** is a complete, production-ready Kubernetes platform demonstrating modern DevOps best practices. It combines GitOps delivery, progressive deployment strategies, comprehensive monitoring, security scanning, and automated testing in a beginner-friendly package.

## 🎯 What Is This Project?

ArgoStack is a **learning-focused DevOps reference implementation** that shows you how to build a complete cloud-native platform from scratch. Whether you're learning Kubernetes, preparing for DevOps interviews, or building your portfolio, this project provides hands-on experience with industry-standard tools and practices.

### What You'll Learn

- **GitOps with ArgoCD**: Automated, declarative deployments from Git
- **Progressive Delivery**: Canary deployments with automated analysis and rollback
- **Monitoring Stack**: Prometheus metrics, Grafana dashboards, and intelligent alerting
- **CI/CD Pipelines**: GitHub Actions workflows for testing, building, and security scanning
- **Multi-Environment**: Proper dev → staging → production promotion workflow
- **Security**: Container scanning, network policies, and best practices
- **Load Testing**: Performance validation with K6

## 📚 Documentation

- **[Complete Setup Guide](docs/complete-documentation.md)** - Step-by-step instructions with commands
- **[Troubleshooting Guide](docs/troubleshooting.md)** - Common errors and solutions

## 🚀 Quick Start

```bash
# 1. Install tools
bash scripts/install-tools.sh

# 2. Start Minikube cluster
bash scripts/start-cluster.sh

# 3. Deploy all components
bash scripts/setup-cluster.sh

# 4. Access dashboards
kubectl port-forward -n argocd svc/argocd-server 8080:443
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

**Credentials:**
- ArgoCD: `admin` / (get password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`)
- Grafana: `admin` / `admin123`

## 📦 Key Components

### 1. Sample Application (`apps/sample-app`)
- Python Flask REST API with health endpoints
- Prometheus metrics export
- Docker containerization

### 2. GitOps with ArgoCD (`argocd/`)
- Application definitions for dev, staging, production
- Auto-sync enabled for continuous delivery
- Health status monitoring

### 3. Progressive Delivery (`k8s/overlays/*/rollout.yml`)
- Argo Rollouts for canary deployments
- Automated Prometheus-based analysis
- Traffic shifting: 20% → 50% → 100%
- Automatic rollback on failures

### 4. Monitoring Stack (`monitoring/`)
- Prometheus for metrics collection
- Grafana with custom dashboards
- 16 production-ready alert rules
- ServiceMonitor for automatic scraping

### 5. CI/CD Pipelines (`.github/workflows/`)
- **ci.yml**: Build, test, push to GHCR on every push
- **security-scan.yml**: Trivy vulnerability scanning + kube-score
- **release.yml**: Production releases via tags
- Image Registry: `ghcr.io/bamideleflint/argostack-sample-app`

### 6. Load Testing (`load-testing/`)
- K6 scenarios: baseline, stress, spike, soak
- Kubernetes Job integration

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────┐
│                GitHub Repository                     │
│  (Source of Truth for Infrastructure & Code)         │
└────────────────┬─────────────────────────────────────┘
                 │
        ┌────────┴──────────┐
        │                   │
   ┌────▼─────┐         ┌───▼────────┐
   │ GitHub   │         │   ArgoCD   │
   │ Actions  │         │  (GitOps)  │
   │  (CI/CD) │         └─────┬──────┘
   └────┬─────┘               │
        │                     │ Auto-sync
        │ Build & Push        │
        ▼                     ▼
   ┌─────────────────────────────────┐
   │    Kubernetes Cluster           │
   │  ┌─────────┬──────────┬───────┐ │
   │  │   Dev   │ Staging  │  Prod │ │
   │  │ (Canary)│ (Canary) │(Stable)│ │
   │  └─────────┴──────────┴───────┘ │
   │                                  │
   │  ┌──────────────────────────┐   │
   │  │  Monitoring & Security   │   │
   │  │ Prometheus | Grafana     │   │
   │  │ Alertmanager | K6        │   │
   │  └──────────────────────────┘   │
   └─────────────────────────────────┘
```

## 🎓 Use Cases

- **Learning**: Hands-on experience with production DevOps tools
- **Portfolio**: Demonstrate cloud-native expertise to employers
- **Reference**: Template for real-world Kubernetes projects
- **Interview Prep**: Practice with common DevOps interview topics

## ✨ Features

- ✅ Fully automated GitOps workflow
- ✅ Progressive canary deployments with rollback
- ✅ Comprehensive monitoring and alerting
- ✅ Security scanning in CI/CD
- ✅ Multi-environment support (dev/staging/prod)
- ✅ Load testing integration
- ✅ Custom Grafana dashboards
- ✅ Network policies for security
- ✅ Pod disruption budgets for availability
- ✅ Beginner-friendly documentation

## 📋 Prerequisites

- **OS**: Linux or WSL2 on Windows
- **Tools**: Docker, kubectl, helm, kustomize
- **Cluster**: Minikube (local) or any Kubernetes cluster
- **Memory**: 8GB RAM minimum
- **CPU**: 4 cores recommended

## 🤝 Contributing

Contributions welcome! Please check out the documentation for setup details.

## 📧 Contact

- **Email**: oluwafunsho.osho@gmail.com
- **GitHub**: [Bamideleflint](https://github.com/Bamideleflint)

## 📄 License

MIT License - See LICENSE file for details

---

**Made with ❤️ for the DevOps community**
