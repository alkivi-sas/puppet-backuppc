class backuppc::service () {
	service { $backuppc::params::backuppc_service_name:
		ensure     => running,
		hasstatus  => true,
		hasrestart => true,
		enable     => true,
	}
}

