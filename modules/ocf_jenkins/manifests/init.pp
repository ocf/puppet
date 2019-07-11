class ocf_jenkins {
  include ocf::extrapackages
  include ocf::firewall::allow_web
  include ocf::tmpfs
  include ocf::ssl::default

  class { 'ocf::packages::docker':
    autoclean => false,
  }

  class { 'ocf_ocfweb::dev_config':
    group   => 'jenkins-slave',
    require => User['jenkins-slave'],
  }

  class { 'ocf_jenkins::jenkins_apt':
    stage => first,
  }

  file {
    '/etc/ocf-kubernetes':
      ensure => 'directory',
      purge  => true,
  }

  file {
    '/etc/ocf-kubernetes/secrets':
      ensure  => 'directory',
      source  => 'puppet:///kubernetes-secrets',
      recurse => true,
      purge   => true,
      owner   => jenkins-deploy,
      group   => jenkins-deploy,
      mode    => '0700';
  }

  include ocf_jenkins::proxy

  package { 'jenkins':; }
  service { 'jenkins':
    require => Package['jenkins'];
  }

  augeas { '/etc/default/jenkins':
    context => '/files/etc/default/jenkins',
    changes => [
      'set JAVA_ARGS \'"-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dhudson.model.ParametersAction.safeParameters=ghprbActualCommit,ghprbActualCommitAuthor,ghprbActualCommitAuthorEmail,ghprbAuthorRepoGitUrl,ghprbCommentBody,ghprbCredentialsId,ghprbGhRepository,ghprbPullAuthorEmail,ghprbPullAuthorLogin,ghprbPullAuthorLoginMention,ghprbPullDescription,ghprbPullId,ghprbPullLink,ghprbPullLongDescription,ghprbPullTitle,ghprbSourceBranch,ghprbTargetBranch,ghprbTriggerAuthor,ghprbTriggerAuthorEmail,ghprbTriggerAuthorLogin,ghprbTriggerAuthorLoginMention,GIT_BRANCH,sha1 -Djenkins.branch.WorkspaceLocatorImpl.PATH_MAX=0 -Xmx1024m"\'',
    ],
    require => Package['jenkins'],
    notify  => Service['jenkins'];
  }

  file {
    '/opt/jenkins':
      ensure => directory;

    '/opt/jenkins/launch-slave':
      source => 'puppet:///modules/ocf_jenkins/launch-slave',
      mode   => '0755';

    ['/opt/jenkins/slave', '/opt/jenkins/slave/workspace']:
      ensure => directory,
      owner  => jenkins-slave,
      group  => jenkins-slave;

    '/etc/sudoers.d/jenkins-slave':
      content => "jenkins ALL=(jenkins-slave) NOPASSWD: ALL\n";

    '/opt/jenkins/deploy':
      ensure => directory,
      owner  => jenkins-deploy,
      group  => jenkins-deploy;

    '/opt/jenkins/deploy/ocfdeploy.keytab':
      source    => 'puppet:///private/ocfdeploy.keytab',
      owner     => root,
      group     => jenkins-deploy,
      mode      => '0640',
      show_diff => false;

    '/opt/jenkins/deploy/.pypirc':
      source    => 'puppet:///private/pypirc',
      owner     => root,
      group     => jenkins-deploy,
      mode      => '0640',
      show_diff => false;

    '/opt/jenkins/deploy/.docker':
      ensure => directory,
      owner  => root,
      group  => jenkins-deploy,
      mode   => '0750';

    '/opt/jenkins/deploy/.docker/config.json':
      source    => 'puppet:///private/docker-config.json',
      owner     => root,
      group     => jenkins-deploy,
      mode      => '0640',
      show_diff => false;

    '/opt/jenkins/deploy/ssh_cli':
      source    => 'puppet:///private/ssh_cli',
      owner     => jenkins-deploy,
      group     => jenkins-deploy,
      mode      => '0640',
      show_diff => false;

    '/opt/jenkins/update-plugins':
      source => 'puppet:///modules/ocf_jenkins/update-plugins',
      mode   => '0750';

    '/etc/sudoers.d/jenkins-deploy':
      content => "jenkins ALL=(jenkins-deploy) NOPASSWD: ALL\n",
      owner   => root,
      group   => root;
  }

  # We set up two separate jenkins users:
  #
  #   - jenkins-slave:
  #         Used for running build jobs with possibly untrusted code.
  #   - jenkins-deploy:
  #         Used for running *trusted* deploy jobs from a user that has access
  #         to the ocfdeploy keytab. This user should NEVER run untrusted code.
  #
  # This is in addition to the `jenkins` user that is configured by the
  # Debian package, which is used for hosting the Jenkins master.
  #
  # Within Jenkins, we configure two "slaves" which are really the same server,
  # but launched by executing the slave.jar binaries as the appropriate users
  # (via sudo). We then set access controls on the jobs so that only trusted
  # jobs run as `jenkins-deploy`.
  #
  # This is a bit complicated, but it allows us both better security (we no
  # longer have to worry that anybody who can get some code built can become
  # ocfdeploy, which is a privileged user account) and protects Jenkins
  # somewhat against bad jobs that might e.g. delete files or crash processes.
  #
  # Of course, in many cases once code builds successfully, we ship it off
  # somewhere where it gets effectively run as root anyway. But this feels a
  # little safer.
  user {
    default:
      groups  => ['sys', 'docker'],
      shell   => '/bin/bash',
      require => Package['docker-ce'];

    'jenkins-slave':
      comment => 'OCF Jenkins Slave',
      home    => '/opt/jenkins/slave/';

    'jenkins-deploy':
      comment => 'OCF Jenkins Deploy',
      home    => '/opt/jenkins/deploy/';
  }

  # mount jenkins slave workspace as tmpfs for speed
  mount { '/opt/jenkins/slave/workspace':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'noatime,nodev,nosuid,uid=jenkins-slave,gid=jenkins-slave,mode=755',
    require => [File['/opt/jenkins/slave/workspace'], User['jenkins-slave']];
  }

  # Autoclean /var/lib/docker when it's too full. This filesystem on the Jenkins
  # server tends to fill up much faster than our regular cronjobs can clean it.
  file { '/opt/jenkins/autoclean-docker':
    source => 'puppet:///modules/ocf_jenkins/autoclean-docker',
    mode   => '0755',
  } ->
  cron { 'clean-old-docker-garbage-jenkins':
    command => 'chronic /opt/jenkins/autoclean-docker',
    minute  => '*/5',
  }

  # Install plugin updates for Jenkins
  cron { 'update-jenkins-plugins':
    command => '/opt/jenkins/update-plugins',
    user    => root,
    special => 'weekly',
  }

  ocf::firewall::firewall46 { '899 allow jenkins to send mail':
    opts    => {
      chain  => 'PUPPET-OUTPUT',
      uid    => 'jenkins',
      proto  => 'tcp',
      dport  => 25,
      action => 'accept',
    },
    # Require the jenkins user to have been created already
    require => Package['jenkins'],
  }
}
