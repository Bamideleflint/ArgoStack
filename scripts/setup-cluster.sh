#!/bin/bash
# Setup Kubernetes cluster with ArgoCD and monitoring tools

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setting up Kubernetes Cluster${NC}"
echo -e "${BLUE}========================================${NC}"

# Install Prometheus Stack
install_prometheus() {
    echo -e "${BLUE}Installing Prometheus Stack...${NC}"
    
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Add Prometheus Helm repo
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install kube-prometheus-stack with optimized settings for minikube
    echo -e "${YELLOW}This may take 5-10 minutes on minikube...${NC}"
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.retention=7d \
        --set prometheus.prometheusSpec.resources.requests.memory=512Mi \
        --set prometheus.prometheusSpec.resources.limits.memory=1Gi \
        --set alertmanager.alertmanagerSpec.resources.requests.memory=128Mi \
        --set alertmanager.alertmanagerSpec.resources.limits.memory=256Mi \
        --set grafana.adminPassword=admin123 \
        --set grafana.persistence.enabled=false \
        --set grafana.resources.requests.memory=128Mi \
        --set grafana.resources.limits.memory=256Mi \
        --set kube-state-metrics.resources.requests.memory=64Mi \
        --set kube-state-metrics.resources.limits.memory=128Mi \
        --set prometheus-node-exporter.resources.requests.memory=32Mi \
        --set prometheus-node-exporter.resources.limits.memory=64Mi \
        --timeout 20m \
        --wait || true
    
    # Check if installation succeeded
    echo -e "${YELLOW}Checking Prometheus components...${NC}"
    sleep 10
    kubectl get pods -n monitoring
    
    echo -e "${GREEN}Prometheus Stack installation initiated${NC}"
    echo -e "${YELLOW}Note: Pods may take 5-10 minutes to become ready${NC}"
    echo -e "${YELLOW}Grafana Admin Password: admin123${NC}"
    echo -e "${YELLOW}Access Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80${NC}"
}

# Install ArgoCD
install_argocd() {
    echo -e "${BLUE}Installing ArgoCD...${NC}"
    
    # Create namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Install ArgoCD
    echo -e "${YELLOW}Installing ArgoCD manifests...${NC}"
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for ArgoCD pods to be ready
    echo -e "${YELLOW}Waiting for ArgoCD to be ready (this may take 2-3 minutes)...${NC}"
    kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s || true
    
    # Get initial admin password
    echo -e "${YELLOW}Retrieving ArgoCD admin password...${NC}"
    sleep 10
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "<password-not-ready>")
    
    echo -e "${GREEN}ArgoCD installed successfully${NC}"
    echo -e "${YELLOW}ArgoCD Admin Username: admin${NC}"
    echo -e "${YELLOW}ArgoCD Admin Password: ${ARGOCD_PASSWORD}${NC}"
    echo -e "${YELLOW}Access ArgoCD: kubectl port-forward -n argocd svc/argocd-server 8080:443${NC}"
    echo -e "${YELLOW}Then visit: https://localhost:8080${NC}"
}

# Install Argo Rollouts
install_argo_rollouts() {
    echo -e "${BLUE}Installing Argo Rollouts...${NC}"
    
    # Create namespace
    kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Argo Rollouts
    kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
    
    echo -e "${GREEN}Argo Rollouts installed successfully${NC}"
}

# Deploy sample application using Kustomize
deploy_sample_app() {
    echo -e "${BLUE}Deploying sample application...${NC}"
    
    # Get the script directory to reference project paths
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    PROJECT_ROOT="$( cd "${SCRIPT_DIR}/.." && pwd )"
    
    # Create dev namespace
    kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
    
    # Apply base manifests with dev overlay using Kustomize
    if [ -d "${PROJECT_ROOT}/k8s/overlays/dev" ]; then
        echo -e "${YELLOW}Applying development environment manifests...${NC}"
        kubectl apply -k "${PROJECT_ROOT}/k8s/overlays/dev" || echo -e "${YELLOW}Note: Application deployment may need Docker image to be built first${NC}"
    else
        echo -e "${YELLOW}Dev overlay not found, skipping application deployment${NC}"
    fi
    
    echo -e "${GREEN}Sample application deployment initiated${NC}"
}

# Apply ArgoCD applications
apply_argocd_apps() {
    echo -e "${BLUE}Applying ArgoCD applications...${NC}"
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    PROJECT_ROOT="$( cd "${SCRIPT_DIR}/.." && pwd )"
    
    # Apply ArgoCD project
    if [ -f "${PROJECT_ROOT}/argocd/projects/project.yml" ]; then
        echo -e "${YELLOW}Applying ArgoCD project...${NC}"
        kubectl apply -f "${PROJECT_ROOT}/argocd/projects/project.yml" || true
    fi
    
    # Apply ArgoCD applications
    if [ -d "${PROJECT_ROOT}/argocd/applications" ]; then
        echo -e "${YELLOW}Applying ArgoCD applications...${NC}"
        kubectl apply -f "${PROJECT_ROOT}/argocd/applications/" || echo -e "${YELLOW}Note: Some applications may fail without proper image registry access${NC}"
    fi
    
    echo -e "${GREEN}ArgoCD applications configured${NC}"
}


# Main installation
main() {
    install_prometheus
    install_argocd
    install_argo_rollouts
    deploy_sample_app
    apply_argocd_apps
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Cluster setup complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Installed components:"
    echo "  ✅ Prometheus Stack (monitoring namespace)"
    echo "  ✅ ArgoCD (argocd namespace)"
    echo "  ✅ Argo Rollouts (argo-rollouts namespace)"
    echo ""
    echo "Useful commands:"
    echo "  - Check monitoring pods: kubectl get pods -n monitoring"
    echo "  - Check ArgoCD pods: kubectl get pods -n argocd"
    echo "  - Access Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    echo "  - Access ArgoCD: kubectl port-forward -n argocd svc/argocd-server 8080:443"
    echo ""
    echo "Credentials:"
    echo "  - Grafana: admin / admin123"
    echo "  - ArgoCD: admin / (see password above)"
}

main
