/*
== Definition: reprepro::repository

Adds a packages repository.

Parameters:
- *name*: the name of the repository
- *ensure*: present/absent, defaults to present
- *basedir*: base directory of reprepro
- *incoming_name*: the name of the rule-set, used as argument
- *incoming_dir*: the name of the directory to scan for .changes files
- *incoming_tmpdir*: directory where the files are copied into before they are read
- *incoming_allow*: allowed distributions
- *owner*: owner of reprepro files
- *group*: reprepro files group
- *options*: reprepro options

Requires:
- Class["reprepro"]

Example usage:

  reprepro::repository { 'localpkgs':
    ensure  => present,
    options => ['verbose', 'basedir .'],
  }


*/
define reprepro::repository (
  $ensure          = present,
  $basedir         = $::reprepro::params::basedir,
  $incoming_name   = "incoming",
  $incoming_dir    = "incoming",
  $incoming_tmpdir = "tmp",
  $incoming_allow  = "",
  $owner           = 'reprepro',
  $group           = 'reprepro',
  $options         = ['verbose', 'ask-passphrase', 'basedir .']
  ) {

  include reprepro::params
  include concat::setup

  file {
    [
      "${basedir}/${name}/conf",
      "${basedir}/${name}/lists",
      "${basedir}/${name}/db",
      "${basedir}/${name}/logs",
      "${basedir}/${name}/tmp",
    ]:
      ensure  => $ensure ? { present => directory, default => $ensure,},
      purge   => $ensure ? { present => undef,     default => true,}, 
      recurse => $ensure ? { present => undef,     default => true,},
      force   => $ensure ? { present => undef,     default => true,},
      mode    => '2755',
      owner   => $owner, 
      group   => $group;
       
    [
      "${basedir}/${name}",
      "${basedir}/${name}/dists",
      "${basedir}/${name}/pool",
    ]:
      ensure  => $ensure ? { present => directory, default => $ensure,},
      purge   => $ensure ? { present => undef,     default => true,}, 
      recurse => $ensure ? { present => undef,     default => true,},
      force   => $ensure ? { present => undef,     default => true,},
      mode    => '2755', 
      owner   => $owner, 
      group   => $group;

    "${basedir}/${name}/incoming":
      ensure  => $ensure ? { present => directory, default => $ensure,},
      purge   => $ensure ? { present => undef,     default => true,}, 
      recurse => $ensure ? { present => undef,     default => true,},
      force   => $ensure ? { present => undef,     default => true,},
      mode    => '2770',
      owner   => $owner,
      group   => $group;

    "${basedir}/${name}/conf/options":
      ensure  => $ensure,
      mode    => '0640',
      owner   => $owner,
      group   => $group,
      content => inline_template("<%= options.join(\"\n\") %>\n");

    "${basedir}/${name}/conf/incoming":
      ensure  => $ensure,
      mode    => '0640',
      owner   => $owner,
      group   => $group,
      content => template("reprepro/incoming.erb");
  }

  concat { "${basedir}/${name}/conf/distributions":
    owner => $owner,
    group => $group,
    mode  => '0640',
  }

}
