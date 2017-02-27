try {
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
                        ssh ocfdeploy@puppet 'sudo /opt/puppetlabs/scripts/update-prod'
                '''
            }
        }
    }

} catch (err) {
    def subject = "${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - Failure!"
    def message = "${env.JOB_NAME} (#${env.BUILD_NUMBER}) failed: ${env.BUILD_URL}"

    if (env.BRANCH_NAME == 'master') {
        slackSend color: '#FF0000', message: message
        mail to: 'root@ocf.berkeley.edu', subject: subject, body: message
    } else {
        mail to: emailextrecipients([
            [$class: 'CulpritsRecipientProvider'],
            [$class: 'DevelopersRecipientProvider']
        ]), subject: subject, body: message
    }

    throw err
}

// vim: ft=groovy
