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
          def dockerImageName = "${dockerRepoName}:${BRANCH_NAME}"
          def buildArgs = "--build-arg REVISION='${GIT_COMMIT}' ."
          def newImage = docker.build(dockerImageName, buildArgs)
          newImage.push()
          newImage.push('${GIT_COMMIT}')

          if (BRANCH_NAME == 'master') {
            stage('Update latest tag') {
              newImage.push('latest')
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
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-staging.tmpl | kubectl --context azure apply --dry-run=client --record -f -"
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-production.tmpl | kubectl --context azure apply --dry-run=client --record -f -"
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
