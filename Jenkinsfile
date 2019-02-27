#!groovy

node {
    checkout scm

    def dockerRepoName = 'zooniverse/zoo-event-stats'
    def dockerImageName = "${dockerRepoName}:${BRANCH_NAME}"
    def newImage = null

    stage('Build Docker image') {
        newImage = docker.build(dockerImageName)
        newImage.push()
    }

    if (BRANCH_NAME == 'master') {
        stage('Update latest tag') {
            newImage.push('latest')
        }

        stage('Deploy to Swarm') {
            sh """
                cd "/var/jenkins_home/jobs/Zooniverse GitHub/jobs/operations/branches/master/workspace" && \
                ./hermes_wrapper.sh exec swarm19a -- \
                    docker stack deploy --prune \
                    -c /opt/infrastructure/stacks/zoo-event-stats-staging.yml \
                    zoo-event-stats-staging
            """
        }
    }

    if (BRANCH_NAME == 'production') {
        stage('Update production tag') {
            // Ruby API image
            def apiDockerfile = 'Dockerfile.api'
            apiImage = docker.build("${dockerRepoName}:production-api", "-f ${apiDockerfile} .")
            apiImage.push('production-api')

            // KCL stream reader image
            def streamDockerfile = 'Dockerfile.stream'
            streamImage = docker.build("${dockerRepoName}:production-stream", "-f ${streamDockerfile} .")
            streamImage.push('production-stream')
        }

        stage('Deploy to Swarm') {
            sh """
                cd "/var/jenkins_home/jobs/Zooniverse GitHub/jobs/operations/branches/master/workspace" && \
                ./hermes_wrapper.sh exec swarm19a -- \
                    docker stack deploy --prune \
                    -c /opt/infrastructure/stacks/zoo-event-stats.yml \
                    zoo-event-stats
            """
        }
    }
}
