class backuppc::config (
    $domain_name          = $backuppc::domain_name,
    $wakeup_schedule      = $backuppc::wakeup_schedule,
    $max_backups          = $backuppc::max_backups,
    $max_user_backups     = $backuppc::max_user_backups,
    $max_nightly_jobs     = $backuppc::max_nightly_jobs,
    $max_old_log_days     = $backuppc::max_old_log_days,
    $full_period          = $backuppc::full_period,
    $incr_period          = $backuppc::incr_period,
    $full_keep_cnt        = $backuppc::full_keep_cnt,
    $full_keep_cnt_min    = $backuppc::full_keep_cnt_min,
    $full_age_max         = $backuppc::full_age_max,
    $incr_keep_cnt        = $backuppc::incr_keep_cnt,
    $incr_keep_cnt_min    = $backuppc::incr_keep_cnt_min,
    $incr_age_max         = $backuppc::incr_age_max,
    $incr_levels          = $backuppc::incr_levels,
    $email_min_days       = $backuppc::email_min_days,
    $email_from           = $backuppc::email_from,
    $email_to             = $backuppc::email_to,
    $cgi_admin_user_group = $backuppc::cgi_admin_user_group,
    $cgi_admin_users      = $backuppc::cgi_admin_users,

) {
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
}
