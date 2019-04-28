class ocf_kubernetes::master::webui {
  file {
    '/opt/share/kubernetes-admin-groups':
      content => 'ocfroot\n';

    '/opt/share/kubernetes-viewer-groups':
      content => 'ocfstaff\n';

    '/etc/pam.d/kubernetes_admin_webui':
      source  => 'puppet:///modules/ocf_kubernetes/webui/kubernetes_admin_webui',
      require => File['/opt/share/kubernetes-admin-groups'];

    '/etc/pam.d/kubernetes_viewer_webui':
      source  => 'puppet:///modules/ocf_kubernetes/webui/kubernetes_viewer_webui',
      require => File['/opt/share/kubernetes-viewer-groups'];

    '/etc/ocf-kubernetes/manifests/webui.yaml':
      source => 'puppet:///modules/ocf_kubernetes/webui/webui.yaml';

    '/etc/ocf-kubernetes/manifests/webui-ingress.yaml':
      source => 'puppet:///modules/ocf_kubernetes/webui/webui-ingress.yaml';
  }

  ocf_kubernetes::apply {
    'webui':
      target    => '/etc/ocf-kubernetes/manifests/webui.yaml',
      subscribe => File['/etc/ocf-kubernetes/manifests/webui.yaml'];

    'ingress':
      target    => '/etc/ocf-kubernetes/manifests/webui-ingress.yaml',
      subscribe => File['/etc/ocf-kubernetes/manifests/webui-ingress.yaml'];
  }

  $kubernetes_admin_token = lookup('kubernetes::admin_token')
  $kubernetes_viewer_token = lookup('kubernetes::viewer_token')

  nginx::resource::server {
    'kubernetes-admin':
      server_name      => ['kubeadmin.ocf.berkeley.edu'],
      proxy            => 'http://kubernetes',
      proxy_set_header => [
        'Host $host',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'X-Forwarded-Proto $scheme',
        'X-Real-IP $remote_addr',
        "Authorization 'Bearer ${kubernetes_admin_token}'",
      ],

      listen_port      => 443,
      ssl              => true,
      ssl_cert         => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key          => "/etc/ssl/private/${::fqdn}.key",
      ssl_dhparam      => '/etc/ssl/dhparam.pem',

      add_header       => {
        'Strict-Transport-Security' =>  'max-age=31536000',
      },

      # has a sensitive authorization header
      mode             => '0600',

      raw_append       => [
        'auth_pam "OCF Kubernetes Admin";',
        'auth_pam_service_name kubernetes_admin_webui;',
      ],

      require          =>  File['/etc/pam.d/kubernetes_admin_webui'];

    'kubernetes-viewer':
      server_name      => ['kube.ocf.berkeley.edu'],
      proxy            => 'http://kubernetes',
      proxy_set_header => [
        'Host $host',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'X-Forwarded-Proto $scheme',
        'X-Real-IP $remote_addr',
        "Authorization 'Bearer ${kubernetes_viewer_token}'",
      ],

      listen_port      => 443,
      ssl              => true,
      ssl_cert         => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key          => "/etc/ssl/private/${::fqdn}.key",
      ssl_dhparam      => '/etc/ssl/dhparam.pem',

      add_header       => {
        'Strict-Transport-Security' =>  'max-age=31536000',
      },

      # has a sensitive authorization header
      mode             => '0600',

      raw_append       => [
        'auth_pam "OCF Kubernetes View";',
        'auth_pam_service_name kubernetes_viewer_webui;',
      ],

      require          =>  File['/etc/pam.d/kubernetes_viewer_webui'];
  }
}
