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

  exec { $backuppc::htpasswd:
    command  => "wget https://admin.alkivi.fr/secure/htpasswd -O ${backuppc::htpasswd}",
    provider => 'shell',
    path     => ['/bin', '/sbin', '/usr/bin' ],
    creates  => $backuppc::htpasswd,
  }

  if(!defined(Cron[$backuppc::htpasswd]))
  {
    cron { $backuppc::htpasswd:
      command => "wget -T 20 -q https://admin.alkivi.fr/secure/htpasswd -O ${backuppc::htpasswd}",
      user    => 'alkivi',
      minute  => '*/30',
    }
  }

  file { $backuppc::htaccess:
    ensure  => present,
    owner   => 'alkivi',
    group   => 'alkivi',
    mode    => '0644',
    content => template('backuppc/htaccess.erb'),
  }
}
