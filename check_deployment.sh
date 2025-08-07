#!/bin/bash

# Abilita l'uscita in caso di errore
set -e

NAMESPACE="formazione-sou"
DEPLOYMENT_NAME="flask-app-example-flask-app-chart"
echo "--- Avvio il controllo delle best practices per il deployment: $DEPLOYMENT_NAME nel namespace: $NAMESPACE ---"

# ==================================
# 1. VERIFICA PRESENZA DEL DEPLOYMENT
# ==================================
echo "Recupero il manifesto del deployment..."
if ! kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.metadata.name}' > /dev/null; then
    echo "ERRORE: Deployment '$DEPLOYMENT_NAME' non trovato nel namespace '$NAMESPACE'. Controllare il nome del deployment."
    exit 1
fi
echo "Deployment trovato."

# ==================================
# 2. VERIFICA PROBE
# ==================================
echo "Verifica l'esistenza di livenessProbe e readinessProbe..."
# Usa jsonpath per verificare l'esistenza della chiave 'livenessProbe'
if kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' > /dev/null && \
   kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' > /dev/null; then
    echo "Liveness e Readiness Probe trovate."
else
    echo "ERRORE: Il deployment non ha livenessProbe o readinessProbe configurate."
    exit 1
fi

# ==================================
# 3. VERIFICA LIMITS E REQUESTS
# ==================================
echo "Verifica l'esistenza di limits e requests per CPU e Memoria..."
if kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' > /dev/null && \
   kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' > /dev/null && \
   kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' > /dev/null && \
   kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' > /dev/null; then
    echo "Limits e Requests trovati."
else
    echo "ERRORE: Il deployment non ha limits o requests configurati per CPU/Memoria."
    exit 1
fi

echo "--- Controllo delle best practices completato con successo! 🎉 ---"
exit 0