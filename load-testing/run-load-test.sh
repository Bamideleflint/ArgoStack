#!/bin/bash

# Script to run K6 load tests locally or in Kubernetes

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to show usage
usage() {
    echo -e "${BLUE}K6 Load Testing Script${NC}"
    echo ""
    echo "Usage: $0 [test-type] [mode] [namespace]"
    echo ""
    echo "Test types:"
    echo "  baseline  - Baseline load test (10 users, 5 min)"
    echo "  stress    - Stress test (up to 150 users, 25 min)"
    echo "  spike     - Spike test (sudden surge to 200 users)"
    echo "  soak      - Soak test (30 users, 30 min)"
    echo ""
    echo "Mode:"
    echo "  local     - Run K6 locally (requires k6 installed)"
    echo "  k8s       - Run as Kubernetes Job"
    echo ""
    echo "Namespace (optional, default: dev):"
    echo "  dev, staging, production"
    echo ""
    echo "Examples:"
    echo "  $0 baseline local dev"
    echo "  $0 stress k8s staging"
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
    exit 1
fi

TEST_TYPE=$1
MODE=$2
NAMESPACE=${3:-dev}

# Validate test type
case $TEST_TYPE in
    baseline|stress|spike|soak)
        ;;
    *)
        echo -e "${RED}Invalid test type: $TEST_TYPE${NC}"
        usage
        exit 1
        ;;
esac

# Validate mode
case $MODE in
    local|k8s)
        ;;
    *)
        echo -e "${RED}Invalid mode: $MODE${NC}"
        usage
        exit 1
        ;;
esac

TEST_FILE="${SCRIPT_DIR}/k6/${TEST_TYPE}-test.js"

if [ ! -f "$TEST_FILE" ]; then
    echo -e "${RED}Test file not found: $TEST_FILE${NC}"
    exit 1
fi

# Run test based on mode
if [ "$MODE" == "local" ]; then
    echo -e "${BLUE}Running K6 ${TEST_TYPE} test locally...${NC}"
    
    # Check if k6 is installed
    if ! command -v k6 &> /dev/null; then
        echo -e "${RED}K6 is not installed. Install it first:${NC}"
        echo "  curl https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz -L | tar xvz --strip-components 1"
        echo "  sudo mv k6 /usr/local/bin/"
        exit 1
    fi
    
    # Set BASE_URL based on namespace
    export BASE_URL="http://sample-app.${NAMESPACE}.svc.cluster.local"
    
    echo -e "${YELLOW}Target: $BASE_URL${NC}"
    echo -e "${YELLOW}Starting test...${NC}"
    
    k6 run "$TEST_FILE"
    
elif [ "$MODE" == "k8s" ]; then
    echo -e "${BLUE}Running K6 ${TEST_TYPE} test as Kubernetes Job...${NC}"
    
    JOB_FILE="${SCRIPT_DIR}/k6-${TEST_TYPE}-job.yml"
    
    if [ ! -f "$JOB_FILE" ]; then
        echo -e "${YELLOW}Job manifest not found, using baseline job as template${NC}"
        JOB_FILE="${SCRIPT_DIR}/k6-baseline-job.yml"
    fi
    
    # Delete existing job if it exists
    kubectl delete job k6-${TEST_TYPE}-test -n $NAMESPACE 2>/dev/null || true
    kubectl delete configmap k6-${TEST_TYPE}-test -n $NAMESPACE 2>/dev/null || true
    
    # Create ConfigMap with test script
    echo -e "${YELLOW}Creating ConfigMap with test script...${NC}"
    kubectl create configmap k6-${TEST_TYPE}-test \
        --from-file=${TEST_TYPE}-test.js="$TEST_FILE" \
        -n $NAMESPACE
    
    # Create and run job
    echo -e "${YELLOW}Creating K6 job...${NC}"
    cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: k6-${TEST_TYPE}-test
  namespace: $NAMESPACE
spec:
  backoffLimit: 0
  ttlSecondsAfterFinished: 3600
  template:
    metadata:
      labels:
        app: k6-test
        test-type: ${TEST_TYPE}
    spec:
      restartPolicy: Never
      containers:
      - name: k6
        image: grafana/k6:latest
        command: ["k6", "run", "/scripts/${TEST_TYPE}-test.js"]
        env:
        - name: BASE_URL
          value: "http://sample-app.${NAMESPACE}.svc.cluster.local"
        volumeMounts:
        - name: k6-script
          mountPath: /scripts
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
      volumes:
      - name: k6-script
        configMap:
          name: k6-${TEST_TYPE}-test
EOF
    
    echo -e "${GREEN}K6 job created!${NC}"
    echo ""
    echo "Monitor the test:"
    echo "  kubectl get jobs -n $NAMESPACE"
    echo "  kubectl logs -f job/k6-${TEST_TYPE}-test -n $NAMESPACE"
    echo ""
    echo "View results after completion:"
    echo "  kubectl logs job/k6-${TEST_TYPE}-test -n $NAMESPACE"
fi

echo -e "${GREEN}Test initiated successfully!${NC}"
