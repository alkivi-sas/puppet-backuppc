class backuppc::archive (
  $hubic_mount   = '/mnt/hubic',
  $archive_dir   = '/home/backuppc/archive',
  $admin_email   = 'backup@alkivi.fr',
  $from_email    = 'backup@alkivi.fr',
  $archive_split = '25',
) {

  validate_string($hubic_mount)
  validate_string($archive_dir)
  validate_string($admin_email)
  validate_string($from_email)
  validate_string($archive_split)

  Package {
    ensure => installed,
  }

  File {
    ensure => present,
    owner  => 'backuppc',
    group  => 'backuppc',
    mode   => '750',
  }

  $packages = ['alkivi-hubic']

  package { $packages: }

  concat::fragment { "config-archive":
    target  => '/etc/backuppc/hosts',
    content => "archive 0\n",
    order   => 03,
  }

  # Creates backup script
  file { '/usr/share/backuppc/bin/Alkivi_archiveHost':
    source => 'puppet:///modules/backuppc/Alkivi_archiveHost',
  }

  # Creates archive.pl config file
  file { '/etc/backuppc/archive.pl':
    content => template('backuppc/archive.pl.erb'),
    group   => 'www-data',
  }

  # TODO : cron
}
