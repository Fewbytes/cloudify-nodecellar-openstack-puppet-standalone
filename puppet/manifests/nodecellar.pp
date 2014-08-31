# MODULES: puppetlabs-nodejs
#          puppetlabs-vcsrepo 

class nodecellar(
  $git_url          = 'https://github.com/cloudify-cosmo/nodecellar.git',
  $git_branch       = 'master',
  $installation_dir = '/opt/nodecellar',
  $runit_base_dir   = '/etc/sv',
  $path             = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  $nodecellar_port  = 80,
  $mongo_host       = '127.0.0.1',
  $mongo_port       = 27017,
  $libcap_package   = 'libcap2-bin',
) {

  Exec {
    path => $path
  }

  if($nodecellar_port < 1024) {
    package { $libcap_package: }
    ->
    exec { 'Allow nodejs to bind to privileged ports':
      command => 'setcap "cap_net_bind_service=+ep" `which nodejs`',
      unless  => 'getcap `which nodejs` | grep -q "cap_net_bind_service+ep"',
      require => Class['nodejs'],
      before  => Anchor['nodejs-ready'],
    }
  }

  # NodeJS
  class { 'nodejs':
    manage_repo => true
  }
  ->
  anchor { 'nodejs-ready': }

  # Get nodecellar code
  package { 'git': }
  ->
  vcsrepo { $installation_dir:
    ensure   => present,
    provider => git,
    source   => $git_url,
    revision => $git_branch,
  }
  ->
  exec { 'Install nodecellar dependencies using npm':
    command => 'npm install',
    cwd     => $installation_dir,
    require => Anchor['nodejs-ready'],
    creates => "${installation_dir}/node_modules",
  }
  ->
  anchor { 'nodecellar-app-ready': }

  # Setup nodecellar service
  user { 'nodecellar':
    ensure => present,
  }

  package {'runit': }
  ->
  file { "${runit_base_dir}/nodecellar":
    ensure => directory,
  }
  ->
  file { "${runit_base_dir}/nodecellar/run":
    alias   => 'nodecellar-init-conf',
    ensure  => present,
    content => "#!/bin/bash -e\nPATH=${path} NODECELLAR_PORT=${nodecellar_port} MONGO_HOST=${mongo_host} MONGO_PORT=${mongo_port} exec chpst -u nodecellar nodejs ${installation_dir}/server.js",
    mode    => '0700',
  }
  ->
  service { 'nodecellar':
    ensure     => 'running',
    enable     => true,
    provider   => 'runit',
    hasrestart => false,
    require    => User['nodecellar'],
    require    => Anchor['nodecellar-app-ready'],
    subscribe  => File['nodecellar-init-conf'],
  }
}

### $cloudify_git_url                 = 'https://github.com/cloudify-cosmo/nodecellar.git'
### $cloudify_git_branch              = 'master'
### $cloudify_properties_base_port    = 8080
### $cloudify_related_host_ip         = '127.0.0.1'
### $cloudify_related_properties_port = 27017

class{'nodecellar':
  git_url         => $cloudify_properties_git_url,
  git_branch      => $cloudify_properties_git_branch,
  nodecellar_port => $cloudify_properties_base_port,
  mongo_host      => $cloudify_related_host_ip,
  mongo_port      => $cloudify_related_properties_port,
}
