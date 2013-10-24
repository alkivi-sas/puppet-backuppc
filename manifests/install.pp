class backuppc::install () {
  Package {
    ensure => installed,
  }

  package { $backuppc::params::backuppc_package_name:
  }

  package { $backuppc::params::backuppc_extra_packages:
  }
}
