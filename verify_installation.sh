#!/bin/bash

# K3s + Cilium Installation Verification Script

# Load print helper functions
source "$(dirname "$0")/scripts/print_helper.sh"

cprint "K3s + Cilium Installation Verification" 0 "equal"

# Load configuration
if [[ -f "./my_k3s_cluster.config" ]]; then
    source ./my_k3s_cluster.config
else
    cprint_warning "Configuration file not found!"
fi

cprint "1. Checking K3s service status" 0 "dash"
if systemctl is-active --quiet k3s; then
    cprint "K3s service is running" 1
else
    cprint_error "K3s service is not running"
fi

cprint "2. Checking kubectl connectivity" 0 "dash"
if kubectl cluster-info > /dev/null 2>&1; then
    cprint "kubectl can connect to cluster" 1
else
    cprint_error "kubectl cannot connect to cluster"
fi

cprint "3. Checking nodes status" 0 "dash"
READY_NODES=$(kubectl get nodes --no-headers | grep -c "Ready")
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
cprint "Nodes: $READY_NODES/$TOTAL_NODES Ready" 1
kubectl get nodes

cprint "4. Checking Cilium pods" 0 "dash"
CILIUM_RUNNING=$(kubectl get pods -n ${CILIUM_NAMESPACE:-cilium} --no-headers 2>/dev/null | grep -c "Running")
CILIUM_TOTAL=$(kubectl get pods -n ${CILIUM_NAMESPACE:-cilium} --no-headers 2>/dev/null | wc -l)
if [[ $CILIUM_TOTAL -gt 0 ]]; then
    cprint "Cilium pods: $CILIUM_RUNNING/$CILIUM_TOTAL Running" 1
    kubectl get pods -n ${CILIUM_NAMESPACE:-cilium}
else
    cprint_warning "No Cilium pods found"
fi

cprint "5. Checking Cilium status" 0 "dash"
if command -v cilium &> /dev/null; then
    cilium status --brief
else
    cprint_warning "Cilium CLI not found"
fi

cprint "6. Checking system resources" 0 "dash"
kubectl top nodes 2>/dev/null || cprint "Metrics server not available" 1

cprint "7. Checking available tools" 0 "dash"
TOOLS=("kubectl" "helm" "k9s" "kubens" "kubectx" "cilium" "hubble")
for tool in "${TOOLS[@]}"; do
    if command -v $tool &> /dev/null; then
        cprint "✓ $tool" 1
    else
        cprint "✗ $tool (not found)" 1
    fi
done

cprint_success "Verification completed!"
