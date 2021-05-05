#!groovy

def dockerRepoName = 'zooniverse/zoo-event-stats'

pipeline {
  agent none

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Build Docker image') {
      agent any
      steps {
        script {
          stage('Build API image') {
            def buildArgs = "--build-arg REVISION='${GIT_COMMIT}' -f Dockerfile.api ."
            def newImage = docker.build("${dockerRepoName}:api-${GIT_COMMIT}", buildArgs)
            newImage.push()

            if (BRANCH_NAME == 'master') {
              stage('Update api image latest tag') {
                // as this repo builds two distinct image artefacts, so after this change
                // zooniverse/zoo-event-stats:latest doesn't mean anything anymore
                // instead each image will have it's own latest tag
                // e.g. zooniverse/zoo-event-stats:api-latest & zooniverse/zoo-event-stats:stream-latest
                newImage.push('api-latest')
              }
            }
          }

          stage('Build Stream Image') {
            def buildArgs = "-f Dockerfile.stream ."
            def newImage = docker.build("${dockerRepoName}:stream-${GIT_COMMIT}", buildArgs)
            newImage.push()

            if (BRANCH_NAME == 'master') {
              stage('Update stream image latest tag') {
                newImage.push('stream-latest')
              }
            }
          }
        }
      }
    }

    stage('Build production API Docker image') {
      when { tag 'production-release' }
      agent any
      steps {
        script {
          def buildArgs = "--build-arg REVISION='${GIT_COMMIT}' -f Dockerfile.api ."
          def newImage = docker.build("${dockerRepoName}:production-api-${GIT_COMMIT}", buildArgs)
          newImage.push()
        }
      }
    }

    stage('Build production stream Docker image') {
      when { tag 'production-release' }
      agent any
      steps {
        script {
          def newImage = docker.build("${dockerRepoName}:production-stream-${GIT_COMMIT}", "-f Dockerfile.stream .")
          newImage.push()
        }
      }
    }

    stage('Dry run deployments') {
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-staging.tmpl | kubectl --context azure apply --dry-run=server --record -f -"
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-production.tmpl | kubectl --context azure apply --dry-run=server --record -f -"
      }
    }

    stage('Deploy staging to Kubernetes') {
      when { branch 'master' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-staging.tmpl | kubectl --context azure apply --record -f -"
      }
    }

    stage('Deploy production to Kubernetes') {
      when { tag 'production-release' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-production.tmpl | kubectl --context azure apply --record -f -"
      }
    }
  }
}
