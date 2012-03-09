class reprepro {

  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        squeeze, lenny: { include reprepro::debian }
        default: { fail "reprepro is not available for ${operatingsystem}/${lsbdistcodename}"}
      }
    }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }

}

