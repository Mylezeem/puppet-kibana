class kibana (
  $source_url    = $kibana::params::source_url,
  $webserver     = $kibana::params::webserver,
  $vhost_options = $kibana::params::vhost_options,
) inherits kibana::params {

  include ::stdlib

  # Setup a webserver with reverse
  # proxy
  #
  if $webserver == 'apache' {
    include ::apache

    $vhost_default = {
      'docroot'    => '/dev/null',
      'port'       => '80',
      'servername' => $::fqdn,
      'proxy_pass' => [{'path' => '/', 'url' => 'http://localhost:5601'}]
    }
    $vhost_tmp = merge($vhost_default, $vhost_options)
    $vhost_real = hash('kibana', $vhost_tmp)

    create_resource('apache::Vhost', $vhost_real)
  }

  # Get Kibana tar ball
  #
  #archive { 'kibana-v4.0.0' :
  archive { 'kibana' :
    ensure           => present,
    url              => $source_url,
    target           => '/opt/kibana',
    follow_redirects => true,
    checksum         => false,
    src_target       => '/tmp',
  } ->
  # Create the systemd script
  # for Kibana 4
  #
  file { '/usr/lib/systemd/system/kibana.service' :
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/kibana/kibana.service',
  } ->
  service { 'kibana' :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
    

}
