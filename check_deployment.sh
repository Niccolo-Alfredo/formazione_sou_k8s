#!/bin/bash
set -e

# Parametri
NAMESPACE="${1:-formazione-sou}"
DEPLOYMENT_NAME="${2:-flask-app-example-flask-app-chart}"
KUBECONFIG_FILE="${3:-$HOME/.kube/config}"

echo "--- Avvio il controllo delle best practices per il deployment: $DEPLOYMENT_NAME nel namespace: $NAMESPACE ---"

export KUBECONFIG="$KUBECONFIG_FILE"

# ==================================
# 1. VERIFICA PRESENZA DEL DEPLOYMENT
# ==================================
echo "Recupero il manifesto del deployment..."
DEPLOYMENT_JSON=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o json || true)
if [[ -z "$DEPLOYMENT_JSON" ]]; then
    echo "ERRORE: Deployment '$DEPLOYMENT_NAME' non trovato nel namespace '$NAMESPACE'."
    exit 1
fi
echo "Deployment trovato."

# ==================================
# 2. VERIFICA PROBE
# ==================================
echo "Verifica l'esistenza di livenessProbe e readinessProbe..."
LIVENESS=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' || true)
READINESS=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' || true)

if [[ -n "$LIVENESS" && -n "$READINESS" ]]; then
    echo "Liveness e Readiness Probe trovate."
else
    echo "ERRORE: Il deployment non ha livenessProbe o readinessProbe configurate."
    exit 1
fi

# ==================================
# 3. VERIFICA LIMITS E REQUESTS
# ==================================
echo "Verifica l'esistenza di limits e requests per CPU e Memoria..."
CPU_LIMIT=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' || true)
MEM_LIMIT=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' || true)
CPU_REQUEST=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' || true)
MEM_REQUEST=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' || true)

if [[ -n "$CPU_LIMIT" && -n "$MEM_LIMIT" && -n "$CPU_REQUEST" && -n "$MEM_REQUEST" ]]; then
    echo "Limits e Requests trovati."
else
    echo "ERRORE: Il deployment non ha limits o requests configurati per CPU/Memoria."
    exit 1
fi

echo "--- Controllo delle best practices completato con successo! ---"
exit 0
