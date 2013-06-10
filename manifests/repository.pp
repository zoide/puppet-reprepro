/*
 * == Definition: reprepro::repository
 *
 * Adds a packages repository.
 *
 * Parameters:
 * - *name*: the name of the repository
 * - *ensure*: present/absent, defaults to present
 * - *basedir*: base directory of reprepro
 * - *incoming_name*: the name of the rule-set, used as argument
 * - *incoming_dir*: the name of the directory to scan for .changes files
 * - *incoming_tmpdir*: directory where the files are copied into before they
 * are read
 * - *incoming_allow*: allowed distributions
 * - *owner*: owner of reprepro files
 * - *group*: reprepro files group
 * - *options*: reprepro options
 *
 * Requires:
 * - Class["reprepro"]
 *
 * Example usage:
 *
 * reprepro::repository { 'localpkgs':
 *  ensure  => present,
 *  options => ['verbose', 'basedir .'],
 *}
 */
define reprepro::repository (
  $ensure          = present,
  $basedir         = $::reprepro::params::basedir,
  $incoming_name   = 'incoming',
  $incoming_dir    = 'incoming',
  $incoming_tmpdir = 'tmp',
  $incoming_allow  = '',
  $owner           = 'reprepro',
  $group           = 'reprepro',
  $options         = ['verbose', 'ask-passphrase', 'basedir .']) {
  include reprepro::params
  include concat::setup

  File {
    owner  => $owner,
    group  => $group,
    mode   => '2755',
    ensure => $ensure,
  }

  file { "${basedir}/${name}":
    ensure  => $ensure ? {
      present => 'directory',
      default => $ensure,
    },
    purge   => $ensure ? {
      present => undef,
      default => true,
    },
    recurse => $ensure ? {
      present => undef,
      default => true,
    },
    force   => $ensure ? {
      present => undef,
      default => true,
    },
  }

  if $ensure == 'present' {
    file {
      "${basedir}/${name}/dists":
        ensure  => 'directory',
        require => File["${basedir}/${name}"];

      "${basedir}/${name}/pool":
        ensure  => 'directory',
        require => File["${basedir}/${name}"];

      "${basedir}/${name}/conf":
        ensure  => 'directory',
        require => File["${basedir}/${name}"];

      "${basedir}/${name}/lists":
        ensure  => 'directory',
        require => File["${basedir}/${name}"];

      "${basedir}/${name}/db":
        ensure  => 'directory',
        require => File["${basedir}/${name}"];

      "${basedir}/${name}/logs":
        ensure  => 'directory',
        require => File["${basedir}/${name}"];

      "${basedir}/${name}/tmp":
        ensure  => 'directory',
        require => File["${basedir}/${name}"];

      "${basedir}/${name}/incoming":
        ensure  => 'directory',
        require => File["${basedir}/${name}"],
        mode    => '2775';

      "${basedir}/${name}/conf/options":
        mode    => '0640',
        content => inline_template("<%= options.join(\"\n\") %>\n"),
        require => File["${basedir}/${name}/conf"];

      "${basedir}/${name}/conf/incoming":
        mode    => '0640',
        content => template('reprepro/incoming.erb'),
        require => File["${basedir}/${name}/conf"];
    }

    concat { "${basedir}/${name}/conf/distributions":
      owner   => $owner,
      group   => $group,
      mode    => '0640',
      require => File["${basedir}/${name}/conf"],
    }
  }
}
