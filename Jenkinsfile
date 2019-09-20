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
      // Don't run this on the master branch yet, since it's really made for
      // testing PRs and changes, it should always show no diffs on master.
      // However, it might be useful on master in the future in some kind of
      // mode to just show that all catalogs actually compile.
      when {
        not {
          branch 'master'
        }
      }
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
        sh 'make all_diffs'
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
