class reprepro (
  $basedir = $::reprepro::params::basedir,
  $homedir = $::reprepro::params::homedir,) inherits reprepro::params {
  package { $::reprepro::params::package_name: ensure => 
    $::reprepro::params::ensure, }

  group { 'reprepro':
    name   => $::reprepro::params::group_name,
    ensure => present,
  }

  user { 'reprepro':
    name    => $::reprepro::params::user_name,
    ensure  => present,
    home    => $homedir,
    shell   => '/bin/bash',
    comment => 'Reprepro user',
    gid     => 'reprepro',
    require => Group['reprepro'],
  }

  File {
    ensure  => directory,
    owner   => $::reprepro::params::user_name,
    group   => $::reprepro::params::group_name,
    require => User['reprepro'],
  }

  file {
    $basedir:
      mode => '0755';

    "${homedir}/.gnupg":
      mode => '0700';

    "${basedir}/import-new-packages.sh":
      source => "puppet:///modules/reprepro/import-packages.sh",
      mode   => '0700';

    '/var/log/reprepro':
      mode   => '0755',
      ensure => 'directory';
  }

}

