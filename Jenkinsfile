// Jenkinsfile per build e push di un'immagine Docker su Docker Hub

def buildAndPushMyDockerImage(config) {
    def defaults = [
        imageName: 'niccoloalfredo/flask-app-example',
        dockerHubCredsId: 'docker-hub-credentials',
        dockerfileDir: './app',
        dockerfileName: 'Dockerfile',
        gitTagName: null,
        branchName: null,
        gitCommitShortSha: null
    ]
    config = defaults + config

    def buildTag
    def shouldPushLatest = false

    if (config.gitTagName) {
        buildTag = config.gitTagName
    } else if (config.branchName == 'main' || config.branchName == 'master') {
        buildTag = 'latest'
        shouldPushLatest = true
    } else if (config.branchName == 'develop') {
        buildTag = "develop-${config.gitCommitShortSha}"
    } else if (config.branchName != null) {
        def sanitizedBranchName = config.branchName.replaceAll('/', '-')
        buildTag = "${sanitizedBranchName}-${config.gitCommitShortSha}"
    } else {
        buildTag = "commit-${config.gitCommitShortSha}"
    }

    docker.withRegistry('https://index.docker.io/v1/', config.dockerHubCredsId) {
        def image = docker.build("${config.imageName}:${buildTag}", "--target builder ${config.dockerfileDir} -f ${config.dockerfileDir}/${config.dockerfileName}")
        image.push(buildTag)
        if (shouldPushLatest) {
            image.push("latest")
        }
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
                checkout scm
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    def gitTagName = env.GIT_TAG_NAME
                    def rawBranchName = env.GIT_BRANCH ?: env.BRANCH_NAME
                    def branchName = rawBranchName ? rawBranchName.replaceFirst('^origin/', '') : null
                    def gitCommitShortSha = env.GIT_COMMIT ? env.GIT_COMMIT.substring(0, 7) : 'unknown'

                    buildAndPushMyDockerImage([
                        imageName: env.DOCKER_IMAGE_NAME,
                        dockerHubCredsId: env.DOCKER_HUB_CREDENTIALS_ID,
                        dockerfileDir: './app',
                        dockerfileName: 'Dockerfile',
                        gitTagName: gitTagName,
                        branchName: branchName,
                        gitCommitShortSha: gitCommitShortSha
                    ])
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