/*

== Class: reprepro::params

Global parameters

*/
class reprepro::params {

  $basedir = '/var/packages'
  $ensure  = present

  case $::osfamily {
    Debian: {
      $package_name = 'reprepro'
      $user_name    = 'reprepro'
      $group_name   = 'reprepro'
    }
  }

}
