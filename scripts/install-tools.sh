#!/bin/bash
# Install all required DevOps tools

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing DevOps Tools...${NC}"

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo -e "${GREEN}Detected OS: ${MACHINE}${NC}"

# Install kubectl
install_kubectl() {
    echo -e "${BLUE}Installing kubectl...${NC}"
    if command -v kubectl &> /dev/null; then
        echo -e "${GREEN}kubectl already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install kubectl
        else
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            rm kubectl
        fi
        echo -e "${GREEN}kubectl installed successfully${NC}"
    fi
}

# Install Helm
install_helm() {
    echo -e "${BLUE}Installing Helm...${NC}"
    if command -v helm &> /dev/null; then
        echo -e "${GREEN}Helm already installed${NC}"
    else
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        echo -e "${GREEN}Helm installed successfully${NC}"
    fi
}

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

# Install ArgoCD CLI
install_argocd_cli() {
    echo -e "${BLUE}Installing ArgoCD CLI...${NC}"
    if command -v argocd &> /dev/null; then
        echo -e "${GREEN}ArgoCD CLI already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install argocd
        else
            curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
            sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
            rm argocd-linux-amd64
        fi
        echo -e "${GREEN}ArgoCD CLI installed successfully${NC}"
    fi
}

# Install Argo Rollouts kubectl plugin
install_argo_rollouts() {
    echo -e "${BLUE}Installing Argo Rollouts kubectl plugin...${NC}"
    if command -v kubectl-argo-rollouts &> /dev/null; then
        echo -e "${GREEN}Argo Rollouts plugin already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install argoproj/tap/kubectl-argo-rollouts
        else
            curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
            chmod +x kubectl-argo-rollouts-linux-amd64
            sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
        fi
        echo -e "${GREEN}Argo Rollouts plugin installed successfully${NC}"
    fi
}

# Install k9s (Kubernetes CLI UI)
install_k9s() {
    echo -e "${BLUE}Installing k9s...${NC}"
    if command -v k9s &> /dev/null; then
        echo -e "${GREEN}k9s already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install k9s
        else
            curl -sS https://webinstall.dev/k9s | bash
        fi
        echo -e "${GREEN}k9s installed successfully${NC}"
    fi
}

# Install Trivy (security scanner)
install_trivy() {
    echo -e "${BLUE}Installing Trivy...${NC}"
    if command -v trivy &> /dev/null; then
        echo -e "${GREEN}Trivy already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install trivy
        else
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
            sudo apt-get update
            sudo apt-get install trivy
        fi
        echo -e "${GREEN}Trivy installed successfully${NC}"
    fi
}

# Install kubeval (manifest validator)
install_kubeval() {
    echo -e "${BLUE}Installing kubeval...${NC}"
    if command -v kubeval &> /dev/null; then
        echo -e "${GREEN}kubeval already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install kubeval
        else
            wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
            tar xf kubeval-linux-amd64.tar.gz
            sudo mv kubeval /usr/local/bin
            rm kubeval-linux-amd64.tar.gz
        fi
        echo -e "${GREEN}kubeval installed successfully${NC}"
    fi
}

# Install kustomize
install_kustomize() {
    echo -e "${BLUE}Installing kustomize...${NC}"
    if command -v kustomize &> /dev/null; then
        echo -e "${GREEN}kustomize already installed${NC}"
    else
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        sudo mv kustomize /usr/local/bin/
        echo -e "${GREEN}kustomize installed successfully${NC}"
    fi
}

# Install kubeseal (for sealed secrets)
install_kubeseal() {
    echo -e "${BLUE}Installing kubeseal...${NC}"
    if command -v kubeseal &> /dev/null; then
        echo -e "${GREEN}kubeseal already installed${NC}"
    else
        if [ "$MACHINE" == "Mac" ]; then
            brew install kubeseal
        else
            wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz
            tar -xvzf kubeseal-0.24.0-linux-amd64.tar.gz kubeseal
            sudo install -m 755 kubeseal /usr/local/bin/kubeseal
            rm kubeseal kubeseal-0.24.0-linux-amd64.tar.gz
        fi
        echo -e "${GREEN}kubeseal installed successfully${NC}"
    fi
}

# Main installation
main() {
    install_kubectl
    install_helm
    install_minikube
    install_argocd_cli
    install_argo_rollouts
    install_k9s
    install_trivy
    install_kubeval
    install_kustomize
    install_kubeseal
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}All tools installed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Installed tools:"
    echo "  - kubectl: $(kubectl version --client 2>/dev/null | head -n1 | sed 's/Client Version: //' || echo 'N/A')"
    echo "  - helm: $(helm version --short 2>/dev/null || echo 'N/A')"
    echo "  - minikube: $(minikube version --short 2>/dev/null || echo 'N/A')"
    echo "  - argocd: $(argocd version --client --short 2>/dev/null || echo 'N/A')"
    echo "  - kubectl-argo-rollouts: $(kubectl argo rollouts version 2>/dev/null || echo 'N/A')"
    echo "  - k9s: $(k9s version --short 2>/dev/null || echo 'N/A')"
    echo "  - trivy: $(trivy --version 2>/dev/null || echo 'N/A')"
    echo "  - kustomize: $(kustomize version --short 2>/dev/null || echo 'N/A')"
}

main