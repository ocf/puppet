@Library('shared-ocf-pipeline@add-create-gist') _

pipeline {
  agent {
    label 'slave'
  }

  options {
    ansiColor('xterm')
    timeout(time: 1, unit: 'HOURS')
    timestamps()
  }

  stages {
   stage('check-gh-trust') {
      steps {
        checkGitHubAccess()
      }
    }

    stage('install-dependencies') {
      steps {
        sh 'make vendor'
      }
    }

    stage('test') {
      steps {
        sh 'make test'
      }
    }

    stage('octocatalog-diff') {
      steps {
        // Fetch in the master branch so that octocatalog-diff can diff against
        // it. Jenkins by default only clones in branches that are needed and
        // doesn't add any others.
        //
        // See https://github.com/allegro/axion-release-plugin/issues/195 and
        // https://medium.com/rocket-travel-engineering/running-advanced-git-commands-in-a-declarative-multibranch-jenkinsfile-e82b075dbc53
        // for example
        sh 'git config --add remote.origin.fetch +refs/heads/master:refs/remotes/origin/master'
        sh 'git fetch --no-tags'

        script {
          // This should only run for pull requests, so that it is able to post
          // change/failure comments on the review
          if (env.CHANGE_ID) {
            // Unfortunately both the output and the status code cannot be
            // saved at the same time (thanks jenkins, see
            // https://issues.jenkins-ci.org/browse/JENKINS-44930), so the
            // output is saved to a file and then used soon after
            def status = sh returnStatus: true, script: 'make all_diffs > all_diffs_output.log'
            // GitHub has a max comment length of 65536, so create a gist and
            // link to that if necessary
            def output = readFile('all_diffs_output.log').trim()
            def charLimit = 65536
            if (output.length() > charLimit) {
              def url = createGist(output)
              pullRequest.comment('**WARNING: Test output is too long for a GitHub comment, posted to a gist instead**: ' + url)
            } else {
              pullRequest.comment(output)
            }

            if (status != 0) {
              currentBuild.result = 'FAILURE'
            }
          }
        }
      }
    }

    stage('update-prod') {
      when {
        branch 'master'
      }
      agent {
        label 'deploy'
      }
      steps {
        sh '''
            kinit -t /opt/jenkins/deploy/ocfdeploy.keytab ocfdeploy
                ssh ocfdeploy@puppet 'sudo /opt/puppetlabs/scripts/update-prod'
        '''
      }
    }

    // This stage is positioned after the one to update prod so it does not
    // block updates deploying until it's been tested further
    stage('octocatalog-diff-master') {
      when {
        branch 'master'
      }
      steps {
        script {
          // This should always pass since it's comparing master against
          // itself. If it does not pass, this indicates something wrong with
          // the octocatalog-diff test setup (like a dummy secret that needs
          // adding), some transient failure (inability to contact puppetdb for
          // instance), or catalog compilation issues
          sh 'make all_diffs'
        }
      }
    }
  }

  post {
    failure {
      emailNotification()
    }
    always {
      node(label: 'slave') {
        ircNotification()
      }
    }
  }
}

// vim: ft=groovy
