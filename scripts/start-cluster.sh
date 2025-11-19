#!/bin/bash
# Start minikube cluster with optimal settings for WSL

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Starting Minikube Cluster${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo -e "${RED}minikube is not installed. Please run install-tools.sh first.${NC}"
    exit 1
fi

# Check if cluster is already running
if minikube status &> /dev/null; then
    echo -e "${YELLOW}Minikube cluster is already running${NC}"
    minikube status
    exit 0
fi

# Start minikube with optimal settings for development
echo -e "${BLUE}Starting minikube cluster...${NC}"
minikube start \
    --driver=docker \
    --cpus=4 \
    --memory=6144 \
    --disk-size=20g \
    --force

echo -e "${GREEN}Minikube cluster started successfully!${NC}"

# Verify kubectl is configured
echo -e "${BLUE}Verifying kubectl configuration...${NC}"
kubectl cluster-info
kubectl get nodes

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cluster is ready!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Run './scripts/setup-cluster.sh' to install ArgoCD and monitoring tools"
echo "  2. Build and push your Docker image to GitHub Container Registry"
echo "  3. Deploy your applications"
echo ""
echo "Useful commands:"
echo "  - Check cluster status: minikube status"
echo "  - Stop cluster: minikube stop"
echo "  - Delete cluster: minikube delete"
echo "  - Access dashboard: minikube dashboard"
