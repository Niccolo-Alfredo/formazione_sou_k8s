// Jenkinsfile
// Pipeline Jenkins dichiarativa per la build e il push di un'immagine Docker

pipeline {
    // Agente che esegue la pipeline. 'any' significa che Jenkins può usare qualsiasi agente disponibile.
    agent any

    // Variabili di ambiente globali per la pipeline
    environment {
        // Il nome dell'immagine Docker. Sostituisci 'TUO_USERNAME_DOCKERHUB' con il tuo username Docker Hub.
        // Esempio: 'myusername/flask-app-example'
        DOCKER_IMAGE_NAME = 'niccoloalfredo/flask-app-example'
        // Il tag dell'immagine. Utilizziamo il numero di build di Jenkins per un tag unico.
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    // Credenziali Jenkins:
    // Devi configurare le tue credenziali Docker Hub in Jenkins.
    // Vai su "Manage Jenkins" -> "Manage Credentials" -> "Add Credentials".
    // Tipo: "Username with password".
    // Username: Il tuo username Docker Hub
    // Password: La tua password Docker Hub
    // ID: Assegna un ID significativo, ad esempio "docker-hub-credentials"
    // Questo ID verrà usato nel blocco 'withCredentials'
    // DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-credentials' // Sostituisci con l'ID che hai configurato

    // Definizione delle fasi della pipeline
    stages {
        // Fase di Checkout del codice dal repository Git
        stage('Checkout SCM') {
            steps {
                // Clona il repository Git specificato.
                // Assicurati che il tuo job Jenkins sia configurato per usare questo SCM.
                git branch: 'main', url: 'https://github.com/Niccolo-Alfredo/formazione_sou_k8s.git' // Sostituisci con il tuo username GitHub
            }
        }

        // Fase di Build dell'immagine Docker
        stage('Build Docker Image') {
            steps {
                script {
                    // Costruisce l'immagine Docker usando la stage 'builder'
                    // Il Dockerfile si trova nella sottodirectory 'app'.
                    // Il tag dell'immagine sarà 'TUO_USERNAME_DOCKERHUB/flask-app-example:BUILD_NUMBER'
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --target builder ./app" // <-- AGGIUNGI --target builder
                    // Aggiunge un tag 'latest' all'immagine per facilità d'uso
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        // Fase di Push dell'immagine Docker su Docker Hub
        stage('Push Docker Image') {
            steps {
                // Utilizza le credenziali Docker Hub configurate in Jenkins
                // Sostituisci 'docker-hub-credentials' con l'ID delle tue credenziali Jenkins
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    script {
                        // Esegue il login a Docker Hub
                        sh "echo \"${DOCKER_PASSWORD}\" | docker login -u \"${DOCKER_USERNAME}\" --password-stdin"
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
        // Sempre esegui il logout da Docker Hub per sicurezza
        always {
            script {
                sh "docker logout"
            }
        }
        // Se la pipeline fallisce, stampa un messaggio
        failure {
            echo "Pipeline fallita. Controlla i log per i dettagli."
        }
        // Se la pipeline ha successo, stampa un messaggio
        success {
            echo "Pipeline completata con successo! Immagine Docker ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} pushata su Docker Hub."
        }
    }
}
