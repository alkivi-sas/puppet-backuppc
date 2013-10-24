class backuppc::config () {
  File {
    ensure => present,
    owner  => 'backuppc',
    group  => 'www-data',
    mode   => '0644',
  }

  file { '/etc/backuppc/config.pl':
    content => template('backuppc/config.pl.erb'),
    notify  => Class['backuppc::service'],
  }

  concat { '/etc/backuppc/hosts':
    owner   => 'backuppc',
    group   => 'www-data',
    mode    => '0644',
    notify  => Class['backuppc::service'],
  }

  concat::fragment { 'base':
    target  => '/etc/backuppc/hosts',
    content => template('backuppc/hosts.erb'),
    order   => 01,
  }

  file { '/etc/backuppc/localhost.pl':
    ensure => absent,
  }

  file { $backuppc::htaccess:
    ensure  => present,
    owner   => 'alkivi',
    group   => 'alkivi',
    mode    => '0644',
    source => 'puppet:///modules/backuppc/htaccess',
  }
}
