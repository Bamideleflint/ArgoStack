#!/bin/bash

# Script to deploy custom Grafana dashboards
# This script creates ConfigMaps for Grafana dashboards and imports them

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Deploying Custom Grafana Dashboards...${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/.." && pwd )"
DASHBOARD_DIR="${PROJECT_ROOT}/monitoring/grafana/dashboards"

# Check if dashboards directory exists
if [ ! -d "$DASHBOARD_DIR" ]; then
    echo -e "${YELLOW}Dashboard directory not found: $DASHBOARD_DIR${NC}"
    exit 1
fi

# Deploy dashboard ConfigMap
echo -e "${YELLOW}Applying dashboard ConfigMap...${NC}"
kubectl apply -f "${PROJECT_ROOT}/monitoring/grafana/dashboard-configmap.yml" || true

# Alternative: Create ConfigMaps directly from dashboard JSON files
echo -e "${YELLOW}Creating ConfigMaps from dashboard JSON files...${NC}"

for dashboard_file in "$DASHBOARD_DIR"/*.json; do
    if [ -f "$dashboard_file" ]; then
        dashboard_name=$(basename "$dashboard_file" .json)
        echo -e "${YELLOW}Creating ConfigMap for: $dashboard_name${NC}"
        
        kubectl create configmap "grafana-dashboard-${dashboard_name}" \
            --from-file="$dashboard_file" \
            --namespace=monitoring \
            --dry-run=client -o yaml | \
            kubectl label -f - grafana_dashboard=1 --local --dry-run=client -o yaml | \
            kubectl apply -f -
    fi
done

# Restart Grafana to pick up new dashboards
echo -e "${YELLOW}Restarting Grafana to load new dashboards...${NC}"
kubectl rollout restart deployment prometheus-grafana -n monitoring

# Wait for Grafana to be ready
echo -e "${YELLOW}Waiting for Grafana to be ready...${NC}"
kubectl wait --for=condition=available --timeout=120s deployment/prometheus-grafana -n monitoring || true

echo -e "${GREEN}Dashboard deployment complete!${NC}"
echo ""
echo "Available dashboards:"
kubectl get configmap -n monitoring -l grafana_dashboard=1 -o name

echo ""
echo -e "${GREEN}Access Grafana to view dashboards:${NC}"
echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "  Login: admin / admin123"
echo "  Navigate to: Dashboards → Browse"
