// Jenkinsfile
// Pipeline Jenkins dichiarativa per la build e il push di un'immagine Docker

// Definizione della funzione helper per la build e il push dell'immagine Docker
// Questa funzione incapsula la logica di tagging e interazione con Docker Hub.
def buildAndPushMyDockerImage(config) {
    // Definisci i valori predefiniti per i parametri della funzione
    def defaults = [
        imageName: 'niccoloalfredo/flask-app-example', // Sostituisci con il tuo username Docker Hub
        dockerHubCredsId: 'docker-hub-credentials',
        dockerfileDir: './app',
        dockerfileName: 'Dockerfile',
        gitTagName: null,
        branchName: null,
        gitCommitShortSha: null
    ]
    // Unisci i parametri forniti con i valori predefiniti
    config = defaults + config

    def buildTag // Il tag che useremo per la build e il push principale
    def shouldPushLatest = false // Flag per decidere se pushare anche il tag 'latest'

    // Logica per determinare il tag dell'immagine Docker
    if (config.gitTagName) {
        // Caso 1: Build da un tag Git
        buildTag = config.gitTagName
        echo "Building from Git tag: '${buildTag}'"
    } else if (config.branchName == 'main' || config.branchName == 'master') {
        // Caso 2: Build dal branch 'main' (o 'master')
        buildTag = 'latest' // Il tag principale per la main è 'latest'
        shouldPushLatest = true // In questo caso, pushiamo anche il tag 'latest'
        echo "Building from '${config.branchName}' branch. Image tag will be: '${buildTag}'"
    } else if (config.branchName == 'develop') {
        // Caso 3: Build dal branch 'develop'
        buildTag = "develop-${config.gitCommitShortSha}"
        echo "Building from 'develop' branch. Image tag will be: '${buildTag}'"
    } else if (config.branchName != null) { // Questo gestisce altri branch come 'feature/xyz'
        // Caso 4: Build da altri branch (es. feature branches)
        // Sostituisce i '/' con '-' per avere un tag Docker valido
        def sanitizedBranchName = config.branchName.replaceAll('/', '-')
        buildTag = "${sanitizedBranchName}-${config.gitCommitShortSha}"
        echo "Building from branch '${config.branchName}'. Image tag will be: '${buildTag}'"
    } else {
        // Caso di fallback: branchName è nullo (es. build triggerata da un SHA specifico, non un branch o tag)
        // Utilizziamo un tag basato sull'SHA del commit per chiarezza.
        buildTag = "commit-${config.gitCommitShortSha}"
        echo "Warning: Branch name is null and not a tag build. Building with tag: '${buildTag}'"
    }

    // Interazione con Docker Hub in modo sicuro usando le credenziali Jenkins
    docker.withRegistry('https://index.docker.io/v1/', config.dockerHubCredsId) {
        // Costruisci l'immagine Docker
        // Usiamo il 'buildTag' determinato dalla logica
        // --target builder specifica la fase di build leggera nel Dockerfile
        // -f specifica il Dockerfile
        def image = docker.build("${config.imageName}:${buildTag}", "--target builder ${config.dockerfileDir} -f ${config.dockerfileDir}/${config.dockerfileName}")
        echo "Docker image built: ${config.imageName}:${buildTag}"

        // Push dell'immagine con il tag specifico (es. v1.0.0, develop-SHA, latest)
        image.push(buildTag)
        echo "Pushed ${config.imageName}:${buildTag} to Docker Hub."

        // Se la build proviene dal branch 'main', pushiamo anche il tag 'latest'
        if (shouldPushLatest) {
            // L'oggetto 'image' ha già il riferimento all'immagine con il buildTag,
            // pushare 'latest' automaticamente la tagga localmente e poi la pusha.
            image.push("latest")
            echo "Pushed ${config.imageName}:latest to Docker Hub (from ${config.branchName} branch)."
        }

        // Opzionale: pulizia delle immagini Docker locali dopo il push
        // Commentato per default in quanto Jenkins spesso gestisce la pulizia degli agenti
        // sh "docker rmi --force ${config.imageName}:${buildTag}"
        // if (shouldPushLatest) {
        //     sh "docker rmi --force ${config.imageName}:latest"
        // }
    }
}


pipeline {
    // Agente che esegue la pipeline. 'agent-1' è il nome che abbiamo dato al tuo agente.
    agent {
        node {
            label 'agent-1'
        }
    }

    // Configurazione degli strumenti globali di Jenkins
    tools {
        git 'Default' // Nome dello strumento Git configurato globalmente in Jenkins
    }

    // Variabili di ambiente globali per la pipeline
    environment {
        // Il nome base dell'immagine Docker. Sostituisci 'niccoloalfredo' con il tuo username Docker Hub.
        DOCKER_IMAGE_NAME = 'niccoloalfredo/flask-app-example'
        // L'ID delle credenziali Docker Hub configurate in Jenkins
        DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-credentials'
    }

    // Definizione delle fasi della pipeline
    stages {
        // Fase di Checkout del codice dal repository Git
        stage('Checkout SCM') {
            steps {
                // Clona il repository Git specificato.
                // Usiamo 'checkout scm' per sfruttare la configurazione SCM del job Jenkins,
                // che ora dovrebbe essere impostata per monitorare tutti i branch e tag.
                checkout scm
            }
        }

        // Fase che combina la determinazione del tag, la build e il push dell'immagine Docker
        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Preleva le informazioni necessarie dal contesto di Jenkins
                    // env.GIT_TAG_NAME è popolato solo se la build è da un tag Git
                    def gitTagName = env.GIT_TAG_NAME
                    // env.BRANCH_NAME contiene il nome del branch (es. 'main', 'develop', 'feature/xyz')
                    // Questo è il modo più affidabile per ottenere il nome del branch per le build da branch.
                    def branchName = env.BRANCH_NAME
                    // env.GIT_COMMIT contiene l'SHA completo del commit Git
                    def gitCommitShortSha = env.GIT_COMMIT ? env.GIT_COMMIT.substring(0, 7) : 'unknown'

                    // Chiama la funzione helper per eseguire la logica di build e push
                    buildAndPushMyDockerImage(
                        imageName: DOCKER_IMAGE_NAME,
                        dockerHubCredsId: DOCKER_HUB_CREDENTIALS_ID,
                        gitTagName: gitTagName,
                        branchName: branchName, // Ora dovrebbe essere corretto
                        gitCommitShortSha: gitCommitShortSha
                    )
                }
            }
        }
    }

    // Post-azioni (eseguite dopo che tutte le fasi sono completate)
    post {
        failure {
            echo "Pipeline failed. Check logs for details."
        }
        success {
            echo "Pipeline completed successfully! Docker images pushed to Docker Hub."
        }
    }
}