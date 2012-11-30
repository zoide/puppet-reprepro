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
- *options*: reprepro options

Requires:
- Class["reprepro"]

Example usage:

    reprepro::distribution {"dev-lenny-backports":
      ensure        => present,
      repository    => "dev",
      codename      => "lenny-backports",
      origin        => "Camptocamp",
      label         => "Camptocamp",
      suite         => "lenny-backports",
      architectures => "i386 amd64 source",
      components    => "main contrib non-free",
      description   => "Camptocamp consolidated lenny-backports dev-repository",
      sign_with     => "packages@mycompagny",
      update        => "lenny-backports",
      options       => ['verbose', 'basedir .'],
    }

*/
define reprepro::repository (
  $ensure          = present,
  $basedir         = $::reprepro::params::basedir,
  $incoming_name   = "incoming",
  $incoming_dir    = "incoming",
  $incoming_tmpdir = "tmp",
  $incoming_allow  = "",
  $options         = ['verbose', 'ask-passphrase', 'basedir .']
  ) {

  include reprepro::params

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
      mode    => '2750',
      owner   => 'reprepro', 
      group   => 'reprepro';
       
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
      owner   => 'reprepro', 
      group   => 'reprepro';

    "${basedir}/${name}/incoming":
      ensure  => $ensure ? { present => directory, default => $ensure,},
      purge   => $ensure ? { present => undef,     default => true,}, 
      recurse => $ensure ? { present => undef,     default => true,},
      force   => $ensure ? { present => undef,     default => true,},
      mode    => '2770',
      owner   => 'reprepro',
      group   => 'reprepro';

    "${basedir}/${name}/conf/options":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'reprepro',
      group   => 'reprepro',
      content => inline_template("<%= $options.join(\"\n\") %>");

    "${basedir}/${name}/conf/incoming":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'reprepro',
      group   => 'reprepro',
      content => template("reprepro/incoming.erb");
  }

  cron { "${name} cron":
    command => template('reprepro/cron.erb'),
    user    => $::reprepro::params::user_name,
    minute  => '*/5',
  }

}
