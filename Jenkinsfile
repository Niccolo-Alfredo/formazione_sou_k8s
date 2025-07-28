// Jenkinsfile
// Pipeline Jenkins dichiarativa per la build e il push di un'immagine Docker

pipeline {
    // Agente che esegue la pipeline. 'agent-1' è il nome che abbiamo dato al tuo agente.
    agent {
        node {
            label 'agent-1' // Assicurati che questo corrisponda al label del tuo Jenkins Agent
            // Se usi un workspace specifico sul tuo agente, potresti definire customWorkspace
            // customWorkspace "${env.WORKSPACE}"
        }
    }

    // Configurazione degli strumenti globali di Jenkins
    // Assicurati che lo strumento Git sia configurato in "Manage Jenkins" -> "Global Tool Configuration"
    // con il nome 'DefaultGit' (o il nome che gli hai dato).
    tools {
        git 'DefaultGit' // Questo associa lo strumento Git configurato globalmente
    }

    // Variabili di ambiente globali per la pipeline
    environment {
        // Il nome dell'immagine Docker. Sostituisci 'niccoloalfredo' con il tuo username Docker Hub.
        DOCKER_IMAGE_NAME = 'niccoloalfredo/flask-app-example'
        // Il tag dell'immagine. Utilizziamo il numero di build di Jenkins per un tag unico.
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}"
        // L'ID delle credenziali Docker Hub configurate in Jenkins
        // Devi configurare le tue credenziali Docker Hub in Jenkins:
        // "Manage Jenkins" -> "Manage Credentials" -> "(global)" -> "Add Credentials"
        // Tipo: "Username with password", ID: "docker-hub-credentials", Username/Password del tuo Docker Hub.
        DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-credentials'
    }

    // Definizione delle fasi della pipeline
    stages {
        // Fase di Checkout del codice dal repository Git
        // La fase 'Declarative: Checkout SCM' è spesso gestita automaticamente dalla Pipeline Dichiarativa
        // quando il job è configurato con "Pipeline script from SCM".
        // Manteniamo una fase esplicita per maggiore chiarezza se necessario, ma non è strettamente obbligatoria se il SCM è configurato a livello di job.
        stage('Checkout SCM') {
            steps {
                // Clona il repository Git specificato.
                // L'uso di "scm" qui si riferisce alla configurazione SCM del job Jenkins.
                // Se la tua repo è privata, assicurati che le credenziali siano impostate a livello di job.
                git branch: 'main', url: 'https://github.com/Niccolo-Alfredo/formazione_sou_k8s.git'
            }
        }

        // Fase di Build dell'immagine Docker
        stage('Build Docker Image') {
            steps {
                script {
                    // Costruisce l'immagine Docker.
                    // Il Dockerfile si trova nella sottodirectory 'app'.
                    // Il tag dell'immagine sarà 'niccoloalfredo/flask-app-example:BUILD_NUMBER'
                    // L'opzione --target builder assicura che venga costruita solo la stage di produzione del Dockerfile.
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --target builder ./app"
                    // Aggiunge un tag 'latest' all'immagine per facilità d'uso
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        // Fase di Push dell'immagine Docker su Docker Hub
        stage('Push Docker Image') {
            steps {
                // Utilizza 'withDockerRegistry' per gestire il login/logout in modo sicuro.
                // Non è più necessario usare 'withCredentials' e 'docker login/logout' espliciti.
                withDockerRegistry(credentialsId: DOCKER_HUB_CREDENTIALS_ID, url: 'https://index.docker.io/v1/') {
                    script {
                        // Effettua il push dell'immagine con il tag specifico (BUILD_NUMBER)
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        // Effettua il push dell'immagine con il tag 'latest'
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }

    // Post-azioni (eseguite dopo che tutte le fasi sono completate)
    post {
        // Le azioni di login/logout sono gestite automaticamente da withDockerRegistry,
        // quindi non è necessario un 'always { docker logout }' esplicito qui.
        failure {
            echo "Pipeline fallita. Controlla i log per i dettagli."
        }
        success {
            echo "Pipeline completata con successo! Immagine Docker ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} pushata su Docker Hub."
        }
    }
}