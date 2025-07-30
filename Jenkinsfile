// Jenkinsfile(check)

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
        branchName: null, // Questo sarà il nome del branch effettivo o null
        gitCommitShortSha: null
    ]
    // Unisci i parametri forniti con i valori predefiniti
    config = defaults + config

    def buildTag // Il tag che useremo per la build e il push principale
    def shouldPushLatest = false // Flag per decidere se pushare anche il tag 'latest'

    // Logica per determinare il tag dell'immagine Docker
    if (config.gitTagName) {
        // Caso 1: Build da un tag Git (env.GIT_TAG_NAME è popolato)
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
    } else if (config.branchName != null) {
        // Caso 4: Build da altri branch (es. feature branches), quando branchName è popolato
        // Sostituisce i '/' con '-' per avere un tag Docker valido
        def sanitizedBranchName = config.branchName.replaceAll('/', '-')
        buildTag = "${sanitizedBranchName}-${config.gitCommitShortSha}"
        echo "Building from branch '${config.branchName}'. Image tag will be: '${buildTag}'"
    } else {
        // Caso di fallback: branchName è nullo e non è un tag Git esplicito.
        // Questo può succedere se env.BRANCH_NAME e env.GIT_TAG_NAME sono entrambi nulli,
        // o se la build è triggerata da un SHA specifico non associato a un branch/tag noto.
        buildTag = "commit-${config.gitCommitShortSha}"
        echo "Warning: Branch name is null or could not be determined. Building with tag: '${buildTag}'"
    }

    // Interazione con Docker Hub in modo sicuro usando le credenziali Jenkins
    // Questo blocco gestisce l'autenticazione Docker Hub in modo sicuro.
    // NON ci dovrebbero essere chiamate esplicite a `docker login` qui.
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
    agent {
        node {
            label 'agent-1'
        }
    }

    tools {
        git 'Default'
    }

    environment {
        DOCKER_IMAGE_NAME = 'niccoloalfredo/flask-app-example'
        DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-credentials'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: scm.branches,
                        userRemoteConfigs: scm.userRemoteConfigs,
                        extensions: scm.extensions + [
                            [$class: 'CloneOption',
                             noTags: false,
                             shallow: false,
                             depth: 0,
                             timeout: 10]
                        ],
                        doGenerateSubmoduleConfigurations: false,
                        submoduleCfg: [],
                        refspec: '+refs/heads/*:refs/remotes/origin/* +refs/tags/*:refs/tags/*'
                    ])

                    // Imposta GIT_TAG_NAME se è un build da tag
                    def tagOutput = sh(script: "git describe --tags --exact-match || true", returnStdout: true).trim()
                    if (tagOutput) {
                        env.GIT_TAG_NAME = tagOutput
                        echo "Detected Git tag: ${env.GIT_TAG_NAME}"
                    } else {
                        echo "No Git tag detected for this build."
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    echo "--- DEBUG VARIABILI AMBIENTE GIT ---"
                    echo "env.GIT_TAG_NAME: ${env.GIT_TAG_NAME}"
                    echo "env.BRANCH_NAME: ${env.BRANCH_NAME}"
                    echo "env.GIT_BRANCH: ${env.GIT_BRANCH}"
                    echo "env.GIT_COMMIT: ${env.GIT_COMMIT}"

                    def gitTagName = env.GIT_TAG_NAME
                    def rawBranchName = env.GIT_BRANCH ?: env.BRANCH_NAME
                    def branchName = rawBranchName ? rawBranchName.replaceFirst('^origin/', '') : null
                    def gitCommitShortSha = env.GIT_COMMIT ? env.GIT_COMMIT.substring(0, 7) : 'unknown'

                    echo "--- DEBUG VARIABILI PASSATE ALLA FUNZIONE ---"
                    echo "gitTagName (passato): ${gitTagName}"
                    echo "branchName (passato, pulito): ${branchName}"
                    echo "gitCommitShortSha (passato): ${gitCommitShortSha}"

                    // buildAndPushMyDockerImage(...) è momentaneamente disattivata per il debug
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed. Check logs for details."
        }
        success {
            echo "Pipeline completed successfully! Docker images pushed to Docker Hub."
        }
    }
}