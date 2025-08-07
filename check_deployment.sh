#!/bin/bash

# Uscita immediata se un comando fallisce
set -e

NAMESPACE="formazione-sou"
DEPLOYMENT_NAME="flask-app-example-flask-app-chart"
echo "--- Avvio il controllo delle best practices per il deployment: $DEPLOYMENT_NAME nel namespace: $NAMESPACE ---"

# Recupera il manifesto del deployment in formato JSON
echo "Recupero il manifesto del deployment..."
# Reindirizza l'errore standard per nascondere eventuali messaggi di avviso
DEPLOYMENT_JSON=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o json 2>/dev/null)

if [ -z "$DEPLOYMENT_JSON" ]; then
    echo "ERRORE: Deployment '$DEPLOYMENT_NAME' non trovato nel namespace '$NAMESPACE'. Controllare il nome del deployment."
    exit 1
fi

# ==================================
# 1. VERIFICA PROBE
# ==================================
echo "Verifica l'esistenza di livenessProbe e readinessProbe..."
# `jq` è un tool a riga di comando per processare dati JSON
# Il comando controlla se la chiave 'livenessProbe' o 'readinessProbe' ha un valore 'null'
if echo $DEPLOYMENT_JSON | jq '.spec.template.spec.containers[0].livenessProbe' | grep -q 'null' || \
   echo $DEPLOYMENT_JSON | jq '.spec.template.spec.containers[0].readinessProbe' | grep -q 'null'; then
    echo "ERRORE: Il deployment non ha livenessProbe o readinessProbe configurate."
    exit 1
fi
echo "Liveness e Readiness Probe trovate."

# ==================================
# 2. VERIFICA LIMITS E REQUESTS
# ==================================
echo "Verifica l'esistenza di limits e requests per CPU e Memoria..."
if echo $DEPLOYMENT_JSON | jq '.spec.template.spec.containers[0].resources.limits.cpu' | grep -q 'null' || \
   echo $DEPLOYMENT_JSON | jq '.spec.template.spec.containers[0].resources.requests.cpu' | grep -q 'null' || \
   echo $DEPLOYMENT_JSON | jq '.spec.template.spec.containers[0].resources.limits.memory' | grep -q 'null' || \
   echo $DEPLOYMENT_JSON | jq '.spec.template.spec.containers[0].resources.requests.memory' | grep -q 'null'; then
    echo "ERRORE: Il deployment non ha limits o requests configurati per CPU/Memoria."
    exit 1
fi
echo "Limits e Requests trovati."

# Se tutti i controlli passano, lo script termina con successo
echo "--- Controllo delle best practices completato con successo! 🎉 ---"
exit 0