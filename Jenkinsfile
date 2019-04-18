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
          def newImage = docker.build(dockerImageName)
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
          def newImage = docker.build("${dockerRepoName}:production-api-${BRANCH_NAME}", "-f Dockerfile.api .")
          newImage.push()
        }
      }
    }

    stage('Build production stream Docker image') {
      when { tag 'production-release' }
      agent any
      steps {
        script {
          def newImage = docker.build("${dockerRepoName}:production-stream-${BRANCH_NAME}", "-f Dockerfile.stream .")
          newImage.push()
        }
      }
    }

    stage('Deploy staging to Kubernetes') {
      when { branch 'master' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-staging.tmpl | kubectl apply --record -f -"
      }
    }

    stage('Deploy production to Kubernetes') {
      when { tag 'production-release' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-production.tmpl | kubectl apply --record -f -"
      }
    }
  }
}
