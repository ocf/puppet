class ocf_mirrors::kali {
  ocf_mirrors::ftpsync {
    'kali':
      # TODO: Change these to archive.kali.org afer we become an official mirror
      rsync_host  => 'archive.linux.duke.edu',
      cron_minute => '15';

    'kali-images':
      rsync_host  => 'archive.linux.duke.edu',
      rsync_extra => '--block-size=8192',
      cron_minute => '25';
  }

  ocf_mirrors::monitoring { 'kali':
    type          => 'ftpsync',
    dist_to_check => 'kali-rolling',
    upstream_host => 'archive.kali.org';
  }

  # Taken from http://docs.kali.org/community/kali-linux-mirrors
  # Key can be found at http://archive.kali.org/pushmirror.pub
  ssh_authorized_key { 'kali-push@mirrors':
    ensure  => present,
    user    => 'mirrors',
    type    => 'ssh-rsa',
    options => [
      'no-port-forwarding',
      'no-X11-forwarding',
      'no-agent-forwarding',
      'no-pty',
      'command="BASEDIR=/opt/mirrors/project/kali /opt/mirrors/project/kali/bin/ftpsync"'
    ],
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDAtCI3JKfvnREbPIa7n1ewpe9SxXg5/5S84630zoFVDf03wKDdFEmR97ezLZELKt4vo1O5aj/TQ4tkPWNmagoZC6anWmIA/+/ekhB9IjQk/cJksk9alHIR2S76Itn3bJ1ofJeLeQrXdqeo/PBTiDlywIOZVQczXKfPjOfAxvMZFig/FczVmMHfC0Q2pp6V7hnqXMeE3oKn5ByygoqD7vQUygIFhwO3QqCX5QIU50d6QD21ujcYuQG+Cj02sKOqi8A+lDbCVWrhUS2ltw3IwYlCddISbClxkmbAANlvHqeoyPKHsn3bvZkua0gowTBYaAh5d7tn91fQ21g9veDPAs6x',
  }
}
