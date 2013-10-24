class backuppc (
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
  $motd                 = true,
  $domain_name,
) {

  if($motd)
  {
    motd::register{ 'BackupPC Server': }
  }

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



}
