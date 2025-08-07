import os
import sys
from kubernetes import client, config

def main():
    """
    Script per verificare le best practice di un deployment di Kubernetes.
    """
    namespace = "formazione-sou"
    deployment_name = "flask-app-example-flask-app-chart"

    print("--- Avvio il controllo delle best practices per il deployment: "
          f"{deployment_name} nel namespace: {namespace} ---")

    try:
        # Carica la configurazione del cluster dall'ambiente in cui lo script viene eseguito
        # Questo userà il Service Account del Pod Jenkins
        config.load_incluster_config()
        v1 = client.AppsV1Api()
    except Exception as e:
        print(f"ERRORE: Impossibile connettersi all'API di Kubernetes. {e}")
        sys.exit(1)

    try:
        # Recupera il manifesto del deployment
        deployment = v1.read_namespaced_deployment(name=deployment_name, namespace=namespace)
        print("✅ Deployment trovato.")
    except client.ApiException as e:
        if e.status == 404:
            print(f"ERRORE: Deployment '{deployment_name}' non trovato nel namespace '{namespace}'.")
        else:
            print(f"ERRORE: Errore durante il recupero del deployment. {e}")
        sys.exit(1)

    container = deployment.spec.template.spec.containers[0]

    # ==================================
    # 1. VERIFICA PROBE
    # ==================================
    print("Verifica l'esistenza di livenessProbe e readinessProbe...")
    if not container.liveness_probe or not container.readiness_probe:
        print("ERRORE: Il deployment non ha livenessProbe o readinessProbe configurate.")
        sys.exit(1)
    print("✅ Liveness e Readiness Probe trovate.")

    # ==================================
    # 2. VERIFICA LIMITS E REQUESTS
    # ==================================
    print("Verifica l'esistenza di limits e requests per CPU e Memoria...")
    resources = container.resources
    if (not resources or
        not resources.limits or
        not resources.requests or
        'cpu' not in resources.limits or
        'memory' not in resources.limits or
        'cpu' not in resources.requests or
        'memory' not in resources.requests):
        print("ERRORE: Il deployment non ha limits o requests configurati per CPU/Memoria.")
        sys.exit(1)
    print("✅ Limits e Requests trovati.")

    print("--- Controllo delle best practices completato con successo! 🎉 ---")
    sys.exit(0)

if __name__ == "__main__":
    main()