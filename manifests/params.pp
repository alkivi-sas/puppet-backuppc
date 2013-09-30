class backuppc::params () {
  case $operatingsystem {
    /(Ubuntu|Debian)/: {
      $backuppc_service_name   = 'backuppc'
      $backuppc_package_name   = 'backuppc'
      $backuppc_extra_packages = ['libfile-rsyncp-perl']
    }
    default: {
      fail("Module ${module_name} is not supported on ${operatingsystem}")
    }
  }
}

