class backuppc (
  $htpasswd             = '/home/alkivi/.htpasswd',
  $htaccess             = '/usr/share/backuppc/cgi-bin/.htaccess',
  $wakeup_schedule      = [2,4,6,12,18,20,22],
  $max_backups          = 2,
  $max_user_backups     = 1,
  $max_nightly_jobs     = 4,
  $max_old_log_days     = 15,
  $full_period          = '6.97',
  $full_keep_cnt        = ['1'],
  $full_keep_cnt_min    = 1,
  $full_age_max         = 90,
  $incr_period          = '0.97',
  $incr_keep_cnt        = 5,
  $incr_keep_cnt_min    = 1,
  $incr_age_max         = 30,
  $incr_levels          = ['1'],
  $email_min_days       = '0.97',
  $email_from           = 'backup@alkivi.fr',
  $email_to             = 'backup+customer@alkivi.fr',
  $cgi_admin_user_group = 'admin',
  $cgi_admin_users      = ['martin', 'bayou'],
  $remote_backup        = false,
  $motd                 = true,
  $apache_vhost         = true,
  $domain_name,

) {

  if($motd)
  {
    motd::register{ 'BackupPC Server': }
  }

  validate_string($htpasswd)
  validate_string($domain_name)

  validate_array($wakeup_schedule)
  validate_string($max_backups)
  validate_string($max_user_backups)
  validate_string($max_nightly_jobs)
  validate_string($max_old_log_days)

  validate_string($full_period)
  validate_array($full_keep_cnt)
  validate_string($full_keep_cnt_min)
  validate_string($full_age_max)

  validate_string($incr_period)
  validate_string($incr_keep_cnt)
  validate_string($incr_keep_cnt_min)
  validate_string($incr_age_max)
  validate_array($incr_levels)

  validate_string($email_min_days)
  validate_string($email_from)
  validate_string($email_to)

  validate_string($cgi_admin_user_group)
  validate_array($cgi_admin_users)

  # declare all parameterized classes
  class { 'backuppc::params': }
  class { 'backuppc::install': }
  class { 'backuppc::config': }
  class { 'backuppc::service': }

  # declare relationships
  Class['backuppc::params'] ->
  Class['backuppc::install'] ->
  Class['backuppc::config'] ->
  Class['backuppc::service']

  # Apache config
  if($apache_vhost)
  {
    apache::vhost { 'backuppc':
      priority        => '001',
      servername      => "backup.${domain_name}",
      port            => '443',
      ssl             => true,
      ssl_cert        => '/home/alkivi/www/ssl/alkivi.crt',
      ssl_key         => '/home/alkivi/www/ssl/alkivi.key',
      docroot         => '/usr/share/backuppc/cgi-bin',
      logroot         => '/home/alkivi/www/log',
      access_log      => false,
      override        => ['All'],
      error_log_file  => 'apache_error.log',
      custom_fragment => '
      CustomLog /home/alkivi/www/log/apache_access.log combined
      Alias /backuppc /usr/share/backuppc/cgi-bin/
      ',
      directories     => [
        {
          path           => '/usr/share/backuppc/cgi-bin',
          options        => 'ExecCGI FollowSymlinks',
          allow_override => ['Limit','AuthConfig'],
          order          => ['allow','deny'],
          addhandlers    => [
            {
              handler    => 'cgi-script',
              extensions => ['.cgi'],
            }
          ],
        },
      ],
    }
  }

  if($remote_backup)
  {
    class { 'backuppc::archive':
      from_email  => $email_from,
      admin_email => $email_to,
    }
  }

}
