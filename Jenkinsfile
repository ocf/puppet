node('slave') {
    step([$class: 'WsCleanup'])

    stage('check-out-code') {
        checkout scm
    }

    stage('install-dependencies') {
        sh 'make vendor'
    }

    stage('test') {
        sh 'make test'
    }

    stash 'src'
}


if (env.BRANCH_NAME == 'master') {
    node('deploy') {
        step([$class: 'WsCleanup'])
        unstash 'src'

        stage('update-prod') {
            sh '''
                kinit -t /opt/jenkins/deploy/ocfdeploy.keytab ocfdeploy
                    ssh ocfdeploy@puppet 'sudo /opt/puppet/scripts/update-prod'
            '''
        }
    }
}
