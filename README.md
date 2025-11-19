# ArgoStack - DevOps Project with ArgoCD, Grafana & Prometheus

This project demonstrates a complete DevOps setup using ArgoCD for GitOps, Prometheus for monitoring, and Grafana for visualization in a Kubernetes environment.

## 📚 Complete Documentation

For comprehensive documentation, please see [docs/complete-documentation.md](docs/complete-documentation.md).

## Project Structure

ArgoStack/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── security-scan.yml
│       └── release.yml
├── apps/
│   └── sample-app/
│       ├── Dockerfile
│       ├── .dockerignore
│       └── src/
├── k8s/
│   ├── base/
│   │   ├── deployment.yml
│   │   ├── service.yml
│   │   ├── servicemonitor.yml
│   │   └── kustomization.yml
│   ├── overlays/
│   │   ├── dev/
│   │   │   └── kustomization.yml
│   │   ├── staging/
│   │   │   └── kustomization.yml
│   │   └── prod/
│   │       └── kustomization.yml
├── argocd/
│   ├── applications/
│   │   ├── sample-app-dev.yml
│   │   ├── sample-app-staging.yml
│   │   └── sample-app-prod.yml
│   └── projects/
│       └── project.yml
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus-config.yml
│   │   ├── alerting-rules.yml
│   │   └── kustomization.yml
│   └── grafana/
│       ├── dashboards/
│       │   ├── app-dashboard.json
│       │   └── kubernetes-dashboard.json
│       ├── grafana-config.yml
│       └── kustomization.yml

├── scripts\
│   ├── setup-cluster.sh\
│   ├── start-cluster.sh\
│   └── install-tools.sh
└── docs/
    └── complete-documentation.md

## Components

### 1. GitHub Actions CI/CD Pipeline
- **ci.yml**: Continuous integration pipeline that runs tests, builds and pushes Docker images, and updates Kubernetes manifests
- **security-scan.yml**: Security scanning with Trivy and kube-score
- **release.yml**: Release pipeline that creates GitHub releases

### 2. Kubernetes Manifests with Kustomize
- **base**: Base Kubernetes manifests for the sample application
- **overlays**: Environment-specific overlays for dev, staging, and production

### 3. ArgoCD Applications
- **applications**: ArgoCD Application manifests for each environment
- **projects**: ArgoCD Project definitions

### 4. Monitoring with Prometheus and Grafana
- **prometheus**: Prometheus configuration and alerting rules
- **grafana**: Grafana configuration and dashboards



### 6. Scripts
- **setup-cluster.sh**: Script to set up the Kubernetes cluster with all components
- **install-tools.sh**: Script to install required tools

## Getting Started

1. Install required tools:
   ```bash
   ./scripts/install-tools.sh
   ```

2. Start the Kubernetes cluster:
   ```bash
   ./scripts/start-cluster.sh
   ```

3. Set up the cluster with all components:
   ```bash
   ./scripts/setup-cluster.sh
   ```

4. Access the tools:
   - ArgoCD: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
   - Grafana: `kubectl port-forward svc/grafana -n monitoring 3000:80`

## Features

- **GitOps**: Automated deployment using ArgoCD
- **Monitoring**: Comprehensive monitoring with Prometheus
- **Visualization**: Dashboards with Grafana
- **Security**: Automated security scanning
- **Multi-environment**: Dev, staging, and production environments
- **Helm**: Helm charts for application deployment
- **Kustomize**: Environment-specific configurations

## Prerequisites

- Kubernetes cluster (minikube or cloud provider)
- kubectl
- Helm
- Kustomize
- Docker
- ArgoCD CLI

## Contact

For questions or support, please contact:
- Email: oluwafunsho.osho@gmail.com
- GitHub: [Bamideleflint](https://github.com/Bamideleflint)

## License

This project is licensed under the MIT License.
